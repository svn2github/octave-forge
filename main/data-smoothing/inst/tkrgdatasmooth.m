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
##@deftypefn {Function File} {[@var{ys}, @var{lambda}] =} tkrgdatasmooth (@var{x}, @var{y})
##@deftypefnx {Function File} {[@var{ys}, @var{lambda}] =} tkrgdatasmooth (@var{x}, @var{y}, @var{o})
##@deftypefnx {Function File} {[@var{ys}, @var{lambda}] =} tkrgdatasmooth (@var{x}, @var{y}, @var{o}, @var{option}, @var{value})
##
## Smooths the @var{y} values of 1D data by Tikhonov regularization.
## The @var{x} values need not be equally spaced but they should be
## ordered (and non-overlapping). The order of the smoothing derivative
## @var{o}, can be provided (default is 2), and the option-value pair
## should be either the regularizaiton parameter "lambda" or the
## standard deviation "stdev" of the randomness in the data.  With no
## option supplied, generalized cross-validation is used to determine
## lambda.
## Reference: Anal. Chem. (2003) 75, 3631.
## @seealso{tkrgscatdatasmooth}
## @end deftypefn



function [ys, lambda] = tkrgdatasmooth (x, y, d, option, value)

  if (length(x)!=length(y))
    error("x and y must be equal length vectors")
  endif
  if ( size(x)(1)==1 )
    x = x';
  endif
  if ( size(y)(1)==1 )
    y = y';
  endif

  if (nargin < 3)
    d = 2;
  endif

  guess = 0;
  if (nargin > 3)
    if ( strcmp(option,"lambda") )
      ## if lambda provided, use it directly
      lambda = value;
    elseif ( strcmp(option,"stdev") )
      ## if stdev is provided, scale it and use it
      stdev = value;
      opt = optimset("TolFun",1e-6,"MaxFunEvals",20);
      log10lambda = fminunc ("tkrgdatasmddwrap", guess, opt, x, y, d, "stdev", stdev);
      lambda = 10^log10lambda;
    else
      warning("option #s is not recognized; using cross-validation",option)
    endif
  else
    ## perform cross-validation
    opt = optimset("TolFun",1e-4,"MaxFunEvals",20);
    log10lambda = fminunc ("tkrgdatasmddwrap", guess, opt, x, y, d, "cve");
    lambda = 10^log10lambda;
  endif
  
  ys = tkrgdatasmdd(x, y, lambda, d);

endfunction


%!demo
%! npts = 100;
%! x = linspace(0,1,npts)';
%! x = x + 1/npts*(rand(npts,1)-0.5);
%! y = sin(10*x);
%! stdev = 1e-1;
%! y = y + stdev*randn(npts,1);
%! yp = ddmat(x,1)*y;
%! y2p = ddmat(x,2)*y;
%! d = 4;
%! [ys, lambda] = tkrgdatasmooth (x,y,d);
%! lambda
%! ysp = ddmat(x,1)*ys;  
%! ys2p = ddmat(x,2)*ys;
%! figure(1);
%! plot(x,y,'o',x,ys)
%! title("y(x)")
%! figure(2);
%! plot(x(1:end-1),[yp,ysp])
%! axis([min(x),max(x),min(ysp)-abs(min(ysp)),max(ysp)*2])
%! title("y'(x)")
%! figure(3)
%! plot(x(2:end-1),[y2p,ys2p])
%! axis([min(x),max(x),min(ys2p)-abs(min(ys2p)),max(ys2p)*2])
%! title("y''(x)")
%! %--------------------------------------------------------
%! % this demo used generalized cross-validation to determine lambda

%!demo
%! npts = 100;
%! x = linspace(0,1,npts)';
%! x = x + 1/npts*(rand(npts,1)-0.5);
%! y = sin(10*x);
%! stdev = 1e-1;
%! y = y + stdev*randn(npts,1);
%! yp = ddmat(x,1)*y;
%! y2p = ddmat(x,2)*y;
%! d = 4;
%! [ys, lambda] = tkrgdatasmooth (x,y,d,"stdev",stdev);
%! lambda
%! ysp = ddmat(x,1)*ys;  
%! ys2p = ddmat(x,2)*ys;
%! figure(1);
%! plot(x,y,'o',x,ys)
%! title("y(x)")
%! figure(2);
%! plot(x(1:end-1),[yp,ysp])
%! axis([min(x),max(x),min(ysp)-abs(min(ysp)),max(ysp)*2])
%! title("y'(x)")
%! figure(3)
%! plot(x(2:end-1),[y2p,ys2p])
%! axis([min(x),max(x),min(ys2p)-abs(min(ys2p)),max(ys2p)*2])
%! title("y''(x)")
%! %--------------------------------------------------------
%! % this demo used standard deviation to determine lambda

%!demo
%! npts = 100;
%! x = linspace(0,1,npts)';
%! x = x + 1/npts*(rand(npts,1)-0.5);
%! y = sin(10*x);
%! stdev = 1e-1;
%! y = y + stdev*randn(npts,1);
%! yp = ddmat(x,1)*y;
%! y2p = ddmat(x,2)*y;
%! d = 4;
%! [ys, lambda] = tkrgdatasmooth (x,y,d,"lambda",100);
%! lambda
%! ysp = ddmat(x,1)*ys;  
%! ys2p = ddmat(x,2)*ys;
%! figure(1);
%! plot(x,y,'o',x,ys)
%! title("y(x)")
%! figure(2);
%! plot(x(1:end-1),[yp,ysp])
%! axis([min(x),max(x),min(ysp)-abs(min(ysp)),max(ysp)*2])
%! title("y'(x)")
%! figure(3)
%! plot(x(2:end-1),[y2p,ys2p])
%! axis([min(x),max(x),min(ys2p)-abs(min(ys2p)),max(ys2p)*2])
%! title("y''(x)")
%! %--------------------------------------------------------
%! % this demo used a user specified lambda that was too large
