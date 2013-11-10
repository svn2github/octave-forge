## Copyright (C) 2007-2013 Andreas Stahel <Andreas.Stahel@bfh.ch>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## general linear regression
##
## [p,e_var,r,p_var,y_var] = LinearRegression(F,y)
## [p,e_var,r,p_var,y_var] = LinearRegression(F,y,weight)
##
## determine the parameters p_j  (j=1,2,...,m) such that the function
## f(x) = sum_(i=1,...,m) p_j*f_j(x) fits as good as possible to the 
## given values y_i = f(x_i)
##
## parameters
## F  n*m matrix with the values of the basis functions at the support points 
##    in column j give the values of f_j at the points x_i  (i=1,2,...,n)
## y  n column vector of given values
## weight  n column vector of given weights of data points
##
## return values
## p     m vector with the estimated values of the parameters
## e_var estimated variance of the difference between fitted and
##       measured values
## r     weighted norm of residual
## p_var estimated variance of the parameters p_j
## y_var estimated variance of the dependend variables
##       do NOT request y_var for large data sets, as a n by n matrix is generated

function [p,e_var,r,p_var,y_var] = LinearRegression (F,y,weight)

  if (nargin < 2 || nargin >= 4)
    usage ('wrong number of arguments in [p,e_var,r,p_var,y_var] = LinearRegression(F,y)');
  endif

  [rF, cF] = size (F);
  [ry, cy] = size (y);
  
  if (rF != ry || cy > 1)
    error ('LinearRegression: incorrect matrix dimensions');
  endif

  if (nargin == 2)  % set uniform weights if not provided
    weight = ones (size (y));
  endif

  wF = diag (weight) * F;  % this now efficent with the diagonal matrix
  %wF = F;
  %for j = 1:cF
  %  wF(:,j) = weight.*F(:,j);
  %end

  [Q,R] = qr (wF,0);                     % estimate the values of the parameters
  p     = R \ (Q' * (weight.*y));

  # Compute the residual vector and its weighted norm
  residual = F * p - y;
  r        = norm (weight .* residual);
  # Variance of the weighted residuals
  e_var    = sum ((residual.^2) .* (weight.^4)) / (rF-cF);  

  # Compute variance of parameters, only if requested
  if nargout > 3

    M = inv (R) * Q' * diag(weight);

    # compute variance of the dependent variable, only if requested
    if nargout > 4  
     %% WARNING the nonsparse matrix M2 is of size rF by rF, rF = number of data points
      M2    = F * M;
      M2    = M2 .* M2;   % square each entry in the matrix M2
      y_var = e_var ./ (weight.^4) + M2 * (e_var./(weight.^4));  % variance of y values
    endif
    
    M     = M .* M;                  % square each entry in the matrix M
    p_var = M * (e_var./(weight.^4));  % variance of the parameters
    
  endif

endfunction

%!demo
%! n = 100;
%! x = sort(rand(n,1)*5-1);
%! y = 1+0.05*x + 0.1*randn(size(x));
%! F = [ones(n,1),x(:)];
%! [p,e_var,r,p_var,y_var] = LinearRegression(F,y);
%! yFit = F*p;
%! figure()
%! plot(x,y,'+b',x,yFit,'-g',x,yFit+1.96*sqrt(y_var),'--r',x,yFit-1.96*sqrt(y_var),'--r')
%! title('straight line by linear regression')
%! legend('data','fit','+/-95%')
%! grid on

%!demo
%! n = 100;
%! x = sort(rand(n,1)*5-1);
%! y = 1+0.5*sin(x) + 0.1*randn(size(x));
%! F = [ones(n,1),sin(x(:))];
%! [p,e_var,r,p_var,y_var] = LinearRegression(F,y);
%! yFit = F*p;
%! figure()
%! plot(x,y,'+b',x,yFit,'-g',x,yFit+1.96*sqrt(y_var),'--r',x,yFit-1.96*sqrt(y_var),'--r')
%! title('y = p1 + p2*sin(x) by linear regression')
%! legend('data','fit','+/-95%')
%! grid on

