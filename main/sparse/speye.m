## I = speye(m,n)
##   return a sparse identity matrix, without constructing the full matrix
function s = speye(m,n)
  if nargin == 1, n = m; endif
  lo = min([m,n]);
  s = sparse(1:lo,1:lo,1,m,n);

%!assert(issparse(speye(4)))
%!assert(speye(4),sparse(1:4,1:4,1))
%!assert(speye(2,4),sparse(1:2,1:2,1,2,4))
%!assert(speye(4,2),sparse(1:2,1:2,1,4,2))
