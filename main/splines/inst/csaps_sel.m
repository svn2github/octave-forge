## Copyright (C) 2012 Nir Krakauer
##
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
## @deftypefn{Function File}{[@var{yi} @var{p} @var{sigma2},@var{unc_y}] =} csaps_sel(@var{x}, @var{y}, @var{xi}, @var{w}=[], @var{crit}=[])
## @deftypefnx{Function File}{[@var{pp} @var{p} @var{sigma2},@var{unc_y}] =} csaps_sel(@var{x}, @var{y}, [], @var{w}=[], @var{crit}=[])
##
## Cubic spline approximation with smoothing parameter estimation @*
## approximate [@var{x},@var{y}], weighted by @var{w} (inverse variance; if not given, equal weighting is assumed), at @var{xi}.
##
## The chosen cubic spline with natural boundary conditions @var{pp}(@var{x}) minimizes @var{p} Sum_i @var{w}_i*(@var{y}_i - @var{pp}(@var{x}_i))^2  +  (1-@var{p}) Int @var{pp}''(@var{x}) d@var{x}.
## A selection criterion @var{crit} is used to find a suitable value for @var{p} (between 0 and 1); possible values for @var{crit} are `aicc' (corrected Akaike information criterion, the default); `aic' (original Akaike information criterion); `gcv' (generalized cross validation)  
##
## @var{x} and @var{w} should be @var{n} by 1 in size; @var{y} should be @var{n} by @var{m}; @var{xi} should be @var{k} by 1; the values in @var{x} should be distinct; the values in @var{w} should be nonzero.
##
## returns the selected @var{p}, the estimated data scatter (variance from the smooth trend) @var{sigma2}, and the estimated uncertainty (SD) of the smoothing spline fit at each @var{x} value, @var{unc_y}.
##
## Note: The current evaluation of the effective number of model parameters uses singular value decomposition of an @var{n} by @var{n} matrix and is not computation or storage efficient for large @var{n} (thousands or greater). See Hutchinson (1985) for a more efficient method.
##
## References: 
##
## Carl de Boor (1978), A Practical Guide to Splines, Springer, Chapter XIV
##
## Clifford M. Hurvich, Jeffrey S. Simonoff, Chih-Ling Tsai (1998), Smoothing parameter selection in nonparametric regression using an improved Akaike information criterion, J. Royal Statistical Society, 60B:271-293
##
## M. F. Hutchinson and F. R. de Hoog (1985), Smoothing noisy data with spline functions, Numerische Mathematik, 47:99-106
##
## M. F. Hutchinson (1986), Algorithm 642: A fast procedure for calculating minimum cross-validation cubic smoothing splines, ACM Transactions on Mathematical Software, 12:150-153
##
## Grace Wahba (1983), Bayesian ``confidence intervals'' for the cross-validated smoothing spline, J Royal Statistical Society, 45B:133-150
##
## @end deftypefn
## @seealso{csaps, spline, csapi, ppval, gcvspl}

## Author: Nir Krakauer <nkrakauer@ccny.cuny.edu>

function [ret,p,sigma2,unc_y]=csaps_sel(x,y,xi,w,crit)

  if (nargin < 5)
    crit = [];
    if(nargin < 4)
      w = [];
      if(nargin < 3)
        xi = [];
      endif
    endif
  endif

  if(columns(x) > 1)
    x = x.';
    y = y.';
    w = w.';
  endif

  [x,i] = sort(x);
  y = y(i, :);

  n = numel(x);
  
  if isempty(w)
    w = ones(n, 1);
  end

  if isempty(crit)
    crit = 'aicc';
  end  

  h = diff(x);

  R = spdiags([h(1:end-1) 2*(h(1:end-1) + h(2:end)) h(2:end)], [-1 0 1], n-2, n-2);

  QT = spdiags([1 ./ h(1:end-1) -(1 ./ h(1:end-1) + 1 ./ h(2:end)) 1 ./ h(2:end)], [0 1 2], n-2, n);
  
##determine influence matrix for different p without repeated inversion
  [U D V] = svd(diag(1 ./ sqrt(w))*QT'*sqrtm(inv(R)), 0); D = diag(D).^2;


##choose p by minimizing the penalty function
  penalty_function = @(p) penalty_compute(p, U, D, y, w, n, crit);

  p = fminbnd(penalty_function, 0, 1);



  H = influence_matrix(p, U, D, n);
  [MSR, Ht] = penalty_terms(H, y, w);
  sigma2 = MSR * (n / (n-Ht)); #estimated data error variance (wahba83)
  unc_y = sqrt(sigma2 * diag(H) ./ w); #uncertainty (SD) of fitted curve at each input x-value (hutchinson86)
  

## solve for the scaled second derivatives u and for the function values a at the knots (if p = 1, a = y) 
  u = (6*(1-p)*QT*diag(1 ./ w)*QT' + p*R) \ (QT*y);
  a = y - 6*(1-p)*diag(1 ./ w)*QT'*u;

## derivatives at all but the last knot for the piecewise cubic spline
  aa = a(1:(end-1), :);
  cc = zeros(size(y)); 
  cc(2:(n-1), :) = 6*p*u; #cc([1 n], :) = 0 [natural spline]
  dd = diff(cc) ./ h;
  cc = cc(1:(end-1), :);
  bb = diff(a) ./ h - (cc/2).*h - (dd/6).*(h.^2);

  ret = mkpp (x, cat (2, dd'(:)/6, cc'(:)/2, bb'(:), aa'(:)), size(y, 2));

  if ~isempty(xi)
    ret = ppval (ret, xi);
  endif

endfunction



function H = influence_matrix(p, U, D, n) #returns influence matrix for given p
	H = speye(n) - U * diag(D ./ (D + (p / (6*(1-p))))) * U';
endfunction	

function [MSR, Ht] = penalty_terms(H, y, w)
	MSR = mean(w .* (y - H*y) .^ 2); #mean square residual
	Ht = trace(H); #effective number of fitted parameters
endfunction

function J = aicc(MSR, Ht, n)
	J = mean(log(MSR)(:)) + 2 * (Ht + 1) / max(n - Ht - 2, 0); #hurvich98, taking the average if there are multiple data sets as in woltring86 
endfunction

function J = aic(MSR, Ht, n)
	J = mean(log(MSR)(:)) + 2 * Ht / n;
endfunction

function J = gcv(MSR, Ht, n)
	J = mean(log(MSR)(:)) - 2 * log(1 - Ht / n);
endfunction

function J = penalty_compute(p, U, D, y, w, n, crit) #evaluates a user-supplied penalty function at given p
	H = influence_matrix(p, U, D, n);
	[MSR, Ht] = penalty_terms(H, y, w);
	J = feval(crit, MSR, Ht, n);
	if ~isfinite(J)
		J = Inf;
	endif 	
endfunction


%!shared x,y,ret,p,sigma2,unc_y
%! x = [0:0.01:1]'; y = sin(x);
%! [ret,p,sigma2,unc_y]=csaps_sel(x,y,x);
%!assert (1-p, 0, 1E-6);
%!assert (sigma2, 0, 1E-10);
%!assert (ret-y, zeros(size(y)), 1E-4);
%!assert (unc_y, zeros(size(unc_y)), 1E-5);

