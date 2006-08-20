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

## EXPINT compute the exponential integral,
##
##                    infinity
##                   /
##       expint(x) = | exp(t)/t dt
##                   /
##                  x
##
## See also expint_Ei, expint_E1.

function y = expint(x)
	if (nargin != 1)
		usage ("expint(x)");
	endif
	y = expint_E1(x);
endfuncion;