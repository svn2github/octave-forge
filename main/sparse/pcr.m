function [x, flag, relres, iter, resvec] = pcr(A,b,tol,maxit,M,x0,varargin)
%
%[X, FLAG, RELRES, ITER, RESVEC] = pcr( A, B, TOL, MAXIT, M, X0, ... )
%
%Solves the linear system of equations A*x = B by means of the  Preconditioned
%Conjugate Residuals iterative method.
%
%INPUT ARGUMENTS
%---------------
%
%A can be either a square (preferably sparse) matrix or a name of a function
%which computes A*x. In principle A should be symmetric and nonsingular;
%if PCR finds A (numerically) singular, you will get a warning message
%and the FLAG output parameter will be set.
%
%B is the right hand side vector.
%
%TOL is the required relative tolerance for the residual error, B-A*X. The
%iteration stops if ||B-A*X|| <= TOL*||B-A*X0||, where ||.|| denotes the
%Euclidean norm. If TOL is empty or is omitted, the function sets TOL = 1e-6 by
%default.
%
%MAXIT is the maximum allowable number of iterations;  if [] is supplied for
%MAXIT, or PCR has less arguments, a default value equal to 20 is used.
%
%M is the (left) preconditioning matrix, so that the iteration is
%(theoretically) equivalent to solving by PCR P*x = M\B, with P = M\A.
%Instead of a matrix, the user may pass here a name of a function which returns
%the result of applying the inverse of M to a vector (usually this is the
%preferred way of using the preconditioner), see EXAMPLES for details. 
%Usually it is assumed that M is positive definite. Note that a proper choice of
%the preconditioner may dramatically improve the overall performance of the
%method! If [] is supplied for M, or PCR has less arguments, no preconditioning
%is  applied.
%
%X0 is the initial guess. If X0 is empty or omitted, the function sets X0 to a
%zero vector by default.
%
%The arguments which follow X0 are treated as parameters, and passed in a proper
%way to any of the functions (A or M) which are passed to PCR. See the EXAMPLES
%for details.
%
%OUTPUT ARGUMENTS
%----------------
%
%X is the computed approximation to the solution x of A*x=B.
%
%FLAG reports on the convergence. FLAG = 0 means the solution converged
%and the tolerance criterion given by TOL is satisfied. FLAG = 1 means that the
%limit MAXIT for the iteration count was reached. FLAG = 3 reports 
%PCR breakdown, see [1] for details.
%
%RELRES is the ratio of the final residual to its initial value, measured in the
%Euclidean norm.
%
%ITER is the actual number of iterations performed.
%
%RESVEC describes the convergence history of the method, so that RESVEC(i) 
%contains the Euclidean norms of the residual after the (i-1)-th iteration,  
%i = 1,2,...ITER+1. 
%
%EXAMPLES 
%--------
%
%Let us consider a trivial problem with a diagonal matrix (we exploit the
%sparsity of A) 
%
%	N = 10; 
%	A = diag([1:N]); A = sparse(A);  
%	b = rand(N,1);
%
%EX. 1. Simplest use of PCR
%
%	x = pcr(A,b)
%
%EX. 2. PCR with a function which computes A*x
%
%	function y = applyA(x) y = [1:10]'.*x; end
%
%	x = pcr('applyA',b)
%
%EX. 3. Preconditioned iteration, with full diagnostics. The preconditioner (quite
%strange, because even the original matrix A is trivial) is defined as a
%function:
%
%	function y = applyM(x)		
%	K = floor(length(x)-2); 
%	y = x; 
%	y(1:K) = x(1:K)./[1:K]';	
%	end
%
%	[x, flag, relres, iter, resvec] = pcr(A,b,[],[],'applyM')
%	semilogy([1:iter+1], resvec);
%
%EX. 4. Finally, a preconditioner which depends on a parameter K:
%
%	function y = applyM(x, varargin)
%	K = varargin{1}; 
%	y = x; y(1:K) = x(1:K)./[1:K]';	 
%	end
%
%	[x, flag, relres, iter, resvec] = pcr(A,b,[],[],'applyM',[],3)
%
%You can also run 
%
%	demo('pcr') 
%
%from the command line to see simple examples of how the PCR works.
%
%SEE ALSO: sparse, pcg, gmres
%
%REFERENCES
%
%	[1] W. Hackbusch, "Iterative Solution of Large Sparse Systems of
% 	Equations", section 9.5.4; Springer, 1994

%% Copyright (C) 2004 Piotr Krzyzanowski <piotr.krzyzanowski@mimuw.edu.pl>
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; if not, write to the Free Software
%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%% 
%% REVISION HISTORY
%%
%% 2004-08-14, Piotr Krzyzanowski <piotr.krzyzanowski@mimuw.edu.pl>
%%
%% 	Added 4 demos and 4 tests
%% 
%% 2004-08-01, Piotr Krzyzanowski <piotr.krzyzanowski@mimuw.edu.pl>
%%
%% 	First version of pcr code

breakdown = false;

if ((nargin < 6) || isempty(x0))
	x = zeros(size(b));
else
	x = x0;
end

if (nargin < 5)
	M = [];
end

if ((nargin < 4) || isempty(maxit))
	maxit = 20;
end

maxit = maxit + 2;

if ((nargin < 3) || isempty(tol))
	tol = 1e-6;
end

if (nargin < 2)
	usage('x=pcr(A,b)');
end

% init
if (isnumeric(A))		% is A a matrix?
	r = b-A*x;
else				% then A should be a function!
	r = b-feval(A,x,varargin{:});
end

if (isnumeric(M))		% is M a matrix?
	if isempty(M)		% 	if M is empty, use no precond
		p = r;
	else			%	otherwise, apply the precond
		p = M\r;
	end
else				% then M should be a function!
	p = feval(M,r,varargin{:});
end

iter = 2;

b_bot_old = 1;
q_old = p_old = s_old = zeros(size(x));

	if (isnumeric(A))		% is A a matrix?
		q = A*p;
	else				% then A should be a function!
		q = feval(A,p,varargin{:});
	end
	
resvec(1) = abs(norm(r)); 

%iteration
while (	(resvec(iter-1) > tol*resvec(1)) && (iter < maxit) ),
	
	if (isnumeric(M))		% is M a matrix?
		if isempty(M)		% 	if M is empty, use no precond
			s = q;
		else			%	otherwise, apply the precond
			s = M\q;
		end
	else				% then M should be a function!
		s = feval(M,q,varargin{:});
	end
	b_top = r'*s;
	b_bot = q'*s;
	
	if (b_bot == 0.0)
		breakdown = true;
		break;
	end
	lambda = b_top/b_bot;
	
	x = x + lambda*p;
	r = r - lambda*q;
	
	if (isnumeric(A))		% is A a matrix?
		t = A*s;
	else				% then A should be a function!
		t = feval(A,s,varargin{:});
	end
	
	alpha0 = (t'*s)/b_bot;
	alpha1 = (t'*s_old)/b_bot_old;
	
	p_temp = p; q_temp = q;
	p = s - alpha0*p - alpha1*p_old;
	q = t - alpha0*q - alpha1*q_old;
	
	s_old = s;
	p_old = p_temp;
	q_old = q_temp;
	b_bot_old = b_bot;
	
	
	resvec(iter) = abs(norm(r));
	iter = iter + 1;
end

flag = 0;
relres = resvec(iter-1)./resvec(1);
iter = iter - 2;
if ( iter >= (maxit-2) )
	flag = 1;
	if (nargout < 2)
		warning('PCR: maximum number of iterations (%d) reached\n',...
			iter);
		warning('The initial residual norm was reduced %g times.\n',...
			1.0/relres);
	end
else
	if ((nargout < 2) && (~breakdown))
		fprintf(stderr, 'PCR: converged in %d iterations. \n', iter);
		fprintf(stderr, 'The initial residual norm was reduced %g times.\n',...
			1.0/relres);
	end	
end
if (breakdown)
	flag = 3;
	if (nargout < 2)
		warning('PCR: breakdown occured.\n');
		warning('System matrix singular or preconditioner indefinite?\n');
	end
end

end
%!demo
%!
%!	# Simplest usage of PCR (see also 'help pcr')
%!
%!	N = 20; 
%!	A = diag(linspace(-3.1,3,N)); b = rand(N,1); y = A\b; #y is the true solution
%!  	x = pcr(A,b);
%!	printf('The solution relative error is %g\n', norm(x-y)/norm(y));
%!
%!	# You shouldn't be afraid if PCR issues some warning messages in this
%!	# example: watch out in the second example, why it takes N iterations 
%!	# of PCR to converge to (a very accurate, by the way) solution
%!demo
%!
%!	# Full output from PCR
%!	# We use this output to plot the convergence history  
%!
%!	N = 20; 
%!	A = diag(linspace(-3.1,30,N)); b = rand(N,1); X = A\b; #X is the true solution
%!  	[x, flag, relres, iter, resvec] = pcr(A,b);
%!	printf('The solution relative error is %g\n', norm(x-X)/norm(X));
%!	title('Convergence history'); xlabel('Iteration'); ylabel('log(||b-Ax||/||b||)');
%!	semilogy([0:iter],resvec/resvec(1),'o-g;relative residual;');
%!demo
%!
%!	# Full output from PCR
%!	# We use indefinite matrix based on the Hilbert matrix, with one
%!	# strongly negative eigenvalue
%!	# Hilbert matrix is extremely ill conditioned, so is ours, 
%!	# and that's why PCR WILL have problems
%!
%!	N = 10; 
%!	A = hilb(N); A(1,1)=-A(1,1); b = rand(N,1); X = A\b; #X is the true solution
%!	printf('Condition number of A is   %g\n', cond(A));
%!  	[x, flag, relres, iter, resvec] = pcr(A,b,[],200);
%!	if (flag == 3)
%!	  printf('PCR breakdown. System matrix is [close to] singular\n');
%!	end
%!	title('Convergence history'); xlabel('Iteration'); ylabel('log(||b-Ax||)');
%!	semilogy([0:iter],resvec,'o-g;absolute residual;');
%!demo
%!
%!	# Full output from PCR
%!	# We use an indefinite matrix based on the 1-D Laplacian matrix for A, 
%!	# and here we have cond(A) = O(N^2)
%!	# That's the reason we need some preconditioner; here we take
%!	# a very simple and not powerful Jacobi preconditioner, 
%!	# which is the diagonal of A
%!
%!	# Note that we use here indefinite preconditioners!
%!
%!	N = 100; 
%!	A = zeros(N,N);
%!	for i=1:N-1 # form 1-D Laplacian matrix
%!		A(i:i+1,i:i+1) = [2 -1; -1 2];
%!	endfor
%!	A = [A, zeros(size(A)); zeros(size(A)), -A];
%!	b = rand(2*N,1); X = A\b; #X is the true solution
%!	maxit = 80;
%!	printf('System condition number is %g\n',cond(A));
%!	# No preconditioner: the convergence is very slow!
%!
%!  	[x, flag, relres, iter, resvec] = pcr(A,b,[],maxit);
%!	title('Convergence history'); xlabel('Iteration'); ylabel('log(||b-Ax||)');
%!	semilogy([0:iter],resvec,'o-g;NO preconditioning: absolute residual;');
%!
%!	pause(1);
%!	# Test Jacobi preconditioner: it will not help much!!!
%!
%!	M = diag(diag(A)); # Jacobi preconditioner
%!  	[x, flag, relres, iter, resvec] = pcr(A,b,[],maxit,M);
%!	hold on;
%!	semilogy([0:iter],resvec,'o-r;JACOBI preconditioner: absolute residual;');
%!
%!	pause(1);
%!	# Test nonoverlapping block Jacobi preconditioner: this one should give
%!	# some convergence speedup!
%!
%!	M = zeros(N,N);k=4;
%!	for i=1:k:N # get k x k diagonal blocks of A
%!		M(i:i+k-1,i:i+k-1) = A(i:i+k-1,i:i+k-1);
%!	endfor
%!	M = [M, zeros(size(M)); zeros(size(M)), -M];
%!  	[x, flag, relres, iter, resvec] = pcr(A,b,[],maxit,M);
%!	semilogy([0:iter],resvec,'o-b;BLOCK JACOBI preconditioner: absolute residual;');
%!	hold off;
%!test
%!
%!	#solve small indefinite diagonal system
%!
%!	N = 10; 
%!	A = diag(linspace(-10.1,10,N)); b = ones(N,1); X = A\b; #X is the true solution
%!  	[x, flag] = pcr(A,b,[],N+1);
%!	assert(norm(x-X)/norm(X)<1e-10);
%!	assert(flag,0);
%!
%!test
%!
%!	#solve tridiagonal system, do not converge in default 20 iterations
%!	 #should perform max allowable default number of iterations
%!
%!	N = 100; 
%!	A = zeros(N,N);
%!	for i=1:N-1 # form 1-D Laplacian matrix
%!		A(i:i+1,i:i+1) = [2 -1; -1 2];
%!	endfor
%!	b = ones(N,1); X = A\b; #X is the true solution
%!  	[x, flag, relres, iter, resvec] = pcr(A,b,1e-12);
%!	assert(flag,1);
%!	assert(relres>0.6);
%!	assert(iter,20);
%!
%!test
%!
%!	#solve tridiagonal system with 'prefect' preconditioner
%!	#converges in one iteration
%!
%!	N = 100; 
%!	A = zeros(N,N);
%!	for i=1:N-1 # form 1-D Laplacian matrix
%!		A(i:i+1,i:i+1) = [2 -1; -1 2];
%!	endfor
%!	b = ones(N,1); X = A\b; #X is the true solution
%!  	[x, flag, relres, iter] = pcr(A,b,[],[],A,b);
%!	assert(norm(x-X)/norm(X)<1e-6);
%!	assert(relres<1e-6);
%!	assert(flag,0);
%!	assert(iter,1); #should converge in one iteration
%!
