## Copyright (C) 2012 Carlo de Falco
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

## -*- texinfo -*-
##
## @deftypefn {Function File} @
## {[@var{x}, @var{res}, @var{nit}]} = @
## block_jacobi (@var{A}, @var{b}, @var{x0}, @var{nblocks}, @var{maxit}, @var{tol})
## Solve the linear system @code{A * x = b} using the block-Jacobi iterative algorithm.
## The algorithm is implemented as a preconditioned Richardson iteration with a block-diagonal
## preconditioner.
## @var{nblocks} is the number of diagonal blocks to be extracted from the matrix @var{A},
## @var{maxit} the maximum number of iterations.
## If requested, the output parameter @var{res} contains the value of the residual @code{b - A*x} 
## at the last iteration and @var{nit} the number of iterations that have been performed.
## @end deftypefn

function [x, res, it] = block_jacobi (A, b, x0, nblocks, maxit, tol)
  
  m = rows (A);
  if nblocks > m
    error ("block_jacobi: cannot partition a %d size matrix in %d blocks", m, nblocks)
  endif

  lblocks = ceil (m / nblocks);
  ib = 1; first(ib) = 1; last(ib) = lblocks;
  while (last(ib) < m)
    ++ib;
    first(ib) = last(ib-1) + 1;
    last(ib)  = min ([m first(ib)+lblocks-1]);
  endwhile
  nblocks = ib;
  
  x = x0;
  for it = 1:maxit
    pres = res = b - A*x; 
    if (norm (res, inf) < tol); break; endif
    for ib = 1:nblocks
      range = first(ib):last(ib);
      pres(range) = diag (diag (A(range, range))) \ res(range);
    endfor
    x += pres;
  endfor
  
endfunction