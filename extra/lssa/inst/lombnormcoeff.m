## Copyright (c) 2012 Benjamin Lewis <benjf5@gmail.com>
## 
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 2 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {c =} lombnormcoeff (time, mag, freq)
##
## Return the coefficient of the Lomb Normalised Periodogram at the
## specified @var{frequency} of the periodogram applied to the
## (@var{time}, @var{mag}) series.
##
## @end deftypefn

function coeff = lombnormcoeff(T,X,omega)
tau = atan2( sum( sin( 2.*omega.*T)), sum(cos(2.*omega.*T))) / 2;
coeff = ( ( sum ( X .* cos( omega .* T - tau ) ) .^ 2 ./ sum ( cos ( omega .* T - tau ) .^ 2 )
	   + sum ( X .* sin ( omega .* T - tau ) ) .^ 2 / sum ( sin ( omega .* T - tau ) .^ 2 ) )
	 / ( 2 * var(X) ) );
endfunction
