## Copyright (C) 2013 davide
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## [ g, j, r ] = coupled_circuit_coeff (A, B, C, dt, x)
## 
## Compute coefficients of circuit-device coupling of the form:
##
## g * F + j(x) + r * I = 0;
## 
## 
## INPUT
## A B C : descriptor system 
## dt : the time step in the backward Euler discretization;
## x : state variables.
## 
## OUTPUT
## g : coefficient of the patch voltage
## j : constant bias term
## r : coefficient of the current in the node
## 
## Author: davide <davide@davide-K53SV>
## Created: 2013-06-10

function [g, j, r] = coupled_circuit_coeff (A, B, C, dt, x)

  freq = 1/dt;
  
  a12 = A(1,2:end);
  a22 = A(2:end,2:end);

  b11 = B(1,1);
  b12 = B(1,2:end);
  b21 = B(2:end,1);
  b22 = B(2:end,2:end);

  e11 = b11;
  e12 = a12 / dt + b12;
  e21 = b21;
  e22 = a22 / dt + b22;
  c1 = C(1);
  c2 = C(2:end);

  P = spdiags(1 ./ max(abs(e22),[],2));
  eprec = P * e22;
  w = (P * ((a22 * x) / dt - c2));

  g = e11 - e12 * (eprec \ (P * e21));
  j = c1 - (a12 * x) / dt + ...
      (e12 * (eprec \ w));
  r = 1;

endfunction
