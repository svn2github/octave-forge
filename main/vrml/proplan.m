##       x = proplan(x,d,v=1)
##
## orthogonally project x to the affine plane d*x == v

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: Setembro 2002

function x = proplan(x,d,v)

if exist("v")!=1, v = 1 ;end

d = d(:) ;
N = prod(size(d)) ;		# Assume x is NxP

v = v/norm(d);
d = d/norm(d);

p = (v*d)*ones(1,size(x,2));

x -= d*d'*(x-p) ;
# x = p + (eye(N)-d*d')*(x-p) ;
