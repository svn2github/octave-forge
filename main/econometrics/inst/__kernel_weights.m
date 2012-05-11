## Copyright (C) 2006, 2007 Michael Creel <michael.creel@uab.es>
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

## __kernel_weights: for internal use by kernel_regression and kernel_density. There
## is also a faster .oct file version that should be be found automatically.

function W = __kernel_weights(data, evalpoints, kernel)

	# calculate distances
	nn = rows(evalpoints);
	n = rows(data);
	W = zeros(nn,n);
	for i = 1:nn
		zz = data - repmat(evalpoints(i,:), n, 1);
		zz = feval(kernel, zz);
		W(i,:) = zz';
	endfor
endfunction
