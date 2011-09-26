#!/usr/bin/perl
## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
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
use File::Spec;                 # Perform operation on file names

foreach my $package_dir (@ARGV) {
  open (INDEX, "<", File::Spec->catfile ($package_dir, "INDEX") ) or die "Could not open INDEX file for read: $!";
  my %functions;
  while (my $line = <INDEX>) {
    if ($line =~ m/^ (.*)$/) {
      my $line = $1;
      ## some lines will have more than one function, separated by a space so get them too
      my @list = split (/\s/, $line);
      $functions{$_} = 1 foreach @list;
      ## some lines will have extra whitespace (trailing whitespace) which could be removed
      say "Line of '$line' has trailing whitespace" if $line =~ m/\s$/;
      ## we only need a space at the start of the line
      say "Line of '$line' has extra leading whitespace" if $line =~ m/^\s/;
      ## use spaces, not tabs
      say "Line of '$line' uses tabs instead of spaces" if $line =~ m/\t/;
    }
  }
  close(INDEX);
  my @files;
  push (@files, get_files(File::Spec->catfile ($package_dir, 'inst')) );
  push (@files, get_files(File::Spec->catfile ($package_dir, 'src')) );
  clean_array(\@files);
  foreach (@files) {
    say "'$_' is missing on INDEX" unless delete $functions{$_};
  }
  foreach (keys %functions) {
    say "'$_' is in the INDEX but there's no file for it";
  }
}

sub get_files {
  my $dirname = $_[0];
  opendir (DIR, $dirname) or die "Could not opendir $dirname: $!";
  my @files;
  while (my $file = readdir(DIR)) {
    next if $file =~ m/^\.\.?$/;
    next if $file eq 'Makefile';
    next if $file =~ m/^\.svn(ignore)?$/;
    next if ($file eq 'private' && -d File::Spec->catfile ($dirname, $file) );
    $file =~ s/\.m$// if $dirname =~ m/inst$/;
    $file =~ s/\.c(c)?$// if $dirname =~ m/src$/;
    push (@files, $file);
  }
  closedir(DIR);
  return @files;
}

sub clean_array {
  my %hash;
  foreach (@{$_[0]}) {
    if ($hash{$_}) {
      say "Ups! It seems that the function '$_' is repeated (maybe in inst and again in src)";
    } else {
      $hash{$_} = 1;
    }
  }
  @{$_[0]} = keys %hash;
}
