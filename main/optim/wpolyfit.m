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
## @deftypefn {Function File} {[@var{p}, @var{dp}] =} wpolyfit (@var{n}, @var{x}, @var{y}, @var{dy})
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
## Farebrother, RW (1988). Linear least squares computations.
## New York: Marcel Dekker, Inc.
##
## @end deftypefn


## 2002-03-25 Paul Kienzle
## * accept weight term and return error estimate.
## * use more accurate economy QR decomposition.

function [p, yf, dp] = wpolyfit (x, y, dy, n)


  if (nargin < 3 || nargin > 4)
    usage ("wpolyfit (x, y [, dy], n)");
  endif
  if (nargin < 4) 
    n = dy; 
    dy = ones(size(y));
  endif

  if (! (is_vector (x) && is_vector (y) && is_vector (dy) && \
        all(size (x) == size (y)) && all(size (x) == size (dy))))
    error ("wpolyfit: x and y must be vectors of the same size");
  endif

  if (! (is_scalar (n) && n >= 0 && ! isinf (n) && n == round (n)))
    error ("wpolyfit: n must be a nonnegative integer");
  endif

  y_is_row_vector = (rows (y) == 1);

  k = length (x);

  ## observation matrix
  ## polynomial least squares y = a + bx + cx^2 + dx^3 + ...
  A = (x(:) * ones (1, n+1)) .^ (ones (k, 1) * (0 : n));
  ## polynomial through the origin y = ax + bx^2 + cx^3 + ...
  % A = x(:) * ones(1,n) .^ (ones(k,1) * (1:n));

  ## apply weighting term, if it was given
  if (nargin > 3)
    X = A ./ (dy(:) * ones (1, columns(A)));
    b = y(:) ./ dy(:);
  else
    X = A;
    b = y(:);
  endif

  ## system solution
  [Q,R,P] = qr(X,0);
  p = R\(Q'*b); 
  p(P) = p;

  if (nargout != 1)
    ## find the predicted y values
    yf = y(:) - A*p(:);
    ## estimate sigma from the weighted data
    sigmasq = sumsq(b - X*p)/(length(b)-length(p));
    ## compute error estimate --- note that we shouldn't need the
    ## abs() in here, but the if the matrix is very ill-conditioned
    ## some of the diag entries come out negative. :-(
    dp = flipud(sqrt(sigmasq*abs(diag(inv(X'*X)))));
  endif
  p = flipud(p);
  if (!y_is_row_vector && rows (x) == 1)
    p = p';
    if (nargout > 1) dp = dp'; endif
  endif

  if nargout == 0
    if (any(dy != 1.0))
      errorbar (x, y, dy, "~;data;");
    else
      plot(x,y,";data;");
    endif
    hold on;
    xlabel('abscissa X'), ylabel('data Y'), 
    title('Least-squares Fit (with Error Bounds)');
    plot(x,polyval(p,x),"g-;p(x);",...
         x,polyval(p-sign(p).*dp,x),"c-;p+dp;",...
         x,polyval(p+sign(p).*dp,x),"c-;p-dp;")
    hold off;
    p = [p(:), dp(:)];
  endif

endfunction

