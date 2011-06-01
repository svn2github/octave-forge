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
## @deftypefn {Function File} {} all (@var{x}, @var{dim})
## Return the complex conjugate transpose of the Galois array @var{x}.  
## This function is equivalent to @code{x'}.
## @end deftypefn

function y = ctranspose (g);
  y = g;
  y._x = g._x ';
endfunction

%!assert(ctranspose(gf(0:3,3)),gf([0:3]',3))
%!assert(gf(0:3,3)',gf([0:3]',3))
