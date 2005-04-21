## Generate a function with lots of local maxima and minima.
##
## f(x,y) = 3*(1-x)^2*exp(-x^2 - (y+1)^2) ...
##          - 10*(x/5 - x^3 - y^5)*exp(-x^2-y^2) ...
##          - 1/3*exp(-(x+1)^2 - y^2)
##
## peaks                plot a 49x49 mesh over the range [-3,3]
## peaks(n)             plot an nxn mesh over the range [-3,3]
## peaks(v)             plot over [X,Y]=meshgrid(v,v)
## peaks(x,y)           plot over [X,Y]=meshgrid(x,y)
## Z = peaks(...)       return Z instead of plotting
## [X,Y,Z] = peaks(...) return X,Y,Z instead of plotting

## This program is public domain

## Expression for peaks function was taken from the following paper:
##   http://www.control.hut.fi/Kurssit/AS-74.115/Material/GENALGgoga.pdf
function [X_out,Y_out,Z_out] = peaks(x,y)

  if nargin == 0
    x = y = linspace(-3,3,49);
  elseif nargin == 1
    if length(x) > 1
      y = x;
    else
      x = y = linspace(-3,3,x);
    endif
  endif


  [X,Y] = meshgrid(x,y);
  Z = 3*(1-X).^2.*exp(-X.^2 - (Y+1).^2) \
      - 10*(X/5 - X.^3 - Y.^5).*exp(-X.^2-Y.^2) \
      - 1/3*exp(-(X+1).^2 - Y.^2);

  if nargout == 0
    mesh(x,y,Z);
  elseif nargout == 1
    X_out = Z;
  else
    X_out = X;
    Y_out = Y;
    Z_out = Z;
  endif

endfunction

