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
## @deftypefn {Function File} {} sqrt (@var{x})
## Compute the square-root for each element of @var{x} for a Galois
## array.
## @end deftypefn

function y = sqrt (g)
  tmp = g._index_of(g._x + 1);
  y = g._alpha_to(floor((tmp + bitand(tmp, 1) * g._n) / 2 + 1));
endfunction

%!shared g
%! g = gf([0,2,4,6;1,3,5,7],3);
%!assert(sqrt(g), gf([0,6,2,4;1,7,3,5],3)
%!assert(sqrt(g) .* sqrt(g), g)
