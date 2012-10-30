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
##  --license   License to use. Defaults to "GPLv3+". Valid options are "GPLv3+",
##              "LGPLv3+", "AGPLv3+", "modified BSD", "FreeBSD", "simplified BSD",
##              "public domain", "X11", "Expat", "Apache2" and "ISC".
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
my $license = "GPLv3+";
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
  when (/GPLv3+/i) {
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
  when (/LGPLv3+/i) {
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
  when (/AGPLv3+/i) {
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
  when (/Apache2/i) {
    @text = (
             @copyR_line,
             "You should have received a copy of the GNU Affero General Public License",
             "Licensed under the Apache License, Version 2.0 (the \"License\");",
             "you may not use this file except in compliance with the License.",
             "You may obtain a copy of the License at",
             "",
             "    http://www.apache.org/licenses/LICENSE-2.0",
             "",
             "Unless required by applicable law or agreed to in writing, software",
             "distributed under the License is distributed on an \"AS IS\" BASIS,",
             "WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.",
             "See the License for the specific language governing permissions and",
             "limitations under the License.",
             );
  }
  when (/Expat/i) {
    @text = (
             @copyR_line,
             "Permission is hereby granted, free of charge, to any person obtaining",
             "a copy of this software and associated documentation files (the",
             "\"Software\"), to deal in the Software without restriction, including",
             "without limitation the rights to use, copy, modify, merge, publish,",
             "distribute, sublicense, and/or sell copies of the Software, and to",
             "permit persons to whom the Software is furnished to do so, subject to",
             "the following conditions:",
             "",
             "The above copyright notice and this permission notice shall be included",
             "in all copies or substantial portions of the Software.",
             "",
             "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND,",
             "EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF",
             "MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.",
             "IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY",
             "CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,",
             "TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE",
             "SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",
             );
  }
  when (/ISC/i) {
    @text = (
             @copyR_line,
             "Permission to use, copy, modify, and/or distribute this software for",
             "any purpose with or without fee is hereby granted, provided that the",
             "above copyright notice and this permission notice appear in all",
             "copies.",
             "",
             "THE SOFTWARE IS PROVIDED \"AS IS\" AND ISC DISCLAIMS ALL WARRANTIES WITH",
             "REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF",
             "MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL ISC BE LIABLE FOR ANY",
             "SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES",
             "WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN",
             "ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT",
             "OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.",
             );
  }
  when (/X11/i) {
    @text = (
             @copyR_line,
             "Permission is hereby granted, free of charge, to any person obtaining"
             "a copy of this software and associated documentation files (the"
             "\"Software\"), to deal in the Software without restriction, including"
             "without limitation the rights to use, copy, modify, merge, publish,"
             "distribute, sublicense, and/or sell copies of the Software, and to"
             "permit persons to whom the Software is furnished to do so, subject to"
             "the following conditions:"
             ""
             "The above copyright notice and this permission notice shall be"
             "included in all copies or substantial portions of the Software."
             ""
             "THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND,"
             "EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF"
             "MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND"
             "NONINFRINGEMENT. IN NO EVENT SHALL THE X CONSORTIUM BE LIABLE FOR ANY"
             "CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,"
             "TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE"
             "SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
             ""
             "Except as contained in this notice, the name of the authors shall"
             "not be used in advertising or otherwise to promote the sale, use or"
             "other dealings in this Software without prior written authorization"
             "from the authors."
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
