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
	F = @(x) exp(-x)./x;
	if(x<0)
		y = -quad(F,-x,Inf);
	else
		if(abs(x) > 2 && imag(x) == 0)
			y = expint_Ei(2) - quad(F,-x,-2);
		else
			y = 0;
			for i = 1:100;
				y = y + x.^i./(i.*factorial(i));
			endfor

			y = 0.577215664901532860606512090082402431 + log(x) + y;
		endif
	endif;
endfunction;