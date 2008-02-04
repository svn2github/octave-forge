## Copyright (C) 2003 Motorola Inc and David Bateman
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{y} =} lookup_table (@var{table}, @var{x})
## @deftypefnx {Function File} {@var{y} =} lookup_table (@var{table}, @var{x}, @var{interp}, @var{extrap})
## Using the lookup table created by @dfn{create_lookup_table}, find the value
## @var{y} corresponding to @var{x}. With two arguments the lookup is done
## to the nearest value below in the table less than the desired value. With
## three arguments a simple linear interpolation is performed. With four
## arguments an extrapolation is also performed. The exact values of arguments
## three and four are irrelevant, as only there presence detremines whether
## interpolation and/or extrapolation are used.
## @end deftypefn

function y = lookup_table (table, x, interp, extrap);
  if (nargin < 2)
    error("lookup_table: needs two or more arguments");
  else 
    idx = lookup(table.x, x);
    if (nargin == 2)
      y = table.y (max(1,idx));
    else
      len = length(table.x);
      before = find(idx == 0);
      after = find(idx == len);
      idx = max(1,min(idx, len-1));
      xl = table.x(idx);
      yl = table.y(idx);
      xu = table.x(idx+1);
      yu = table.y(idx+1);
      ## Careful with the order of this interpolation to avoid underflow
      ## in fixed point calculations.
      y = ( yl + (yu - yl) ./ (xu - xl) .* (x - xl));
      if (nargin < 4)
	y(before) = table.y(1);
	y(after) = table.y(len);
      endif
    endif
  endif
endfunction
