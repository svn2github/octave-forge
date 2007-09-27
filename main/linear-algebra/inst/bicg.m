## Copyright (C) 2006   Sylvain Pelissier   <sylvain.pelissier@gmail.com>
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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{x}} bicg (@var{A},@var{b},@var{tol},@var{maxit},@var{M})
## Solve the system @var{A}*@var{x} = @var{b} using the biconjugate gradient method.
## For having a good convergence, A must be sparse.
## @var{tol} specifies the tolerance of the method by default tol is 10e-6, @var{maxit} 
## specifies the maximal number of iterations and @var{M} is a preconditiner.
## @seealso{pcg,lu,chol}
## @end deftypefn

function x = bicg(A,b,tol,maxit,M)
	if (nargin < 2 || nargin > 5)
		usage("\n x = bicg(A,b)\n x = bicg(A,b,tol)\n x = bicg(A,b,tol,maxit)\n x = bicg(A,b,tol,maxit,M)");
	endif

	if(!issquare(A))
		error('A must be square');
	endif;
	if(!isvector(b))
		error('b must be a vector');
	endif
	if(rows(b) != rows(A))
		error('b and A must have the same number of row');
	endif
	if (nargin < 3)
		tol = 10e-6;
	endif
	if (nargin < 4)
		maxit = min([size(A)(1) 20]);
	endif
	if (nargin < 5)
		M = eye(size(A));
	endif
	if(!isscalar(tol))
		error('tol must be a scalar');
	endif
	if(!isscalar(maxit))
		error('maxit must be a scalar');
	endif
	if(rows(M) != rows(A) && columns(M) != columns(A))
		error('M and A must have the same size');
	endif
	
	x=ones(size(b));
	y=-ones(size(b));
	c = 2*ones(size(b));
	M = inv(M);
	r0 = b - A*x;
	s0 = c - A'*y;
	d = M*r0;
	f = M'*s0;
	res0 = Inf;
	if(r0 != zeros(size(r0)))
		
		for k = 1:maxit
			a = (s0'*M*r0)./(f'*A*d);
			x = x + a*d;
			y = y + conj(a)*f;
			r1 = r0 - a*A*d;
			s1 = s0 - conj(a)*A'*f;
			beta = (s1'*M*r1)./(s0'*M*r0);
			d = M*r1+beta*d;
			f = M'*s1+conj(beta)*f;
			r0 = r1;
			s0 = s1;
			res1 = norm(b-A*x)/norm(b);
			if(r1 == zeros(size(r1)) || res1 < tol)
				printf('bicg converged at iteration %i to a solution with relative residual %e\n',k,res1);
				break;
			endif
			if(res0 <= res1)
				printf('bicg stopped at iteration %i without converging to the desired tolerance %e\nbecause the method stagnated.\nThe iterate returned (number %i) has relative residual %e\n',k,tol,k-1,res0);
				break
			endif
			res0 = res1;
		endfor
		if(k == maxit)
			printf('bicg stopped at iteration %i without converging to the desired toleranc %e\nbecause the maximum number of iterations was reached.The iterate returned (number %i) has relative residual %e\n',maxit,tol,maxit,res1);
		endif
	else
		printf('bicg converge after 0 interation\n');
	endif
endfunction;
	