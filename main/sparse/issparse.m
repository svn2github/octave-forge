## issparse(m)
##   returns true if m is a sparse matrix
function flag = issparse(m)
   if (nargin == 0) usage("issparse(m)"); end
   flag = is_sparse(m);
end
