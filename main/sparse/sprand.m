## S = sprand(m,n,d)
##
## Generate a random sparse matrix.  m and n give the dimensions, d
## gives the density (between 0 and 1).
##
## Note: this will fail for large m x n matrices, even if they
## are very sparse.
##
## S = sprand(Q)
##
## Generate a random sparse matrix with non-zero values whereever Q
## is non-zero.

## This program is public domain
## Author: Paul Kienzle <pkienzle@users.sf.net>

function S = sprand(m,n,d)
  if nargin == 1
    [i,j,v,nr,nc] = spfind(m);
    S = sparse(i,j,rand(size(v)),nr,nc);
  elseif nargin == 3
    k = round(d*m*n);
    ## XXX FIXME XXX need a better algorithm for large sparse matrices
    ## E.g., find p such that p samples out of m*n things with replacement
    ## yields on average k unique values, and use 
    ##    idx=unique(fix(rand(1,p)*m*n))+1
    [v,idx] = sort(rand(m*n,1));
    j = floor((idx(1:k)-1)/m);
    i = idx(1:k) - j*m;
    if isempty(i)
      S = sparse(m,n);
    else
      S = sparse(i,j+1,rand(k,1),m,n);
    endif
  else
    usage("sprand(m,n,density) OR sprand(S)");
  endif
endfunction
