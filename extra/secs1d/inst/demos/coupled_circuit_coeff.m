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

function [ g, j, r ] = coupled_circuit_coeff (A, B, C, dt, x)

freq = 1/dt;

%a{1,1} = A(1,1); % 0 by design
a{1,2} = A(1,2:end);
%a{2,1} = A(2:end,1); % 0 by design
a{2,2} = A(2:end,2:end);

b{1,1} = B(1,1);
b{1,2} = B(1,2:end);
b{2,1} = B(2:end,1);
b{2,2} = B(2:end,2:end);

e{1,1} = b{1,1};
e{1,2} = a{1,2}*freq+b{1,2};
e{2,1} = b{2,1};
e{2,2} = a{2,2}*freq+b{2,2};
f{1} = C(1);
f{2} = C(2:end);

g = e{1,1} - e{1,2} * (e{2,2} \ e{2,1});
j = f{1} - e{1,2} * (e{2,2} \ f{2}) + freq*( -a{1,2} + e{1,2} * (e{2,2} \ a{2,2})) * x;
r = 1;

return
endfunction
