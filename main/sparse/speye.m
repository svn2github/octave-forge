## I = speye(m,n)
##   return a sparse identity matrix, without constructing the full matrix
function s = speye(m,n)
  if nargin == 1, n = m; endif
  lo = min([m,n]);
  s = sparse(1:lo,1:lo,1,m,n);
