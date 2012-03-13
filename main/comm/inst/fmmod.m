## Copyright (C) 2007 Sylvain Pelissier <sylvain.pelissier@gmail.com>
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

## -*- texinfo -*-
## @deftypefn {Function File} fmmod (@var{x},@var{fc},@var{fs})
## Create the FM modulation of the signal x with carrier frequency fs. Where x is sample at frequency fs.
## @seealso{ammod,fmdemod,amdemod}
## @end deftypefn

function [s] = fmmod(m,fc,fs,freqdev)
	if(nargin < 3)
		usage('s = my_fmmod(m,fc,fs,freqdev)');
	end
	l = length(m);
	t=0:1./fs:(l-1)./fs;
	int_m = cumsum(m)./fs;
	
	s = cos(2*pi.*fc.*t + 2*pi.*freqdev.*int_m);
