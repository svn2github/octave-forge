## r = fnval(pp,x) or r = fnval(x,pp)
## Compute the value of the piece-wise polynomial pp at points x.

## This program is public domain.
## Paul Kienzle, 2004-02-22
function r = fnval(a,b,left)
  if nargin == 2 || (nargin == 3 && left == 'l' && left == 'r')
    # XXX FIXME XXX ignoring left continuous vs. right continuous option
    if isstruct(a), r=ppval(a,b); else r=ppval(b,a); end
  else
    usage("r=fnval(pp,x) || r=fnval(x,pp)");
  end
end

