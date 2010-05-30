## Copyright (C) 2009,2010 Carlo de Falco
##  
##  This program is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##  
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##  
##  You should have received a copy of the GNU General Public License
##  along with this program; if not, write to the Free Software
##  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
##  
##  Author: Carlo de Falco <cdf _AT_ users _DOT_ sourceforge _DOT_ net>
##  Created:  2009-06-01
##  Modified: 2010-05-28

##   Solves A x = b using the Preconditioned GMRES iterative method
##   with restart a.k.a. PGMRES(m).
##
##   rtol is the relative tolerance,
##   maxit the maximum number of iterations,
##   x0 the initial guess and 
##   m is the restart parameter.
##
##   A can be passed as a matrix or as a function handle or 
##   inline function f such that f(x) = A*x.
##
##   The preconditioner P can be passed as a matrix or as a function handle or 
##   inline function g such that g(x) = P\x.

function [x, resids] = pgmres (A, b, x0, rtol, maxit, restart, P)

  if ((nargin != 7) && (nargin != 6))
    print_usage ();    
  end
      
  if (ischar (A))
    Ax = str2func (A);
  elseif (ismatrix (A))
    Ax = @(x) A*x;
  elseif (isa (A, "function_handle"))
    Ax = A;
  else
    error ("pgmres: first argument is expected to be a function or matrix");
  endif

  if (nargin < 7)
    Pm1x = @(x) x;
  elseif (ischar (P))
    Pm1x = str2func (P);
  elseif (ismatrix (P))
    Pm1x = @(x) P\x;
  elseif (isa (P, "function_handle"))
    Pm1x = P;
  else
    error ("pgmres: first argument is expected to be a function or matrix");
  endif
  
  x_old = x0; 
  x = x_old;
  prec_res = Pm1x (b - Ax (x_old));
  prec_res_norm = norm (prec_res, 2);
  
  B = zeros (restart + 1, 1);
  V = zeros (rows (x), restart);
  H = zeros (restart + 1, restart);

  ## begin loop
  iter = 1;
  restart_it  = restart + 1; 
  resids      = zeros (maxit, 1);
  resids(1)   = prec_res_norm;
  prec_b_norm = norm (Pm1x (b), 2);
  
  while (((iter <= maxit) && ((rtol == 0) || (prec_res_norm > rtol*prec_b_norm))))	      
    ## restart
    if (restart_it > restart)
      restart_it = 1;
      x_old = x;	      
      prec_res = Pm1x (b - Ax (x_old));
      prec_res_norm = norm (prec_res, 2);
      B(1) = prec_res_norm;
      H(:) = 0;
      V(:, 1) = prec_res/prec_res_norm;
    endif      
    ##basic iteration

    tmp = Pm1x (Ax (V(:, restart_it)));
    [tmp, H(1:restart_it, restart_it)] = mgorth (tmp, V(:,1:restart_it));
    
    H(restart_it+1, restart_it) = norm (tmp, 2);
    V(:,restart_it+1) = (tmp / H(restart_it+1, restart_it));
    
    Y = (H(1:restart_it+1, 1:restart_it) \ B (1:restart_it+1));
	      
    little_res = B(1:restart_it+1) - H(1:restart_it+1, 1:restart_it) * Y(1:restart_it);
    prec_res_norm = norm (little_res, 2);
	      
    x = x_old + V(:, 1:restart_it) * Y(1:restart_it);
    
    resids(iter) = prec_res_norm ;
    restart_it++ ; iter++;
  endwhile
    
    resids = resids(1:iter-1);

endfunction


%!shared A, b, dim
%!test
%! dim = 300;
%! A = spdiags ([-ones(dim,1) 2*ones(dim,1) ones(dim,1)], [-1:1], dim, dim);
%! b =  ones(dim, 1); 
%! [x, resids] = pgmres (A, b, b, 1e-10,dim, dim, @(x) x./diag(A));
%! assert(x, A\b, 1e-9*norm(x,inf))
%!
%!test
%! [x, resids] = pgmres (A, b, b, 1e-10, 1e4, dim, @(x) diag(diag(A))\x);
%! assert(x, A\b, 1e-7*norm(x,inf))
%!
%!test
%! A = sprandn (dim, dim, .1);
%! A = A'*A;
%! b = rand (dim, 1);
%! [x, resids] = pgmres (@(x) A*x, b, b, 1e-10, dim, dim, @(x) diag(diag(A))\x);
%! assert(x, A\b, 1e-9*norm(x,inf))
%! [x, resids] = pgmres (A, b, b, 1e-10, dim, dim, @(x) diag(diag(A))\x);
%! assert(x, A\b, 1e-9*norm(x,inf))
%!
%!test
%! [x, resids] = pgmres (A, b, b, 1e-10, 1e6, dim, @(x) x./diag(A));
%! assert(x, A\b, 1e-7*norm(x,inf))