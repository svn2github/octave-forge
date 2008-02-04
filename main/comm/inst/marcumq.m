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
## @deftypefn {Function File} {[@var{Q}] =} marcumq(@var{a,b,m})
##	Compute the Marcum Q function.
## @end deftypefn

function Q = marcumq(a,b,m)

	if nargin < 2
		usage(" marcumq(a,b)\n\tmarcumq(a,b,m)");
	end
	
	if nargin < 3
		m = 1;
	end
	
	l = max([size(a,1) size(b,1) size(m,1)]);
	c = max([size(a,2) size(b,2) size(m,2)]);
	a = padarray(a,[l-size(a,1) c-size(a,2)],'replicate','post')
	b = padarray(b,[l-size(b,1) c-size(b,2)],'replicate','post');
	m = padarray(m,[l-size(m,1) c-size(m,2)],'replicate','post');
	
	if min(a(:)) <0 | min(b(:)) <0
		error("a and b must be positive");
	end
	
	for n = 1:l
		for o = 1:c
			k = 1-m(n,o):100;
			v = (a(n,o)./b(n,o)).^k.*besseli(k,a(n,o).*b(n,o));
			v = sum(v);
			Q(n,o) = v.*exp(-(a(n,o).^2+b(n,o).^2)/2);
		end
	end
endfunction