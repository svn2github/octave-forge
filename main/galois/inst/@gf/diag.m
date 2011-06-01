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
## @deftypefn {Function File} {} diag (@var{v}, @var{k})
## Return a diagonal matrix with Galois vector @var{v} on diagonal @var{k}.
## The second argument is optional.  If it is positive, the vector is placed on
## the @var{k}-th super-diagonal.  If it is negative, it is placed on the
## @var{-k}-th sub-diagonal.  The default value of @var{k} is 0, and the
## vector is placed on the main diagonal.  For example,
## 
## @example
## diag (gf([1, 2, 3],2), 1)
## ans =
## GF(2^2) array. Primitive Polynomial = D^2+D+1 (decimal 7)
## 
## Array elements = 
## 
##   0  1  0  0
##   0  0  2  0
##   0  0  0  3
##   0  0  0  0
## @end example
## @end deftypefn

function y = diag (g, varargin)
  y = g;
  y._x = diag (y._x, varargin{:});
endfunction

%!assert(diag(gf([1; 2; 3], 3)), gf([1, 0, 0; 0, 2, 0; 0, 0, 3], 3));
%!assert(diag (gf([1; 2; 3], 3), 1), gf([0, 1, 0, 0; 0, 0, 2, 0; 0, 0, 0, 3; 0, 0, 0, 0], 3));
%!assert(diag (gf([1; 2; 3], 3), 2), gf([0, 0, 1, 0, 0; 0, 0, 0, 2, 0; 0, 0, 0, 0, 3; 0, 0, 0, 0, 0; 0, 0, 0, 0, 0], 3));
%!assert(diag (gf([1; 2; 3], 3),-1), gf([0, 0, 0, 0; 1, 0, 0, 0; 0, 2, 0, 0; 0, 0, 3, 0], 3));
%!assert(diag (gf([1; 2; 3], 3),-2), gf([0, 0, 0, 0, 0; 0, 0, 0, 0, 0; 1, 0, 0, 0, 0; 0, 2, 0, 0, 0; 0, 0, 3, 0, 0], 3));
%!assert(diag (gf([1, 0, 0; 0, 2, 0; 0, 0, 3], 3)), gf([1; 2; 3], 3));
%!assert(diag (gf([0, 1, 0, 0; 0, 0, 2, 0; 0, 0, 0, 3; 0, 0, 0, 0], 3), 1), gf([1; 2; 3],3));
%!assert(diag (gf([0, 0, 0, 0; 1, 0, 0, 0; 0, 2, 0, 0; 0, 0, 3, 0], 3), -1), gf([1; 2; 3], 3));
%!assert(diag (gf(ones(1, 0), 3), 2), gf(zeros (2), 3));
%!assert(diag (gf(1:3, 3), 4, 2), gf([1, 0; 0, 2; 0, 0; 0, 0], 3));

