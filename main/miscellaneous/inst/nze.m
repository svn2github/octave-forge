## -*- texinfo -*-
## @deftypefn{Function File} {@var{[y,f]} = } nze ( x ) 
## @cindex  
##
## This function is just to save typing and improve readability, as in
## foo(find(foo(:,p)),p)  vs.  nze(foo(:,p)) 
##
## @example
##       y = nze(x) ==  x(find(x)) - Non-Zero Elements
##   [y,f] =        == [x(find(x)),find(x)]
## @end example
## @seealso{grep}
## @end deftypefn

## Author:        Etienne Grossmann <etienne@cs.uky.edu>
## Last modified: November 2002

function [y,f] = nze(x)
[f,j,y] = find(x(:));
