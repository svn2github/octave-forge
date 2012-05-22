## Copyright (C) 2012 Benjamin Lewis <benjf5@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## This function implements the windowing function on page 10 of the doc.
## if t is in [-1,1] then the windowed term is a = 1 + ( |t|^2 * ( 2|t| - 3 )
## else the windowed term is 0.
function a = cubicwgt(t) ## where t is the set of time values
  a = abs(t);
  a = ifelse( ( a < 1 ), 1 + ( ( a .^ 2 ) .* ( 2 .* a - 3 ) ), a = 0);
endfunction
