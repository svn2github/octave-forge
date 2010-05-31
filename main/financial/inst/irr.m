## Copyright (C) 1995, 1996, 1997, 1998, 2000, 2002, 2004, 2005, 2006,
##               2007 Kurt Hornik
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
## @deftypefn {Function File} {} irr (@var{p}, @var{i})
## Return the internal rate of return of a series of payments @var{p}
## from an initial investment @var{i} (i.e., the solution of
## @code{npv (r, p) = i}.  If the second argument is omitted, a value of
## 0 is used.
## @seealso{npv, pv, rate}
## @end deftypefn

## Author: KH <Kurt.Hornik@wu-wien.ac.at>
## Description: Internal rate of return of an investment

function r = irr (p, i = 0)
  ## Check input
  if (nargin != 1 && nargin != 2)
    print_usage ();
  endif

  if (! (isvector (p)))
    error ("irr: p must be a vector");
  endif

  if (! isscalar (i))
    error ("irr: i must be a scalar");
  endif

  ## Solve system
  f = @(x) npv (x, p) - i;
  r = fsolve (f, 0.01);

endfunction
