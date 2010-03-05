## Copyright (C) 1997, 2000, 2003, 2004, 2005, 2006, 2007 Kai P. Mueller
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} ugain (@var{n})
## Creates a system with unity gain, no states.
## This trivial system is sometimes needed to create arbitrary
## complex systems from simple systems with @command{buildssic}.
## Watch out if you are forming sampled systems since @command{ugain}
## does not contain a sampling period.
## @seealso{hinfdemo, jet707}
## @end deftypefn

## Author: Kai P. Mueller <mueller@ifr.ing.tu-bs.de>
## Created: April 1998

function outsys = ugain (n)

  if (nargin != 1)
    print_usage ();
  endif
  outsys = ss ([], [], [], eye (n));

endfunction
