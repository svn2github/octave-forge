## Copyright (C) 2000 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## usage: x = fzero("f", x0)
##
## Find x such that f(x) = 0, starting at x0.
## If x0 is a range, start at the mid-point of the range.
## Returns NaN if the solution is not found.
##
## Note: This is a simple wrapper around the fsolve built-in function.

function [x, fval, status] = fzero(f,x0)

  [x, info] = fsolve (f, mean (x0));
  if info != 1
    x = NaN;
  endif

endfunction