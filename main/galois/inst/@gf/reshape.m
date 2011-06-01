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
## @deftypefn  {Function File} {} reshape (@var{A}, @var{m}, @var{n}, @dots{})
## @deftypefnx {Function File} {} reshape (@var{A}, [@var{m} @var{n} @dots{}])
## @deftypefnx {Function File} {} reshape (@var{A}, @dots{}, [], @dots{})
## @deftypefnx {Function File} {} reshape (@var{A}, @var{size})
## Return a matrix with the specified dimensions (@var{m}, @var{n}, @dots{})
## whose elements are taken from the Galois array @var{A}.  The elements of
## the matrix are accessed in column-major order (like Fortran arrays are 
## stored).
## @end deftypefn

function y = reshape (g, varargin)
  y = g;
  y._x = reshape (g._x, varargin{:});
endfunction

%!assert(reshape(gf(0:7,3),2,4),gf([0,2,4,6;1,3,5,7],3))
