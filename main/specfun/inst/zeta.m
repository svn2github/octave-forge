# Copyright (C) 2006   Sissou   <sylvain.pelissier@gmail.com>
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

## ZETA compute the Riemann's Zeta function.


function z = zeta(t)
	if (nargin != 1)
			usage ("zeta(x)");
	endif

	if(t > 1 && imag(t) == 0)
		F= @(x) 1./(gamma(t)).*x.^(t-1)./(exp(x)-1);
		z = quad(F,0,Inf);
	else
		if(t<0 && imag(t) == 0)
			z = 2.^t.*pi.^(t-1).*sin(pi.*t./2).*gamma(1-t).*zeta(1-t);
		else 
			error("unable to handle complex arguments");
		endif
	endif
endfunction