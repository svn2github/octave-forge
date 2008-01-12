## -*- texinfo -*-
## @deftypefn{Function File} {@var{[y,f]} = } grep ( x ) 
## @cindex  
## This function is just to save typing and improve 
## readability, as in foo(find(foo(:,p)),p) vs. grep(foo(:,p))
##
## You can use grep as follows,
## @example
## y = grep(x) = x(find(x))
## [y,f] = [x(find(x)),find(x)]
## @end example
## @seealso{find,strfind}
## @end deftypefn

## Author:        Etienne Grossmann <etienne@cs.uky.edu>
## Last modified: October 2000

function [y,f] = grep(x)
y = x(:)(f = find(x));
## That does not seem to improve anything
#    if nargout<2,
#      y = x(find(x));
#    else
#      y = x(f = find(x));
#    end
