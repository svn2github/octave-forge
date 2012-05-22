## Copyright (C) 2012 Benjamin Lewis  <benjf5@gmail.com>
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

## nucorrcoeff, computes a coefficient of the wavelet correlation of two time series

function coeff = nucorrcoeff(X1, Y1, X2, Y2, t, o, wgt = cubicwgt, wgtrad = 1)
  so = 0.05 * o;
  ## The first solution that comes to mind is admittedly slightly ugly and has a data footprint of O(2n)
  ## but it is vectorised. 
  mask = ( abs( X1 - t ) * so ) < wgtrad;
  mask = mask .* [ 1 : length(mask) ];
  rx1 = X1(mask); ## I've kept the variable names from the R function here
  ry1 = Y1(mask); ## Needs to have a noisy error if length(Y1) != length(X1) -- add this!
  mask = ( abs( X2 - t ) * so ) < wgtrad;
  mask = mask .* [ 1 : length(mask) ];
  rx2 = X2(mask);
  ry2 = Y2(mask);
  ## I've used the same mask for all of these as it's an otherwise unimportant variable ... can this leak memory?
  length(rx1) ##printing this length is probably used as a warning if 0 is returned; I inculded it
  ## in particular to maintain an exact duplicate of the R function.
  s = sum( wgt( ( rx1 - t ) .* so ) ) * sum( wgt( ( rx2 - t ) .* so );
  coeff = ifelse( s != 0 , ( sum( wgt( ( rx1 - t ) .* so ) .* exp( i .* o .* rx1 ) .* ry1 )
		 * sum( wgt( ( rx2 - t ) .* so ) .* exp( i .* o .* rx2 ) .* ry2 ) ) / s, 0 );


endfunction