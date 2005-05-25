## spones(s)
##   replace non-zero entries of s with 1.

## Author: Paul Kienzle
## This program is public domain
function s = spones(s)
  if issparse(s)
    [i,j,v,m,n] = spfind(s);
  else
    [i,j,v] = find(s);
    [m,n] = size(s);
  end
  s = sparse(i,j,1,m,n);
%!assert(issparse(spones([1,2;3,0])))
%!assert(spones([1,2;3,0]),sparse([1,1;1,0]))
%!assert(spones(sparse([1,2;3,0])),sparse([1,1;1,0]))
