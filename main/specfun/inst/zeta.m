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
	s = columns(t);
	for j = 1:s
		if(real(t(j)) > 0)
			if(imag(t(j)) == 0 && real(t(j)) > 1)
				F= @(x) 1./(gamma(t(j))).*x.^(t(j)-1)./(exp(x)-1);
				z(j) = quad(F,0,Inf);
			else
				z(j) = 0;
				for k = 1:100
					z(j) = z(j) + (-1).^(k-1)./(k.^t(j));
				endfor
				z(j) = 1./(1-2.^(1-t(j))).*z(j);
			endif
		else
			z(j) = 2.^t(j).*pi.^(t(j)-1).*sin(pi.*t(j)./2).*gamma(1-t(j)).*zeta(1-t(j));
		endif
	endfor
endfunction