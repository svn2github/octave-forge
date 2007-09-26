## Copyright (C) 2007   Sissou   <sylvain.pelissier@gmail.com>
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

## -*- texinfo -*-
## @deftypefn {Function File} ammod (@var{x},@var{fc},@var{fs})
## Create the AM modulation of the signal x with carrier frequency fs. Where x is sample at frequency fs.
## @seealso{erfc,erf,erfinv}
## @end deftypefn


function [y] = ammod(x,fc,fs)
    if (nargin != 3)
		usage ("ammod(x,fs,fc)");
	endif
    l = length(x);
    K = 1./max(abs(x));
    t=linspace(0,l.*fs,l);
    y = (1+K.*x).*cos(2.*pi.*fc.*t./fs);