## y = nthrooth(x,n)
## Compute the nth root of x, returning real results for real components of x.

## This program is granted to the public domain.

function y = nthroot(x, m)
  if nargin != 2, usage('nthroot(x,m)'); end
  y = x.^(1./m);

  if isscalar(x), x = x*ones(size(m)); end
  if isscalar(m), m = m*ones(size(x)); end
  idx = (mod(m,2)==1 & imag(x)==0 & x<0);
  if any(idx(:)), y(idx) = -(-x(idx)).^(1./m(idx)); end


  ## If result is all real, make sure it looks real
  if all(imag(y)==0), y=real(y); end

%!assert(nthroot(-1,[3,-3]), [-1,-1],eps);
%!assert(nthroot([-1,1],[3.1,-3]), [-1,1].^(1./[3.1,-3]));
%!assert(nthroot([-1+1i,-1-1i],3), [-1+1i,-1-1i].^(1/3));
