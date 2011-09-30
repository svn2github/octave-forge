## Copyright 2007 R.G.H. Eschauzier <reschauzier@yahoo.com>
## Adapted by Carnë Draug on 2011 <carandraug+dev@gmail.com>
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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

## This function is necessary for impinvar and invimpinvar of the signal package

## Reverse the coefficients of a polynomial
function p_out = polyrev (p_in)
  n = length(p_in);
  for i=(1:n)
    p_out(i) = p_in(n-i+1);
  endfor
endfunction
