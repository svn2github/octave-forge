## contourf(z,n,w)
## Plots a filled contour plot of n levels using the current
## colormap.  The width w is the width of the convolution window
## which smooths the contours.
##
## E.g.,
##     [x,y] = meshgrid(linspace(-2,2,200));
##     z = sinc(sqrt(x.^2 + y.^2)) + 0.5*randn(size(x));
##     contourf(z);
##
## Note that the algorithm computes incorrect contours near the
## edges, which you can see using contourf(sinc(sqrt(x.^2+y.^2)))
## with x,y from above.

## This program is in the public domain
## Author: Paul Kienzle <pkienzle@users.sf.net>

function contourf(z,n,w)
  if nargin < 3, w = 16; end
  if nargin < 2, n = 10; end
  if nargin < 1 || nargin > 3
    usage("contourf(z [, n [, w]])");
  endif

  ## convolute the original with a gaussian if desired
  if w > 0
    [x,y] = meshgrid(2.5*linspace(-1,1,w));
    B = exp(-.5*(x.^2+y.^2));
    z = filter2(B,z,"same");
  endif

  ## find the contours
  C = colormap;
  colormap(repmat(linspace(0.5,1,n+1)',1,3));
  z = filter2(ones(2)/4,imagesc(z));
  z(z!=fix(z)) = 0;

  ## plot the image, with the contours drawn in black.
  colormap([0,0,0; C(linspace(1,rows(C),n+1),:)]);
  image(flipud(z)+1);

  ## restore the colormap
  colormap(C);
endfunction
