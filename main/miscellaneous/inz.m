##       y = inz(x) ==  x(find(x)) - Indices of Non-Zeros
##   [y,f] =        == [x(find(x)),find(x)]
##
## This function is just to save typing and improve readability, as in
##
##   foo(find(foo(:,p)),p)  vs.  inz(foo(:,p)) 

## Author:        Etienne Grossmann  <etienne@isr.ist.utl.pt>
## Last modified: October 2000

function [y,f] = inz(x)
y = x(:)(f = find(x));
## That does not seem to improve anything
#    if nargout<2,
#      y = x(find(x));
#    else
#      y = x(f = find(x));
#    end
