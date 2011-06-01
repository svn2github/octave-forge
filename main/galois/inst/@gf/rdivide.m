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
## @deftypefn {Function File} {} rdivide (@var{x}, @var{y})
## Return the element-by-element right division of the Galois Arrays 
## @var{x} and @var{y}. This function is equivalent to @w{@code{x ./ y}}.
## @seealso{ldivide, mrdivide}
## @end deftypefn

function y = rdivide (a, b)
  [a, b] = promote_and_check (a, b);
  alpha_to = a._alpha_to;
  index_of = a._index_of;
  y = zeros (size (a));
  nzidx = ! (a._x == 0 | b._x == 0);
  y(nzidx) = a._alpha_to (modn(index_of (a._x(nzidx) + 1) - 
			       index_of (b._x(nzidx) + 1) + a._n,
			       a._m, a._n) + 1);
  y = gf (y, a._m, a._prim_poly);
endfunction

%!assert(rdivide(gf([1,2,3],3),gf([4,5,6],3)),gf([7,4,5],3))
%!assert(gf([1,2,3],3) ./ gf([4,5,6],3),gf([7,4,5],3))
