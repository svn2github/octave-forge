%!shared n,l,d,u,b,cl,cu
%! n=15; l=rand(n-1,1);d=rand(n,1);u=rand(n-1,1);b=rand(n,2);cl=rand;cu=rand;

## Need positive definite tridiagonal matrices to test the symmetric solver.
## If diagonal is much bigger than off-diagonal, then the determinants for
## all submatrices will be positive and the system will be positive
## definite (true??).  Since rand is in the range [0,1), adding 2 to
## the diagonal will force this to be true.  Similarly, adding 2 to
## the off diagonal will force the determinants negative and the system
## will not be positive definite.

%!test 
%! A=diag(u,-1)+diag(d+2)+diag(u,1);
%! assert(A*trisolve(d+2,u,b),b,10000*eps);

%!test
%! A=diag(l,-1)+diag(d)+diag(u,1);
%! assert(A*trisolve(l,d,u,b),b,10000*eps);

%!test
%! A=diag(cl,-n+1)+diag(u,-1)+diag(d+2)+diag(u,1)+diag(cu,n-1);
%! assert(A*trisolve(d+2,u,b,cl,cu),b,10000*eps);

%!test
%! A=diag(cl,-n+1)+diag(l,-1)+diag(d)+diag(u,1)+diag(cu,n-1);
%! assert(A*trisolve(l,d,u,b,cl,cu),b,10000*eps);

%!error
%! trisolve(d,u+2,b);

%!error
%! trisolve(d,u+2,b,cl,cu);
 