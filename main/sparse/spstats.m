# [count, mean, var]  = spstats(S)
# 
# Return the stats for the non-zero elements of the sparse matrix S.
# count is the number of non-zeros in each column
# mean is the mean of the non-zeros in each column
# var is the variance of the non-zeros in each column
#
# ... = spstats(x,j)
#
# If x is the data and j is the bin number for the data, compute the
# stats for each bin.  In this case, bins can contain data values of
# zero, whereas with spstats(S) the zeros may disappear.  [They don't
# disappear in the current version of sparse, but that may be a bug.]

# This program is public domain.

# Author: Paul Kienzle <pkienzle@users.sf.net>

function [count,mean,var] = spstats(S,j)
  if nargin < 1 || nargin > 2
    usage("[count, mean, var] = spstats(S)  OR  spstats(x,j)");
  endif

  if nargin == 1
    [i,j,v] = spfind(S);
  else
    v = S;    
    i = [1:length(v)];
    S = sparse(i,j,v);
  endif 

  count = spsum(sparse(i,j,1));
  if (nargout > 1) 
    mean = spsum(S) ./ count; 
  end
  if (nargout > 2) 
    diff = S - sparse(i,j,mean(j)); 
    var = spsum ( diff .* diff ) ./ (count - 1);
  end
end

%!test
%! [n,m,v] = spstats([1 2 1 2 3 4],[2 2 1 1 1 1]);
%! assert(n,[4,2]);
%! assert(m,[10/4,3/2],10*eps);
%! assert(v,[5/3,1/2],10*eps);

