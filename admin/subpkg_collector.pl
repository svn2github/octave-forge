#!/usr/bin/perl
## Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

use 5.010;                      # Use Perl 5.10
use strict;                     # Enforce some good programming rules
use warnings;                   # Replacement for the -w flag, but lexically scoped
use File::Spec;                 # Portably perform operations on file names
use File::Find;                 # Load functions to traverse a directory tree
use File::Copy;

## This function takes the path for the root of a package as argument and creates
## a directory tree ready to be packaged on the current working directory.
##
## It expects the following:
##
##  -root--->deprecated---> .m files
##        |
##        |-> inst-------->subpkg1--->src---------> .cc/.h/Makefile files
##        |           |            |
##        |           |            |->deprecated--> .m files
##        |           |            |
##        |           |            |->private-----> .m files
##        |           |            |
##        |           |            -> .m files
##        |           |
##        |           |--->subpkg2--->same structure as subpkg1
##        |           |--->subpkg3--->same structure as subpkg1
##        |          ...
##        |           |--->subpkgn
##        |
##        |-> src
##
##   * it will mix all Makefile it finds and merge them into a $root/src/Makefile.
##      This file should then be adjusted by the package mantainer. A Makefile
##      can already exist at $root/src and the others will be appended. If the
##      Makefiles are written with this on mind, it can save having to fix it
##
##   * if the deprecated/src/private directories are empty at the end, the script
##      removes them
##
##   * it's possible that $root/inst/private directory already exists inside
##      inst/, as well as some .m files inside inst/ and .cc files inside src/

my $dev   = $ARGV[0];
my $root  = get_export_dir ($dev);

my @command = ("svn", "export", $dev, $root);
system(@command) == 0 or die "system @command failed: $?";

find(\&rm_svnignore, $root);   # a little cleaning up

my $inst        = File::Spec->catdir($root, "inst");
my $deprecated  = File::Spec->catdir($root, "deprecated");
my $src         = File::Spec->catdir($root, "src");
my $private     = File::Spec->catdir($inst, "private");

## create them if they don't exist
-e $_ || mkdir $_ for ($inst, $deprecated, $src, $private);

opendir(my $INST, $inst) or die "Can't opendir $inst: $!";
while (my $subpkg = readdir($INST)) {
  next if $subpkg =~ /^\.\.?$/;
  next if $subpkg =~ /^private$/;

  my $subpkg_path = File::Spec->catdir($inst, $subpkg);
  opendir(my $SUBPKG, $subpkg_path) or die "Can't opendir $subpkg_path: $!";
  while (my $file = readdir($SUBPKG)) {
    next if $file =~ /^\.\.?$/;

    my $old = File::Spec->catdir($inst, $subpkg, $file);
    my $new;
    if ($file =~ /^deprecated$/) {
      $new = File::Spec->catdir($deprecated);
    } elsif ($file =~ /^private$/) {
      copy_private ($old, $private);
      next;
    } elsif ($file =~ /^src$/) {
      my @makefile = copy_src ($old, $src);
      my $makefile = File::Spec->catdir($src, "Makefile");
      open(my $MAKEFILE, ">>", $makefile) or die "Couldn't open $makefile for reading: $!\n";
      print {$MAKEFILE} $_ for @makefile;
      close($MAKEFILE);
      next;
    } else {
      $new = File::Spec->catdir($inst, $file);
    }
    move ($old, $new) or warn "Can't move $old to $new: $!";
  }
  closedir($SUBPKG);
  rmdir $subpkg_path or warn "Could not rmdir $subpkg_path: $!";
}
closedir($INST);

## if they were not necessary(are still empty, remove them
rm_if_empty ($_) for ($inst, $deprecated, $src, $private);
exit;

################################################################################
## Subroutines from this point on

sub get_export_dir {
  my @dirs = File::Spec->splitdir($_[0]);
  pop @dirs if $dirs[-1] eq "";                 # because it will be empty string if given path ended in filesep
  die "Export path '$dirs[-1]' already exist" if -e $dirs[-1];
  return $dirs[-1];
}

sub rm_svnignore {
  ## $_ is file path relative to pwd (always changing)
  ## $path is relative to working directory where script started
  my $path = $File::Find::name;
  unlink $_ or warn "Could not unlink $path: $!" if $_ =~ m/^\.svnignore$/;
}

sub copy_private {
  my ($old_private, $new_private) = @_;
  opendir(my $PRIVATE, $old_private) or die "Can't opendir $old_private: $!";
  while (my $file = readdir($PRIVATE)) {
    next if $file =~ /^\.\.?$/;

    my $old = File::Spec->catdir($old_private, $file);
    my $new = File::Spec->catdir($new_private, $file);
    if ($file =~ /^private$/) {
      copy_private ($old, $new);
    } else {
      move ($old, $new) or warn "Can't move $old to $new: $!";
    }
  }
  closedir($PRIVATE);
  rmdir $old_private or warn "Could not rmdir $old_private: $!";
}

sub copy_src {
  my ($old_src, $new_src) = @_;
  my @makefile;
  opendir(my $SRC, $old_src) or die "Can't opendir $old_src: $!";
  while (my $source = readdir($SRC)) {
    next if $source =~ /^\.\.?$/;
    if ($source =~ /^Makefile$/) {
      my $path = File::Spec->catdir($old_src, $source);
      open(my $MAKEFILE, "<", $path) or die "Couldn't open $path for reading: $!\n";
      @makefile = <$MAKEFILE>;
      close($MAKEFILE);
      unlink $path or warn "Could not unlink $path: $!";
    } else {
      my $old = File::Spec->catdir($old_src, $source);
      my $new = File::Spec->catdir($new_src, $source);
      move ($old, $new) or warn "Can't move $old to $new: $!";
    }
  }
  closedir($SRC);
  rmdir $old_src or warn "Could not rmdir $old_src: $!";
  return @makefile;
}

sub rm_if_empty {
  my $counter = 0;
  opendir(my $DIR, $_[0]) or die "Can't opendir $_[0]: $!";
  while (my $file = readdir($DIR) && $counter == 0) {
    next if $file =~ /^\.\.?$/;
    $counter++;
  }
  closedir ($DIR);
  rmdir $_[0] or warn "Could not rmdir $_[0]: $!" if $counter == 0;
}
