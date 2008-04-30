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
##@deftypefn {Function File} {[@var{x}, @var{y}, @var{lambda}] =} tkrgscatdatasmooth (@var{xm}, @var{ym})
##@deftypefnx {Function File} {[@var{x}, @var{y}, @var{lambda}] =} tkrgscatdatasmooth (@var{xm}, @var{ym}, @var{n}, @var{o})
##@deftypefnx {Function File} {[@var{x}, @var{y}, @var{lambda}] =} tkrgscatdatasmooth (@var{xm}, @var{ym}, @var{n}, @var{o}, @var{range})
##@deftypefnx {Function File} {[@var{x}, @var{y}, @var{lambda}] =} tkrgscatdatasmooth (@var{xm}, @var{ym}, @var{n}, @var{o}, @var{range}, @var{option}, @var{value})
##
## Determines a smooth curve that approximates the scattered (@var{xm}, @var{ym})
## data values by Tikhonov regularization.  The number of points @var{n} for
## the smooth curve and the order of the smoothing derivative @var{o} can be
## provided (defaults are 100 and 2 respectively).  Additionally, the
## desired output range for @var{x}, in the form ([min,max]), can be given; if the provided
## range does not completely span the range of the data, the range
## defaults to the min and max of the data.  The option-value pair
## should be either the regularizaiton parameter "lambda" or the
## standard deviation "stdev" of the randomness in the data.  With no
## option supplied, generalized cross-validation is used to determine
## lambda.
##
## Reference: Anal. Chem. (2003) 75, 3631.
## @seealso{datasmooth}
##@end deftypefn


function [x, y, lambda] = tkrgscatdatasmooth (xm, ym, N, d, range, option, value)

  if (length(xm)!=length(ym))
    error("xm and ym must be equal length vectors")
  endif
  if ( size(xm)(1)==1 )
    xm = xm';
  endif
  if ( size(ym)(1)==1 )
    ym = ym';
  endif

  if (nargin < 3)
    N = 100;
    d = 2;
  endif
  if (nargin < 5)
    range = [min(xm),max(xm)]
  endif
    

  guess = 0;
  if (nargin > 5)
    if ( strcmp(option,"lambda") )
      ## if lambda provided, use it directly
      lambda = value;
    elseif ( strcmp(option,"stdev") )
      ## if stdev is provided, scale it and use it
      stdev = value;
      opt = optimset("TolFun",1e-6,"MaxFunEvals",20);
      log10lambda = fminunc ("tkrgdatasmscatwrap", guess, opt, xm, ym, N, d, range, "stdev", stdev);
      lambda = 10^log10lambda;
    else
      warning("option #s is not recognized; using cross-validation",option)
    endif
  else
    ## otherwise, perform cross-validation
    opt = optimset("TolFun",1e-4,"MaxFunEvals",20);
    log10lambda = fminunc ("tkrgdatasmscatwrap", guess, opt, xm, ym, N, d, range, "cve");
    lambda = 10^log10lambda;
  endif
  
  [x,y] = tkrgdatasmscat (xm, ym, lambda, N, d, range);

endfunction


%!demo
%! npts = 80;
%! xm = linspace(0,1,npts)';
%! stdev = 1e-1;
%! xm = xm + stdev*randn(npts,1);
%! ym = sin(10*xm);
%! ym = ym + stdev*randn(npts,1);
%! ymp = ddmat(xm,1)*ym;
%! ym2p = ddmat(xm,2)*ym;
%! [x, y, lambda] = tkrgscatdatasmooth (xm,ym,500,4,[-0.15,1.15]);
%! lambda
%! yp = ddmat(x,1)*y;  
%! y2p = ddmat(x,2)*y;
%! figure(1);
%! plot(xm,ym,'o',x,y)
%! title("y(x)")
%! figure(2);
%! plot(xm(1:end-1),ymp,'o',x(1:end-1),yp)
%! axis([min(x),max(x),min(yp)-abs(min(yp)),max(yp)*2])
%! title("y'(x)")
%! figure(3)
%! plot(xm(2:end-1),ym2p,'o',x(2:end-1),y2p)
%! axis([min(x),max(x),min(y2p)-abs(min(y2p)),max(y2p)*2])
%! title("y''(x)")
%! %--------------------------------------------------------
%! % this demo used generalized cross-validation to determine lambda

%!demo
%! npts = 80;
%! xm = linspace(0,1,npts)';
%! stdev = 1e-1;
%! xm = xm + stdev*randn(npts,1);
%! ym = sin(10*xm);
%! ym = ym + stdev*randn(npts,1);
%! ymp = ddmat(xm,1)*ym;
%! ym2p = ddmat(xm,2)*ym;
%! [x, y, lambda] = tkrgscatdatasmooth (xm,ym,500,4,[-0.15,1.15],"stdev",stdev);
%! lambda
%! yp = ddmat(x,1)*y;  
%! y2p = ddmat(x,2)*y;
%! figure(1);
%! plot(xm,ym,'o',x,y)
%! title("y(x)")
%! figure(2);
%! plot(xm(1:end-1),ymp,'o',x(1:end-1),yp)
%! axis([min(x),max(x),min(yp)-abs(min(yp)),max(yp)*2])
%! title("y'(x)")
%! figure(3)
%! plot(xm(2:end-1),ym2p,'o',x(2:end-1),y2p)
%! axis([min(x),max(x),min(y2p)-abs(min(y2p)),max(y2p)*2])
%! title("y''(x)")
%! %--------------------------------------------------------
%! % this demo used standard deviation to determine lambda

%!demo
%! npts = 80;
%! xm = linspace(0,1,npts)';
%! stdev = 1e-1;
%! xm = xm + stdev*randn(npts,1);
%! ym = sin(10*xm);
%! ym = ym + stdev*randn(npts,1);
%! ymp = ddmat(xm,1)*ym;
%! ym2p = ddmat(xm,2)*ym;
%! [x, y, lambda] = tkrgscatdatasmooth (xm,ym,500,4,[-0.15,1.15],"lambda",10000);
%! lambda
%! yp = ddmat(x,1)*y;  
%! y2p = ddmat(x,2)*y;
%! figure(1);
%! plot(xm,ym,'o',x,y)
%! title("y(x)")
%! figure(2);
%! plot(xm(1:end-1),ymp,'o',x(1:end-1),yp)
%! axis([min(x),max(x),min(yp)-abs(min(yp)),max(yp)*2])
%! title("y'(x)")
%! figure(3)
%! plot(xm(2:end-1),ym2p,'o',x(2:end-1),y2p)
%! axis([min(x),max(x),min(y2p)-abs(min(y2p)),max(y2p)*2])
%! title("y''(x)")
%! %--------------------------------------------------------
%! % this demo used a user specified lambda that was too large
