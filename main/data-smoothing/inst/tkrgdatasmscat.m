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
##@deftypefn {Function File} {[@var{x}, @var{y}] =} tkrgdatasmscat (@var{xm}, @var{ym}, @var{lambda})
##@deftypefnx {Function File} {[@var{x}, @var{y}] =} tkrgdatasmscat (@var{xm}, @var{ym}, @var{lambda}, @var{n}, @var{o})
##@deftypefnx {Function File} {[@var{x}, @var{y}] =} tkrgdatasmscat (@var{xm}, @var{ym}, @var{lambda}, @var{n}, @var{o}, @var{range})
##@deftypefnx {Function File} {[@var{x}, @var{y}, @var{v}] =} tkrgdatasmscat (...)
##
## Smooths the data of the scattered @var{y} vs. @var{x} values by
## Tikhonov regularization.  Although this function can be used
## directly, the more feature rich function "tkrgscatdatasmooth" should
## be used instead.
## @itemize @w
## @item Input:
##  @itemize @w
##   @item @var{xm}      data series x
##   @item @var{ym}      data series y
##   @item @var{lambda} smoothing parameter
##   @item @var{n}      number of equally spaced smoothed points (default = 100)
##   @item @var{o}      order of smoothing derivative (default = 2)
##   @item @var{range}   two element vector [min,max] giving the desired output range of x; if the range is less than the data, defaults to [min,max] of the data
##  @end itemize
## @item Output:
##  @itemize @w
##   @item @var{x}     smoothed x
##   @item @var{y}     smoothed y
##   @item @var{v}     generalized cross-validation variance
## @end itemize
## @end itemize
##
## References:  Anal. Chem. (2003) 75, 3631; AIChE J. (2006) 52, 325
## @seealso{tkrgscatdatasmooth, tkrgdatasmdd}
##@end deftypefn

## Some code addapted with permission from 'whitsmscat', Paul Eilers, 2003



function [x, y, v] = tkrgdatasmscat (xm, ym, lambda, N, d, range)
  
  ## Defaults if not provided
  if (nargin <= 3)
    N = 100;
    d = 2;
  endif

  ## sort the scattered data
  [xm,idx] = sort (xm);
  ym = ym(idx);
  
  ## construct x
  Nm = length(xm);
  if (nargin > 5)
    xmin = min(range(1),xm(1));
    xmax = max(range(2),xm(end));
  else
    xmin = xm(1);
    xmax = xm(end);
  endif
  L = xmax - xmin;
  dx = L/(N-1);
  x = (xmin:dx:xmax)';

  ## Itilda is the mapping matrix y->ym
  Itilda = speye(N);
  idx = round((xm - xmin) / dx) + 1;
  Itilda = Itilda(idx,:);
  
  ## D is the derivative matrix
  ##D = ddmat(x,d);
  D = dx^(-d)*diff(speye(N),d); # equivalent but a little faster

  ## Smoothing
  delta = sqrt(trace(D'*D)); # a suitable invariant of D
  ##y = (Itilda'*Itilda + lambda*D'*D) \ Itilda'*ym;
  C = chol(Itilda'*Itilda + lambda*delta^(-1)*D'*D);
  y = C \ (C' \ Itilda'*ym);
 
  ## Computation of hat diagonal and cross-validation
  if (nargout > 2)
    ## from AIChE J. (2006) 52, 325
    H = Itilda * ( C \ (C' \ Itilda') );
    ## note: this is variance, squared of the standard error that Eilers uses
    v = (ym - Itilda*y)'*(ym - Itilda*y)/Nm / (1 - trace(H)/Nm)^2;
  endif
  
endfunction
