## t = nonzeros(s)
##   return vector of nonzeros of s
function t = nonzeros(s)
  [i,j,t] = spfind(s)
