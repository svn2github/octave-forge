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
## @deftypefn {Function File} {y =} mtimes (@var{a}, @var{b})
## Return the matrix multiplications of Galois arrays.
## @end deftypefn

function y = mtimes (a, b)
  [a, b] = promote_and_check (a, b);

  if (isscalar(a) && isscalar(b))
    y = a .* b;
  else
    y = __gmtimes__ (a._x, b._x, a._m, a._alpha_to, a._index_of);
    y = gf (y, a._m, a._prim_poly);
  endif
endfunction

%!assert(gf([0,2,4,6;1,3,5,7],3)*gf([0,1;2,3;4,5;6,7],3),gf([0,0;0,0],3))
%!assert(gf([0,1;2,3;4,5;6,7],3)*gf([0,2,4,6;1,3,5,7],3),gf([1,3,5,7;3,1,7,5;5,7,1,3;7,5,3,1],3))

