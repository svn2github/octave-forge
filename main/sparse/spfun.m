## t = spfun(f,s)
##   Compute f(s) for non-zero s, returning the result in sparse t.

## Author: Paul Kienzle
## This program is public domain.
function t = spfun(f,s)
  if issparse(s)
    [i,j,v,m,n] = spfind(s);
  else
    [i,j,v] = find(s);
    [m,n] = size(s);
  end
  t = sparse(i,j,feval(f,v),m,n);

%!assert(spfun('exp',[1,2;3,0]),sparse([exp(1),exp(2);exp(3),0]))
%!assert(spfun('exp',sparse([1,2;3,0])),sparse([exp(1),exp(2);exp(3),0]))
