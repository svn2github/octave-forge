## Copyright (C) 2006   Sissou   <sylvain.pelissier@gmail.com>
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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

##SI compute the sine integral function define by:
##
##                    x
##                   /
##           Si(x) = | sin(t)/t dt
##                   /
##                   0
##

function y = Si(x)
	if (nargin != 1)
		usage ("Si(x)");
	endif
	y = zeros(size(x));
 	if prod(size(x)) < 101
  		for k = 1:prod(size(x))
   		y(k) = sum(besselj([0:100]+0.5,(x(k)/2)).^2);
  		endfor
		y = y.*pi;
 	else
  		for k=0:100
   		y += besselj(k+0.5,x/2).^2;
  		endfor
		y = y.*pi;
 	endif 
endfunction;