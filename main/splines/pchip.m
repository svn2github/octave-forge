## Copyright (C) 2001,2002  Kai Habel
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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{pp} = } pchip (@var{x}, @var{y})
## @deftypefnx {Function File} {@var{yi} = } pchip (@var{x}, @var{y}, @var{xi})
## piecewise cubic hermite interpolating polynom.
## @var{x} must be a vector of increasing values.
## @var{y} is a vector of same length as @var{x},
## or a matrix where the number of columns must match the length
## of @var{x}. In this case the interpolating polynoms are calculated
## for each column. 
## In contrast to spline preserves pchip the monotonicity of (@var{x},@var{y}).
## 
## @seealso{ppval, spline, csape}
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>
## Date: 9. mar 2001
## 2001-04-03 Paul Kienzle
##   * move (:) from definition of l,r to use of l,r so it works with 2.0
##
## S_k = a_k + b_k*x + c_k*x^2 + d_k*x^3; (spline polynom)
##
## 4 conditions:
## S_k(x_k) = y_k;
## S_k(x_k+1) = y_k+1;
## S_k'(x_k) = y_k';
## S_k'(x_k+1) = y_k+1';

function ret = pchip (x, y, xi)

  if (nargin < 2 || nargin > 3)
    usage ("pchip (x, y, [xi])");
  endif

  x = x(:);
  n = length (x);

  if any(diff(x)<0) 
    error('x must be increasing')
  endif

  if (columns(y) == n) y = y'; endif
  
  if (rows(y) != n)
    error("size of x and y must match");
  endif

  [ry,cy] = size (y);
  if (cy > 1)
    h = kron (diff (x), ones (1, cy));
  else
    h = diff (x);
  endif
  
  dy = diff (y) ./ h;

  a = y;
  b = pchip_deriv(x,y);
  c = - (b(2:n, :) + 2 * b(1:n - 1, :)) ./ h + 3 * diff (a) ./ h .^ 2;
  d = (b(1:n - 1, :) + b(2:n, :)) ./ h.^2 - 2 * diff (a) ./ h.^3;

  d = d(1:n - 1, :); c = c(1:n - 1, :);
  b = b(1:n - 1, :); a = a(1:n - 1, :);
  coeffs = [d(:), c(:), b(:), a(:)];
  pp = mkpp (x, coeffs);

  if (nargin == 2)
    ret = pp;
  else
    ret = ppval(pp,xi);
  endif

endfunction
