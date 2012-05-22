## Copyright (C) 2012 Benjamin Lewis <benjf5@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 2 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

function coeff = nuwaveletcoeff( X , Y , t , o , wgt = cubicwgt , wgtrad = 1 )
  so = 0.05 .* o;
  mask = abs( X - t ) * so < wgtrad;
  mask = mask .* [ 1 : length(mask) ];
  rx = X(mask);
  ## This was the fastest way to extract a matching subset that I could think of, but it has a complexity O(2n).
  ry = Y(mask);
  ## Going by the R code, this can use the same mask.
  s = sum( wgt( ( X - t ) .* so ) );
  coeff = ifelse( s != 0 , sum( wgt( ( rx - t ) .* so) .* exp( i .* o .* ( rx - t ) ) .* ry ) ./ s , 0 );
  
endfunction