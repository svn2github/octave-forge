## Copyright (C) 2001 Laurent Mazet
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

## usage: y = ctranspose (x)
##
## Generate the complex conjugate transpose. Equivalent to x'
##
## x: input matrix.
##
## y: complex conjugate transpose of x.

## 2001 FEB 07
##   initial release
## 2001-12-03 Rolf Fabian
## * Don't use x.' !!!

function y = ctranspose (x)  

  y = x';
  
endfunction;
