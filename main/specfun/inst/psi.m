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

## PSI compute the psi function,
##
##
##
##             d 
##    psi(x) = __ log(gamma(x))
##             dx
##

function [y] = psi(x)
	if (nargin != 1)
			usage ("psi(x)");
	endif
	
	if(x == 0)
		y = -Inf;
	else
		h = 0.00000001;
		if(imag(x) == 0 && x > 0)
			y = (lgamma(x+h)-lgamma(x-h))./(2.*h);
		else
			if(imag(x) == 0)
				y = (lgamma((1-x)+h)-lgamma((1-x)-h))./(2.*h) + pi.*cot(pi.*(1-x));
			else
				error("unable to handle complex arguments");
			endif
		endif
	endif

endfunction