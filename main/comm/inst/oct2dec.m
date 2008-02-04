## Copyright (C) 2007   Sylvain Pelissier   <sylvain.pelissier@gmail.com>
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File}  @var{d} = oct2dec(@var{c})
## Convert octal to decimal values.
## @seealso{base2dec,bin2dec,dec2bi}
## @end deftypefn

function d = oct2dec(c)
	 if (nargin != 1)
		usage ("d = oct2dec(c)");
	endif
	 if(any(c(:) < 0) || any(c(:) ~= floor(c(:))))
		error('c must be an octal matrix');
		exit
	end
	l = size(c,2);
	for k = 1:l
		str = num2str(c(:,k));
		d(:,k) = base2dec(str,8);
	end