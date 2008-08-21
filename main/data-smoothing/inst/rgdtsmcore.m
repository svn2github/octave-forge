## Copyright (C) 2008 Jonathan Stickel
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>. 

## -*- texinfo -*-
##@deftypefn {Function File} {[@var{xhat}, @var{yhat}] =} rgdtsmcore (@var{x}, @var{y}, @var{d}, @var{lambda}, [@var{options}])
##
## Smooths @var{y} vs. @var{x} values by Tikhonov regularization.
## Although this function can be used directly, the more feature rich
## function "regdatasmooth" should be used instead.  In addition to
## @var{x} and @var{y}, required input includes the smoothing derivative
## @var{d} and the regularization parameter @var{lambda}.  The smooth
## curve is returned as @var{xhat}, @var{yhat}.  The generalized cross
## validation variance @var{v} may also be returned.
##
## Currently supported input options are (multiple options are allowed):
##
##@table @code
## @item "gridx"
##  use an equally spaced @var{xhat} vector for the smooth curve rather
##  than @var{x}; this option is implied if either the "Nhat" or "range"
##  options are used
## @item "Nhat", @var{value}
##  number of equally spaced smoothed points (default = 100)
## @item "range", @var{value}
##  two element vector [min,max] giving the desired output range of
##  @var{xhat}; if not provided or if the provided range is less than
##  the range of the data, the default is the min and max of @var{x}
## @item "relative"
##  use relative differences for the goodnes of fit term
## @item "midpointrule"
##  use the midpoint rule for the integration terms rather than a direct sum
##@end table
##
## References:  Anal. Chem. (2003) 75, 3631; AIChE J. (2006) 52, 325
##@end deftypefn


function [xhat, yhat, v] = rgdtsmcore (x, y, d, lambda, varargin)

  ## options:  gridx, Nhat, range, relative, midpointrule
  ## add an option to allow an arbitrary, monotonic xhat to be provided?
  ## Defaults if not provided
  Nhat = 100;
  range = [min(x),max(x)];
  gridx = 0;
  relative = 0;
  midpr = 0;
  
  ## this is a hack to allow passing varargin from another function...
  ## is there a better way?
  if length(varargin)
    if iscell(varargin{1})
      varargin = varargin{1};
    endif
  endif
  ## parse the provided options
  if ( length(varargin) )
    for i = 1:length(varargin)
      arg = varargin{i};
      if ischar(arg)
	switch arg
	  case "gridx"
	    gridx = 1;
	  case "Nhat"
	    gridx = 1;
	    Nhat = varargin{i+1};
	  case "range"
	    gridx = 1;
	    range = varargin{i+1};
	  case "relative"
	    relative = 1;
	  case "midpointrule"
	    midpr = 1;
	  otherwise
	    printf("Option '%s' is not implemented;\n", arg)
	endswitch
      endif
    endfor
  endif
  if (gridx & midpr)
    warning("midpointrule is not used if mapping to regular spaced x")
    midpr = 0;
  endif
  
  N = length(x);
  
  ## construct xhat, M, D
  if (gridx)
    xmin = min(range(1),min(x));
    xmax = max(range(2),max(x));
    dx = (xmax-xmin)/(Nhat-1);
    xhat = (xmin:dx:xmax)';
    ## M is the mapping matrix yhat -> y
    M = speye(Nhat);
    idx = round((x - xmin) / dx) + 1;
    M = M(idx,:);
    ## note: this D does not include dx^(-d), but scaled by delta below
    D = diff(speye(Nhat),d);
  else
    Nhat = N;
    xhat = x;
    M = speye(N);
    D = ddmat(x,d);
  endif

  ## construct "weighting" matrices W and U
  ## use relative differences
  if (relative)
    Yinv = spdiag(1./y);
    W = Yinv^2;
  else
    W = speye(N);
  endif
  ## use midpoint rule integration (rather than simple sums)
  if (midpr)
    Bhat = spdiag(-ones(N-1,1),-1) + spdiag(ones(N-1,1),1);
    Bhat(1,1) = -1;
    Bhat(N,N) = 1;
    B = 1/2*spdiag(Bhat*x);
    if ( floor(d/2) == d/2 ) # test if d is even
      dh = d/2;
      Btilda = B(dh+1:N-dh,dh+1:N-dh);
    else # d is odd
      dh = ceil(d/2);
      Btilda = B(dh:N-dh,dh:N-dh);
    endif
    W = W*B;
    U = Btilda;
  else
    ## W = W*speye(Nhat);
    U = speye(Nhat-d);
  endif
  
  ## Smoothing
  delta = trace(D'*D)/Nhat^(2+d);  # using "relative" affects this!
  ##yhat = (M'*W*M + lambda*D'*U*D) \ M'*W*y;
  C = chol(M'*W*M + lambda*delta^(-1)*D'*U*D);
  yhat = C \ (C' \ M'*W*y);
  
  ## Computation of hat diagonal and cross-validation
  if (nargout > 2)
    ## from AIChE J. (2006) 52, 325
    H = M * ( C \ (C' \ M'*W) );
    ## note: this is variance, squared of the standard error that Eilers uses
    v = (M*yhat - y)'*(M*yhat - y)/N / (1 - trace(H)/N)^2;
  endif
  
endfunction
