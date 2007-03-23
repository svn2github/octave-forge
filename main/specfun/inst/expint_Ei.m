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

## EXPINT_EI compute the exponential integral,
##
##                      infinity
##                     /
##    expint_Ei(x) = - | exp(t)/t dt
##                     /
##                     -x
##
## See also expint, expint_E1.

function y = expint_Ei(x)
	if (nargin != 1)
		usage ("expint_Ei(x)");
	endif
	y = zeros(size(x));
	F = @(x) exp(-x)./x;
	s = prod(size(x));
	for t = 1:s;
		if(x(t)<0 && imag(x(t)) == 0)
			y(t) = -quad(F,-x(t),Inf);
		else
			if(abs(x(t)) > 2 && imag(x(t)) == 0)
				y(t) = expint_Ei(2) - quad(F,-x(t),-2);
			else
				if(abs(x(t)) >= 10)
					if(imag(x(t)) <= 0)
						a1 = 4.03640;
						a2 = 1.15198;
						b1 = 5.03637;
						b2 = 4.19160;
						y(t) = -(x(t).^2 - a1.*x(t) + a2)./((x(t).^2-b1.*x(t)+b2).*(-x(t)).*exp(-x(t)))-i.*pi;
					else
						y(t) = conj(expint_Ei(conj(x(t))));
					endif;
		## Serie Expansion
				else 
					for k = 1:100;
						y(t) = y(t) + x(t).^k./(k.*factorial(k));
					endfor
					y(t) = 0.577215664901532860606512090082402431 + log(x(t)) + y(t);
				endif
			endif
		endif;
	endfor
endfunction;