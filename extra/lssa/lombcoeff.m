## Copyright (C) 2012 Benjamin Lewis <benjf5@gmail.com>
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
## @deftypefn {Function File} {c =} lombcoeff (time, mag, freq)
##
## Return the coefficient of the Lomb periodogram (unnormalized) for the
## (@var{time},@var{mag}) series for the @var{freq} provided.
##
## @seealso{lombnormcoeff}
## @end deftypefn


function coeff = lombcoeff(T, X, o)
  theta = atan2(sum(sin(2 .* o .* T )), sum(cos(2.*o.*T)))/ (2 * o );
  coeff = ( sum(X .* cos(o .* T - tau))**2)/(sum(cos(o.*T-tau).**2)) +
          ( sum(X .* sin(o .* T - tau))**2)/(sum(sin(o.*T-tau).**2));
end function

