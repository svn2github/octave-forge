## usage [alpha,c,rms] = expfit(deg,x1,h,y)
##
## Implementation of Prony's method to perform
## non-linear exponential fitting on equidistant
## data.
##
## Fit function: \sum_1^{deg} c(i)*exp(alpha(i)*x)
##
## Data is equidistant, starts at x1 with a stepsize h
##
## Function returns linear coefficients c, non-linear
## coefficients alpha and root mean square error rms
## This method is known to be more stable than 'brute-
## force' non-linear least squares fitting.
##
## The non-linear coefficients alpha can be imaginary,
## fitting function becomes a sum of sines and cosines.
##
## Example
##    x0 = 0; step = 0.05; xend = 5; x = x0:step:xend;
##    y = 2*exp(1.3*x)-0.5*exp(2*x);
##
##    error = (rand(1,length(y))-0.5)*1e-4;
##
##    [alpha,c,rms] = expfit(2,x0,step,y+error)
##
##  alpha =
##
##    2.0000
##    1.3000
##
##  c =
##
##    -0.50000
##     2.00000
##
##    rms = 0.00028461
##
## The fitting is very sensitive to the number of data points.
## It doesn't perform very well for small data sets (theoretically,
## you need at least 2*deg data points, but if there are errors on
## the data, you certainly need more.
##
## Be aware that this is a very (very,very) ill-posed problem.
## By the way, this algorithm relies heavily on computing the roots
## of a polynomial. I used 'roots.m', if there is something better
## please use that code.
##
## Copyright (C) 2000: Gert Van den Eynde
## SCK-CEN (Nuclear Energy Research Centre)
## Boeretang 200
## 2400 Mol
## Belgium
## na.gvandeneynde@na-net.ornl.gov
##
## This code is under the Gnu Public License (GPL) version 2 or later.
## I hope that it is useful, but it is WITHOUT ANY WARRANTY;
## without even the implied warranty of MERCHANTABILITY or FITNESS
## FOR A PARTICULAR PURPOSE.


function [alpha,c,rms] = expfit(deg,x1,h,y)


% Check input

   if (deg < 1) error ('deg must be >= 1');end

   if (h <= 0) error ('Stepsize h must be > 0');end;

%if (length(y) <= 2*deg)
% error ('Number of data points must be larger than 2*deg');end;


   N = length(y);

% Solve for polynomial coeff

% Compose matrix A(i,j) = y(i+j-1)
   A1 = hankel(y(1:N-deg),y(N-deg:N-1));
   b1 = -y(deg+1:N);

% Least squares solution
   s = A1\b1;

% Compose polynomial
   p = [1,fliplr(s')];

% Compute roots
   u = roots(p);

% Compose second matrix A2(i,j) = u(j)^(i-1)
   A2 = ( ones(N,1) * u(:).' )  .^  ( [0:N-1](:) * ones(1,deg) );
   b2 = y;

% Solve linear system
   f = A2\b2;

% Decompose all
   alpha = log(u)/h;
   c = f./exp(alpha*x1);

% Compute rms of y - approx 
% where approx(i) = sum_k ( c(k) * exp(x(i)*alpha(k)) )
   x = x1+h*[0:N-1];
   approx = exp( x(:) * alpha(:).' ) * c(:);
   rms = sqrt(sumsq(approx - y));

endfunction

