## Copyright (C) 1996, 1997 John W. Eaton
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, write to the Free
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{p}, @var{dp}] =} wpolyfit (@var{x}, @var{y}, @var{dy}, @var{n}, 'origin')
## Return the coefficients of a polynomial @var{p}(@var{x}) of degree
## @var{n} that minimizes
## @iftex
## @tex
## $$
## \sum_{i=1}^N (p(x_i) - y_i)^2
## $$
## @end tex
## @end iftex
## @ifinfo
## @code{sumsq (p(x(i)) - y(i))},
## @end ifinfo
## to best fit the data in the least squares sense.  The standard error
## on the observations @var{y} are given in @var{dy}.
##
## The polynomial coefficients are returned in a row vector if @var{x}
## and @var{y} are both row vectors; otherwise, they are returned in a
## column vector.
##
## If more than one output is requested, the second constains the
## predicted value of @var{y} for each @var{x} and the third contains 
## the standard error of the polynomial coefficients @var{p}.
##
## If no output arguments are requested, then it plots the data, the
## fitted line and polynomials defining the standard error range.
##
## If 'origin' is specified, then the fitted polynomial will go through
## the origin.
##
## To compute the predicted values of y with uncertainty use
## @example
##     y = polyval(p,x);
##     dy = sqrt(polyval(dp.^2, x.^2));
## @end example
##
## Example
## @example
##     x = linspace(0,4,20);
##     dy = (1+rand(size(x)))/2;
##     y = polyval([2,3,1],x) + dy.*randn(size(x));
##     wpolyfit(x,y,dy,2);
## @end example
##
## Note that the polynomial coefficients and uncertainties don't 
## exactly match those computed from a monte carlo simulation of 
## fits to the data.  You can see this for yourself:
## @example
##     n=1000; p=zeros(3,n);
##     for i=1:n, p(:,i)=polyfit(x,y+randn(size(y)).*dy,2); end
##     printf("%15g %15g\n", [mean(p'); std(p')]);
## @end example
##
## Farebrother, RW (1988). Linear least squares computations.
## New York: Marcel Dekker, Inc.
##
## @end deftypefn


## 2002-03-25 Paul Kienzle
## * accept weight term and return error estimate.
## * use more accurate economy QR decomposition.
## 2002-05-30 Paul Kienzle
## * go through the origin if requested
## * only return p,dp
## * tidy the output
## * remove the need for flipud(p)
## 2002-06-02 Paul Kienzle
## * oops --- removed the need for flipud(p) but didn't remove flipud(p)
## 2002-07-31 Paul Kienzle
## * prettier graph
## * add example
## * always return values as row vectors
## * don't return if values unless requested

function [p_out, dp_out] = wpolyfit (x, y, dy, n, origin)


  if (nargin < 3 || nargin > 5)
    usage ("wpolyfit (x, y [, dy], n [, 'origin'])");
  endif
  if (nargin ==3) 
    n = dy; 
    dy = [];
    origin='';
  elseif (nargin == 4)
    if isstr(n)
      origin = n;
      n = dy;
      dy = [];
    else
      origin='';
    endif
  endif

  if (length(origin) == 0)
    through_origin = 0;
  elseif strcmp(origin,'origin')
    through_origin = 1;
  else
    error ("wpolyfit: expected 'origin' but found %s", origin)
  endif

  if ! ( is_vector (x) && is_vector (y) && all(size (x) == size (y)) )
    error ("wpolyfit: x and y must be vectors of the same size");
  endif
  if !isempty(dy) && !(is_vector(dy) && all(size(y) == size(dy)))
    error ("wpolyfit: dy must be a vector the same length as y");
  endif

  if (! (is_scalar (n) && n >= 0 && ! isinf (n) && n == round (n)))
    error ("wpolyfit: n must be a nonnegative integer");
  endif

  k = length (x);

  ## observation matrix
  if through_origin
    ## polynomial through the origin y = ax + bx^2 + cx^3 + ...
    A = (x(:) * ones(1,n)) .^ (ones(k,1) * (n:-1:1));
  else
    ## polynomial least squares y = a + bx + cx^2 + dx^3 + ...
    A = (x(:) * ones (1, n+1)) .^ (ones (k, 1) * (n:-1:0));
  endif

  ## apply weighting term, if it was given
  if (isempty(dy))
    X = A;
    b = y(:);
  else
    X = A ./ (dy(:) * ones (1, columns(A)));
    b = y(:) ./ dy(:);
  endif

  ## system solution: X p = b => p = inv(X) b
  ## QR decomposition has good numerical properties:
  ##   XP = QR, with P'P = Q'Q = I, and R upper triangular
  ## so
  ##   inv(X) b = P inv(R) inv(Q) b = P inv(R) Q' b = P (R \ (Q' b))
  ## Note that b is usually a vector and Q is matrix, so it will
  ## be faster to compute (b' Q)' than (Q' b).
  [Q,R,P] = qr(X,0);
  p = R\(b'*Q)'; 
  p(P) = p;

  compute_dp = (nargout == 0 || nargout > 1);
  if (compute_dp)
    ## Get uncertainty from the covariance matrix: dp = sqrt(diag(inv(X'X))).
    ##
    ## Rather than calculate this directly, we are going to use the QR
    ## decomposition we have already computed:
    ##
    ##    XP = QR, with P'P = Q'Q = I, and R upper triangular
    ##
    ## Remembering that inv(AB) = inv(B)inv(A) and (AB)' = B'A', we
    ## can compute inv(X) and inv(X'):
    ##
    ##    inv(X) = inv(QRP') = inv(P')inv(R)inv(Q) = P inv(R)inv(Q)
    ##    inv(X') = inv(PR'Q') = inv(Q')inv(R')inv(P) = inv(Q')inv(R')P'
    ##
    ## Combining and simplifying:
    ##
    ##    inv(X'X) = P inv(R) inv(Q) inv(Q') inv(R') P'
    ##             = P inv(R) inv(Q'Q) inv(R') P'
    ##             = P inv(R) inv(I) inv(R') P'
    ##             = P inv(R) inv(R') P'
    ##
    ## For a permutation matrix P,
    ##
    ##    diag(PAP') = P diag(A)
    ##
    ## and for R upper triangular,
    ##
    ##    inv(R') = inv(R)'
    ##
    ## so:
    ##
    ##    diag(inv(X'X)) = P diag(inv(R) inv(R)')
    ##
    ## Conveniently, for T upper triangular
    ##
    ##    diag(TT') = sumsq(T')'
    ##
    ## so
    ##
    ##    diag(inv(X'X)) = P sumsq(inv(R)')'
    ## 
    ## This is both faster and more accurate than computing inv(X'X)
    dp = sqrt(sumsq(inv(R),2));
    dp(P) = dp;
    if isempty(dy)
      ## If we don't have an uncertainty estimate coming in, estimate it
      ## from the chisq of the fit.
      chisq = sumsq(b - X*p)/(length(y)-length(p));
      dp *= sqrt(chisq);
    endif
  endif

  if through_origin
    p(n+1) = 0;
    if (compute_dp) dp(n+1) = 0; endif
  endif

  if nargout == 0

    if iscomplex(p)
      printf("%32s %15s\n", "Coefficient", "Error");
      printf("%15g %+15gi %15g\n",[real(p(:)),imag(p(:)),dp(:)]');
      # XXX FIXME XXX how to plot complex valued functions?
      # Maybe using hue for phase and saturation for magnitude
      # e.g., Frank Farris (Santa Cruz University) has this:
      # http://www.maa.org/pubs/amm_complements/complex.html
      # Could also look at the book
      #   Visual Complex Analysis by Tristan Needham, Oxford Univ. Press
      # but for now we punt
      return
    endif

    ## decorate the graph
    grid('on');
    xlabel('abscissa X'); ylabel('data Y');
    title('Least-squares Polynomial Fit with Error Bounds');

    ## draw fit with estimated error bounds
    xf = linspace(min(x),max(x),150);
    yf = polyval(p,xf);
    dyf = sqrt(polyval(dp.^2,xf.^2));
    plot(xf,yf+dyf,"g.;;", xf,yf-dyf,"g.;;", xf,yf,"g-;fit;");

    hold on;

    ## plot the data
    if (isempty(dy))
      plot(x,y,"x;data;");
    else
      errorbar (x, y, dy, "~;data;");
    endif

    hold off;

    ## display p,dp as a two column vector
    printf("%15s %15s\n", "Coefficient", "Error");
    printf("%15g %15g\n", [p(:), dp(:)]');

  else

    ## return values as row vectors instead of printing
    p_out = p.';
    if (compute_dp) dp_out = dp.'; endif

  endif

endfunction

%!demo % #1  
%!     x = linspace(0,4,20);
%!     dy = (1+rand(size(x)))/2;
%!     y = polyval([2,3,1],x) + dy.*randn(size(x));
%!     wpolyfit(x,y,dy,2);
  
%!demo % #2
%!     x = linspace(-i,+2i,20);
%!     noise = ( randn(size(x)) + i*randn(size(x)) )/10;
%!     P = [2-i,3,1+i];
%!     y = polyval(P,x) + noise;
%!     [PEST,DELTA]=wpolyfit(x,y,2)

