## Copyright (C) 2000 P.R. Nienhuis
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the
## Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02110-1301, USA.

## funm:  Matrix equivalent of function 'name'
##
## Usage:    B = funm(A, name)
##  where    A = square non-singular matrix, provisionally
##               real-valued
##           B = square result matrix
##        name = string, name of function to apply to A.
##        args = any arguments to pass to function 'name'
##               The function must accept a vector and apply
##               element-wise to that vector.
##
## Example:  To compute sqrtm(A), you could use funm(A, 'sqrt')
##
## Note that you should not use funm for 'sqrt', 'log' or 'exp'; instead
## use sqrtm, logm and expm which are more robust. Similarly,
## trigonometric and hyperbolic functions (cos, sin, tan, cot, sec, csc,
## cosh, sinh, tanh, coth, sech, csch) are better handled by thfm(A,
## name), which defines them in terms of the more robust expm.

## NOTE: the following comments are withheld until they can be verified
##
## If you have a network of coupled systems, where for the individual
## systems a solution exists in terms of scalar variables, in many
## cases the network might be solved using the same form of the
## solution but with substituting the matrix equivalent of the function
## applied to the scalar variables.
## The approach is to do an eigen-analysis of the network to decouple
## the systems, apply the scalar functions to the eigenvalues,
## and then recombine the systems into a network.

## Author: P.R. Nienhuis <106130.1515@compuserve.com>
## Additions by P. Kienzle, .........
## 2001-03-01 Paul Kienzle
##    * generate error for repeated eigenvalues

function B = funm(A, name)

  if (nargin != 2 || !ischar(name) || ischar(A))
    usage ("B = funm (A, 'f' [, args])");
  endif

  [V, D] = eig (A);
  D = diag (feval (name, diag(D)));
  B = V * D * inv (V);
  
endfunction
