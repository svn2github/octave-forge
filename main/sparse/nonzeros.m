## t = nonzeros(s)
##   return vector of nonzeros of s

## Author: Paul Kienzle
## This program is public domain.
function t = nonzeros(s)
  if issparse(s)
    [i,j,t] = spfind(s);
  else
    [i,j,t] = find(s);
  end
%!assert(nonzeros([1,2;3,0]),[1;3;2])
%!assert(nonzeros(sparse([1,2;3,0])),[1;3;2])
