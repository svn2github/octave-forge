function [vec,val] = eiggen(A,B)
% function eiggen(A,B)
% find eigenvalues and vectors of a generalized problem, i.e.
% solve A*v=lambda*B*v for the eigenvalues lambda and eigenvectors v
% As a consequence we have    A*vec=B*vec*diag(val)
%
%  val = eiggen(A,B)  returns the eigenvalues
%  [vec,val] = eiggen(A,B)  returns eigenvectors and eigenvalues
%
%  A   n*n Matrix
%  B   a symmetric positive definite n*n matrix
%  val vector containing the n eigenvalues
%  vec n*n matrix, the columns represent the eigenvectors

% the algorithm uses the Cholesky decomposition B=R'*R and then
% computes the eigenvalues and vectors of inv(R')*A*inv(R)

R=chol(B);
Ri=inv(R);
[vec,val]=eig(Ri'*A*Ri);
vec=Ri*vec;
val=diag(val);
if nargout<2 vec=val;endif
endfunction
