##       y = nze(x) ==  x(find(x)) - Non-Zero Elements
##   [y,f] =        == [x(find(x)),find(x)]
##
## This function is just to save typing and improve readability, as in
##
##   foo(find(foo(:,p)),p)  vs.  nze(foo(:,p)) 

## Author:        Etienne Grossmann <etienne@cs.uky.edu>
## Last modified: November 2002

function [y,f] = nze(x)
[f,j,y] = find(x(:));
