## contourf(z,n,w)
## Plots a filled contour plot of n levels using the current
## colormap.  The width w is the width of the convolution window
## which smooths the contours.
##
## E.g.,
##     [x,y] = meshgrid(linspace(-2,2,200));
##     z = sinc(sqrt(x.^2 + y.^2)) + 0.5*randn(size(x));
##     filled_contour(z);

## This program is in the public domain

function contourf(z,n,w)
  if nargin < 3, w = 16; end
  if nargin < 2, n = 10; end
  if nargin < 1 || nargin > 3
    usage("contourf(z [, n [, w]])");
  endif

  ## generate the gradient image from the original
  M = imagesc(z);

  ## convolute the original with a gaussian if desired
  if w > 0
    [x,y] = meshgrid(2.5*linspace(-1,1,w));
    B = exp(-.5*(x.^2+y.^2));
    z = filter2(B,z,"same");
  endif

  ## find the contours
  C = colormap;
  colormap(rand(n+1,3));
  z = filter2(ones(2)/4,imagesc(z));
  M(z!=fix(z)) = 0;

  ## draw the gradient image with contours
  colormap([0,0,0; C]);
  image(flipud(M)+1);

  ## restore the colormap
  colormap(C);
endfunction
