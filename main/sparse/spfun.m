# t = spfun(f,s)
#   Compute f(s) for non-zero s, returning the result in sparse t.
function t = spfun(f,s)
   [i,j,v,m,n] = spfind(s);
   t = sparse(i,j,feval(f,v),m,n);
