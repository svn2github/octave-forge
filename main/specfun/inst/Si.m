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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## SI compute the sine integral,
##
##                x
##               /
##    Si(x) =    | sin(t)/t dt
##               /
##               0
##

function y = Si(x)
		if (nargin != 1)
			usage ("Si(x)");
	   endif
		s = size(x)(2);
		for t = 1:s
			if( x == 0)
				y = 0;
			else
				if(imag(x(t)) == 0)
					F = @(x) sin(x)./x;
					y(t) = quad(F,0,x(t));
				else
					y(t) = 0;
					for k = 0:100
						y(t) = y(t) + (besselj(k + 0.5,x(t)./2)).^2;
					endfor
					y(t) = y(t).*pi;
					if(real(x(t))==0)
						y(t)=i.*imag(y(t));
					endif
				endif
			endif
		endfor
endfunction