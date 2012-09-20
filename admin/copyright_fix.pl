#!/usr/bin/perl
## Copyright (C) 2011-2012 Carnë Draug <carandraug+dev@gmail.com>
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

## add copyright notice to multiple files
##
## OPTIONS
##  --author    This is the name and e-mail address of the author, and the
##              year(s). Defaults to name obtained from getpwnam call (no guess
##              for e-mail address) and current year. Can be specified multiple
##              times.
##
##  --comment   Character to use as comment. Defaults to '##' and '//' for
##              Octave and C++ source. See '--files' option.
##
##  --files     Extension of files to edit. Defaults to 'm'. Can also be 'cc'
##              and 'h'. See also the '--comment' option.
##
##  --license   License to use. Defaults to "GPL". Valid options are "GPL",
##              "LGPL", "AGPL", "modified BSD", "FreeBSD", "simplified BSD" and
##              "public domain".
##
##  --replace   Replace existing copyright notice on the files for the new one.
##              A copyright notice is identified as the first block of comments
##              as per the '--comment' option.
##
##  --verbose   Turns verbosity on.
##
##
## EXAMPLES:
##   Basic usage. Add a copyright notice to all .m files under current directory, recursively.
##      copyright_fix .
##
##   Same as before but with year and path specified
##      copyright_fix --author="Carnë Draug <carandraug+dev@gmail.com>=2009-2011"/home/devel/pkg/
##
##    Same as before but use '%%' for comment
##      copyright_fix --author="Carnë Draug <carandraug+dev@gmail.com>=2009-2011" --comment="%%" /home/devel/pkg/
##
##    Basic usage but for .cc files
##      copyright_fix --files="cc" .
##
##   Specifying mutiple authors with different years
##      copyright_fix --author="Carnë Draug <carandraug+dev@gmail.com>=2011" --author="Juan Carbajal <carbajal@ifi.uzh.ch>=2010" --comment="%%".
##
##   Specifying license
##      copyright_fix --license="modified BSD" .
##

use 5.010;                      # Use Perl 5.10
use strict;                     # Enforce some good programming rules
use warnings;                   # Replacement for the -w flag, but lexically scoped
use Getopt::Long;               # Parse program arguments
use File::Find;                 # Load functions to traverse a directory tree
use Tie::File;
use Fcntl;

my %authors;
my $comment;
my $files   = "m";
my $license = "GPL";
my $replace;
my $verbose;

GetOptions(
            'authors:s' => \%authors,
            'comment:s' => \$comment,
            'files:s'   => \$files,
            'license:s' => \$license,
            'replace!'  => \$replace,
            'verbose!'  => \$verbose,
           ) or die "Error processing options";

if (keys %authors == 0) {
  ## defaults to Full Name (index 6) of the user running this process and current year
  $authors{(getpwnam (getpwuid($>)))[6]} = (localtime)[5] + 1900;
}
## Order name of authors
## after this we can use sort to get the list of authors ordered by year first
## and alphabetic order of names second
## each element on %authors now points to an array
foreach (keys %authors) {
  my $year = delete $authors{$_};
  $authors{"$year-$_"} = [$year, $_];
}

if (!$comment) {
  if    ($files eq "cc" || $files eq "h") { $comment = "//"; }
  elsif ($files eq "m")                   { $comment = "##"; }
  else  {die "Comment character not defined and unknown type of source";}
}

## prepare license text
my @text;
my @copyR_line  = map ("Copyright (C) ${$authors{$_}}[0] ${$authors{$_}}[1]", sort keys %authors);
my @author_line = map ("Author: ${$authors{$_}}[1] (${$authors{$_}}[0])", sort keys %authors);

my @BSD_header      = (
                       @copyR_line,
                       "All rights reserved.",
                       "",
                       "Redistribution and use in source and binary forms, with or without",
                       "modification, are permitted provided that the following conditions are met:",
                       "",
                      );
my @BSD_clauses     = (
                        [
                         "    1 Redistributions of source code must retain the above copyright notice,",
                         "      this list of conditions and the following disclaimer.",
                        ],
                        [
                         "    2 Redistributions in binary form must reproduce the above copyright",
                         "      notice, this list of conditions and the following disclaimer in the",
                         "      documentation and/or other materials provided with the distribution.",
                        ],
                        [
                         "    3 Neither the name of the author nor the names of its contributors may be",
                         "      used to endorse or promote products derived from this software without",
                         "      specific prior written permission.",
                        ],
                      );
my @BSD_disclaimer  = (
                       "",
                       "THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''",
                       "AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE",
                       "IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE",
                       "ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR",
                       "ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL",
                       "DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR",
                       "SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER",
                       "CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,",
                       "OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE",
                       "OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.",
                      );

given ($license) {
  when (/GPL/i) {
    @text = (
             @copyR_line,
             "",
             "This program is free software; you can redistribute it and/or modify it under",
             "the terms of the GNU General Public License as published by the Free Software",
             "Foundation; either version 3 of the License, or (at your option) any later",
             "version.",
             "",
             "This program is distributed in the hope that it will be useful, but WITHOUT",
             "ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or",
             "FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more",
             "details.",
             "",
             "You should have received a copy of the GNU General Public License along with",
             "this program; if not, see <http://www.gnu.org/licenses/>.",
             );
  }
  when (/LGPL/i) {
    @text = (
             @copyR_line,
             "",
             "This program is free software; you can redistribute it and/or modify it under",
             "the terms of the GNU Lesser General Public License as published by the Free",
             "Software Foundation; either version 3 of the License, or (at your option) any",
             "later version.",
             "",
             "This program is distributed in the hope that it will be useful, but WITHOUT",
             "ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or",
             "FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License",
             "for more details.",
             "",
             "You should have received a copy of the GNU Lesser General Public License",
             "along with this program; if not, see <http://www.gnu.org/licenses/>.",
             );
  }
  when (/AGPL/i) {
    @text = (
             @copyR_line,
             "",
             "This program is free software; you can redistribute it and/or modify it under",
             "the terms of the GNU Affero General Public License as published by the Free",
             "Software Foundation; either version 3 of the License, or (at your option) any",
             "later version.",
             "",
             "This program is distributed in the hope that it will be useful, but WITHOUT",
             "ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or",
             "FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License",
             "for more details.",
             "",
             "You should have received a copy of the GNU Affero General Public License",
             "along with this program; if not, see <http://www.gnu.org/licenses/>.",
             );
  }
  when (/modified BSD/i)   { @text = (@BSD_header, @{$BSD_clauses[0]}, @{$BSD_clauses[1]}, @{$BSD_clauses[2]}, @BSD_disclaimer); }
  when (/simplified BSD/i) { @text = (@BSD_header, @{$BSD_clauses[0]}, @{$BSD_clauses[1]},                     @BSD_disclaimer); }
  when (/FreeBSD/i)        { @text = (@BSD_header, @{$BSD_clauses[0]}, @{$BSD_clauses[1]},                     @BSD_disclaimer,
                                     "",
                                     "The views and conclusions contained in the software and documentation are",
                                     "those of the authors and should not be interpreted as representing official",
                                     "policies, either expressed or implied, of the copyright holders."); }
  when (/public domain/i)  { @text = (@author_line, "This program is granted to the public domain."); }
  default { die "Non-valid license $license."; }
}

## add comment characters to text
@text = map ("$comment $_", @text);
## if we are not replacing a copyright notice, we need an empty line between
## the new copyright and what follows (texinfo maybe)
push (@text, "") if !$replace;

## function that actually edits file
sub fix {
  ## $_ is file path relative to pwd (always changing)
  ## $path is relative to working directory where script started

  my $path = $File::Find::name;
  return if $_ =~ m/^\.\.?$/;                         # skip special "files" . and ..
  return if $File::Find::dir =~ m/\.(svn|hg|git)$/;   # skip svn/hg/git directories
  return unless -f $_;                                # only files ...
  return unless $_ =~ m/\.$files$/;                   # with right extension
  tie (my @file, "Tie::File", $_) or (warn "Can't tie to '$path' : $!\n" && return);

  ## remove copyright
  if ($replace) {
    while ($file[0] =~ m/^$comment/) { shift @file; }             # remove top line as long as it looks like a comment
    if ($verbose) { say "Removed old copyright notice from $_"; }
  }

  ## add copyright
  unshift (@file, @text);
  if ($verbose) { say "Added copyright notice to '$_'"; }
}

if (@ARGV) {
  find(\&fix, @ARGV);     # this call does all the recursive work
} else {
  warn ("No path was specified, no changes were made");
}
