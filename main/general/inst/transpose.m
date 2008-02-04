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

## usage: y = transpose (x)
##
## Generate the non-conjugate transpose. Equivalent to x.'
##
## x: input matrix.
##
## y: non-conjugate transpose of x.

## 2001 FEB 07
##   initial release

function y = transpose (x)  

  y = x.';
  
endfunction
