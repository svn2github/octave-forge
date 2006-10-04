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
		if(imag(x) != zeros(size(x)))
			error('unable to handle complex arguments');
		else
			h = 1e-9;
			y = x;	
			y(x == 0) = -Inf;
			y(x>0) = (lgamma(y(x>0)+h)-lgamma(y(x>0)-h))./(2.*h);
			y(x<0) = (lgamma((1-y(x<0))+h)-lgamma((1-y(x<0))-h))./(2.*h) + pi.*cot(pi.*(1-y(x<0)));
		endif
endfunction