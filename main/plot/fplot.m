## fplot(fn,limits[,n])
##    fn is the name of a function or is an expression containing x
##    limits are the limits for the plot [xlo,xhi] or [xlo,xhi,ylo,yhi]
##    n is the number of points to use
##
## Example
##    fplot('cos',[0,2*pi])
##    fplot('[cos(x),sin(x)]',[0,2*pi])

## I grant this program to the public domain.
## Author: Paul Kienzle <pkienzle@users.sf.net>

function fplot(fn,limits,n)
  if (nargin < 3) n = 100; endif
  x = linspace(limits(1),limits(2),n)';
  if all(isalnum(fn)) 
    y = feval(fn,x);
  else 
    eval(["y=",fn,";"]); 
  endif
  if (length(limits) > 2) 
    axis(limits);
  endif
  plot(x,y,[";",fn,";"]);
endfunction
