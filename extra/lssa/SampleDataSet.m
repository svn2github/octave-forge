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

## No function structure to this, I just want to use it to store the
## sums of sines and cosines I'll use for testing.

xvec = linspace(0,8,1000);
maxfreq = 4 / ( 2 * pi );

yvec = ( 2.*sin(maxfreq.*xvec) + 3.*sin((3/4)*maxfreq.*xvec)
	- 0.5 .* sin((1/4)*maxfreq.*xvec) - 0.2 .* cos(maxfreq .* xvec)
	+ cos((1/4)*maxfreq.*xvec));

