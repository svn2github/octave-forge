## Copyright (C) 2001  Kai Habel
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
## pchip preserves the monotonicity of (x,y)
##
## @seealso{ppval, spline, csape}
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>
## Date: 9. mar 2001
## 2001-04-03 Paul Kienzle
##   * move (:) from definition of l,r to use of l,r so it works with 2.0

## S_k = a_k + b_k*x + c_k*x^2 + d_k*x^3; (spline polynom)
##
## 4 conditions:
## S_k(x_k) = y_k;
## S_k(x_k+1) = y_k+1;
## S_k'(x_k) = y_k';
## S_k'(x_k+1) = y_k+1';
##
## 22. april 2001: Hmm, something is wrong, it seems pchip doesn't 
## preserve the monotonicity, as expected. So if _you_ know how to
## do it right, please contact me. Kai

function ret = pchip (x, y, xi)

  if (nargin < 2 || nargin > 3)
    usage ("pchip (x, y, [xi])");
  endif

  x = x(:);
  n = length (x);

  if (columns(y) == n) y = y'; endif

  [ry,cy] = size (y);
  if (cy > 1)
    h = kron (diff (x), ones (1, cy));
  else
    h = diff (x);
  endif

  a = y;
  
  dy = diff (y) ./ h;
  t = diff (sign (dy)) == 0;
  l = dy(1:n - 2, :);
  r = dy(2:n - 1, :);
  b = zeros (size (y));
  s = reshape (0.5 * (l(:) + r(:)), ry - 2, cy);
  b(2:ry - 1,:) = s .* t;

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
