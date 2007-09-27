## Copyright (C) 2006   Sylvain Pelissier   <sylvain.pelissier@gmail.com>
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

## CI compute the cosine integral function define by:
##
##                    Inf
##                   /
##           Ci(x) = | cos(t)/t dt
##                   /
##                   x
##
##See also : cosint, Si, sinint, expint, expint_Ei.

function y = Ci(z)
	if (nargin != 1)
		usage ("Ci(x)");
	endif
	y = z;
	y(z == 0) = -Inf; 
	y(real(z) == 0 & imag(z) >0)  = 0.5*(expint_Ei(i.*y(real(z) == 0 & imag(z) >0))+expint_Ei(-i.*y(real(z) == 0 & imag(z) >0)))+ i.*pi./2;
	y(real(z) == 0 & imag(z) <0) = 0.5*(expint_Ei(i.*y(real(z) == 0 & imag(z) <0))+expint_Ei(-i.*y(real(z) == 0 & imag(z) <0)))-i*pi./2;
	y(real(z)>0) = -0.5.*(expint_E1(i.*y(real(z)>=0) )+expint_E1(-i.*y(real(z)>=0) ));
	y(real(z)<0) = -0.5.*(expint_E1(-i.*y(real(z)<0))+expint_E1(i.*y(real(z)<0)))+i*pi;
endfunction;