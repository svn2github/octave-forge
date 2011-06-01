## Copyright (C) 2011 David Bateman
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
## @deftypefn {Function File} {} end (@var{obj}, @var{ind}, @var{num})
## Return the @code{end} index of a Galois array.
## @end deftypefn

function r = end (obj, index_pos, num_indices)
  dv = size (obj._x);
  for i = (num_indices + 1) : length (dv)
    dv(num_indices) *= dv(i);
  endfor
  if (index_pos <= length (dv))
    r = dv (index_pos);
  else
    r = 1;
  endif
endfunction

%!assert(gf(0:7,3)(end), gf(7,3))
%!assert(gf([0, 1; 2, 3], 3)(end, 1:2), gf ([2, 3], 3))
