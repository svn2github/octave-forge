# spones(s)
#   replace non-zero entries of s with 1.
function s = spones(s)
   [i,j,v,m,n] = spfind(s);
   s = sparse(i,j,1,m,n);
