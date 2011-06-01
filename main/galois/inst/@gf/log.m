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
## @deftypefn {Function File} {} log (@var{x})
## Compute the logarithm for each element of @var{x} for a Galois
## array.
## @end deftypefn

function y = log (g)
  if (any (g._x == 0))
    warning ("log: log of zero undefined in galois field");
  endif
  y = g;
  y._x = reshape (g._index_of (g._x + 1), size(g._x));
endfunction

%!assert(log(gf(0:7,3)),gf([7, 0, 1, 3, 2, 6, 4, 5], 3))
