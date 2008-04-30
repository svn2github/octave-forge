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
##@deftypefn {Function File} {@var{ys} =} tkrgdatasmdd (@var{x}, @var{y}, @var{lambda})
##@deftypefnx {Function File} {@var{ys} =} tkrgdatasmdd (@var{x}, @var{y}, @var{lambda}, @var{o})
##@deftypefnx {Funciton File} {[@var{ys}, @var{v}]} = tkrgdatasmdd (...)
##
## Smooths the @var{y} vs. @var{x} data values by Tikhonov
## regularization and divided differences (arbitrary spacing of
## @var{x}). Although this function can be used directly, the more
## feature rich function "tkrgdatasmooth" should be used instead
## @itemize @w
## @item Input:
## @itemize @w
##   @item @var{x}:      data series of sampling positions (must be increasing)
##   @item @var{y}:      data series, assumed to be sampled at equal intervals
##   @item @var{lambda}: smoothing parameter; large lambda gives smoother result
##   @item @var{o}:      order of smoothing derivative
##  @end itemize
## @item Output:
##  @itemize @w
##   @item @var{ys}:     smoothed data
##   @item @var{v}:      generalized cross-validation variance
## @end itemize
## @end itemize
##
## References:  Anal. Chem. (2003) 75, 3631; AIChE J. (2006) 52, 325
## @seealso{tkrgdatasmooth, tkrgdatasmscat}
##@end deftypefn

## Addapted with permission from 'whitsmdd', Paul Eilers, 2003



function [ys, v] = tkrgdatasmdd(x, y, lambda, d)
  
  ## Defaults if not provided
  if nargin <= 3
    d = 2;
  endif

  ## find the average dx in order to scale lambda
  L = x(end) - x(1);
  N = length(x);
  dx = L/(N-1);
  
  ## form the matrices
  ## D is the derivative matrix
  D = ddmat(x,d);

  ## B and Btilda are total integration matrices
  Bhat = spdiag(-ones(N-1,1),-1) + spdiag(ones(N-1,1),1);
  Bhat(1,1) = -1;
  Bhat(N,N) = 1;
  B = 1/2*spdiag(Bhat*x);
  ##B = 1/dx*speye(N,N);  # force equal waiting, even for variable spaced x?
  if ( floor(d/2) == d/2 ) # test if d is even
    dh = d/2;
    Btilda = B(dh+1:N-dh,dh+1:N-dh);
  else # d is odd
    dh = ceil(d/2);
    Btilda = B(dh:N-dh,dh:N-dh);
  endif

  ## Smoothing
  delta = sqrt(trace(D'*D)); # a suitable invariant of D for scaling lambda
  ##f = (B + lambda*D'*Btilda*D) \ B*y;
  C = chol(B + lambda*delta^(-1)*D'*Btilda*D);
  ys = C \ (C' \ B*y);
  
  ## Computation of hat diagonal and cross-validation
  if (nargout > 1)
    ## from AIChE J. (2006) 52, 325
    ##H = (B + lambda*D'*Btilda*D) \ B;
    H = C \ (C' \ B);
    ## note: this is variance, squared of the standard error that Eilers uses
    v = (y - ys)'*B*(y - ys) / (1 - trace(H)/N)^2;
  endif
  
endfunction
