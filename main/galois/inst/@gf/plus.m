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
## @deftypefn {Function File} {} plus (@var{a}, @var{b})
## Binary addition operator over a Galois field.
## @end deftypefn

function y = plus (a, b)
  [a, b] = promote_and_check (a, b);
  y = gf (bitxor (a._x, b._x), a._m, a._prim_poly);
endfunction

%!assert(gf(0:7,3)+gf(0:7,3),gf(zeros(1,8),3))

