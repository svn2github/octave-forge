## Copyright (C) 2006  Michael Creel <michael.creel@uab.es>
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
## @deftypefn {Function File} {} unvech (@var{v})
## Performs the reverse of "vech". Generates a symmetric matrix from the lower
## triangular elements, received as a vector @var{v}.
## @end deftypefn

# Note: this uses a double loop. A C version would be a lot faster for large matrices.
## Adapted-By:  Ben Hall <benjamin.hall@pw.utc.com>

function x = unvech (v)

	if (nargin != 1)
    		usage ("unvech (v)");
	endif

	if (! isvector(v))
		usage ("unvech (v)");
	endif

	# find out dimension of symmetric matrix
	p = length(v);
	g = -(1 - sqrt(1 + 8*p))/2;

	if (mod(g,1) != 0)
		error("unvech: the input vector does not generate a square matrix");
	endif

	x = zeros(g,g);

	# fill in the symmetric matrix, the obvious way
# 	k = 1;
# 	for i = 1:g
# 		for j = i:g
# 			x(i,j) = v(k);
# 			if (i != j) x(j,i) = v(k); endif
# 			k = k + 1;
# 		endfor
# 	endfor

	# fill in the symmetric matrix, a more clever way
 	ii = repmat( 1:g, [g 1] );
 	idx= find( ii <= ii' );
 	x(idx) = v;
 	x = x + x' - diag(diag(x));
endfunction
