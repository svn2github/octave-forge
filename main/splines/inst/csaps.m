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
## @deftypefn{Function File}{[@var{yi} @var{p}] =} csaps(@var{x}, @var{y}, @var{p}, @var{xi}, @var{w}=[])
## @deftypefnx{Function File}{[@var{pp} @var{p}] =} csaps(@var{x}, @var{y}, @var{p}, [], @var{w}=[])
##
## Cubic spline approximation (smoothing)@*
## approximate [@var{x},@var{y}], weighted by @var{w} (inverse variance; if not given, equal weighting is assumed), at @var{xi}
##
## The chosen cubic spline with natural boundary conditions @var{pp}(@var{x}) minimizes @var{p} Sum_i @var{w}_i*(@var{y}_i - @var{pp}(@var{x}_i))^2  +  (1-@var{p}) Int @var{pp}''(@var{x}) d@var{x}  
##
## @var{x} and @var{w} should be n by 1 in size; @var{y} should be n by m; @var{xi} should be k by 1; the values in @var{x} should be distinct; the values in @var{w} should be nonzero
##
## @table @asis
## @item @var{p}=0
##       maximum smoothing: straight line
## @item @var{p}=1
##       no smoothing: interpolation
## @item @var{p}<0 or not given
##       an intermediate amount of smoothing is chosen (the smoothing term and the interpolation term are scaled to be of the same magnitude)
## @end table
##
## @end deftypefn
## @seealso{spline, csapi, ppval, gcvspl}

## Author: Nir Krakauer <nkrakauer@ccny.cuny.edu>

function [ret,p]=csaps(x,y,p,xi,w)

  if(nargin < 5)
    w = [];
    if(nargin < 4)
      xi = [];
      if(nargin < 3)
	p = [];
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

  h = diff(x);

  R = spdiags([h(1:end-1) 2*(h(1:end-1) + h(2:end)) h(2:end)], [-1 0 1], n-2, n-2);

  QT = spdiags([1 ./ h(1:end-1) -(1 ./ h(1:end-1) + 1 ./ h(2:end)) 1 ./ h(2:end)], [0 1 2], n-2, n);

## if not given, choose p so that trace(6*(1-p)*QT*diag(1 ./ w)*QT') = trace(pR)
  if isempty(p) || (p < 0)
  	r = 6*trace(QT*diag(1 ./ w)*QT') / trace(R);
  	p = 1 ./ (1 + r);
  endif

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

%!shared x,y
%! x = ([1:10 10.5 11.3])'; y = sin(x);

%!assert (csaps(x,y,1,x), y, 10*eps);
%!assert (csaps(x,y,1,x'), y', 10*eps);
%!assert (csaps(x',y',1,x'), y', 10*eps);
%!assert (csaps(x',y',1,x), y, 10*eps);
%!assert (csaps(x,[y 2*y],1,x)', [y 2*y], 10*eps);

