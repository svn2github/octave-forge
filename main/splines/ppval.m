## Copyright (C) 2000 Paul Kienzle
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

## usage: yi = ppval(pp, xi)
## Evaluate piece-wise polynomial pp and points xi.  If pp.d > 1,
## the returned yi will be a matrix of size rows(xi) by pp.d, or
## its transpose if xi is a row vector.

function yi = ppval(pp, xi)
  if nargin != 2
    usage("yi = ppval(pp, xi)")
  endif
  if !isstruct(pp)
    error("ppval: expects a pp structure");
  endif
  if (isempty (xi))
    yi = [];
  else
    transposed = (rows(xi) == 1);
    [nr, nc] = size(xi);
    xi = xi(:);
    idx = lookup(pp.x(2:pp.n), xi) + 1;
    dx = xi - pp.x(idx);
    dx = dx(:,ones(1,pp.d));
    c = reshape (pp.P(:, 1), pp.n, pp.d);
    yi = c(idx, :);
    for i  = 2 : pp.k;
      c = reshape (pp.P(:, i), pp.n, pp.d);
      yi = yi .* dx + c(idx, :);
    endfor
    if (transposed)
      yi = yi.';
    endif
  endif
endfunction
