## -*- texinfo -*-
## @deftypefn{Function File} [@var{y},@var{f}] = inz ( @var{x} ) 
## @cindex  
## This function is just to save typing and improve readability, as in
## foo(find(foo(:,p)),p)  vs.  inz(foo(:,p)) 
##  y = inz(x) ==  x(find(x)) - Indices of Non-Zeros
## [y,f] = [x(find(x)),find(x)]
## @seealso{grep}
## @end deftypefn

## Author:        Etienne Grossmann <etienne@cs.uky.edu>
## Last modified: October 2000

function [y,f] = inz(x)
y = x(:)(f = find(x));
## That does not seem to improve anything
#    if nargout<2,
#      y = x(find(x));
#    else
#      y = x(f = find(x));
#    end
