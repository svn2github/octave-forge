## Copyright (C) 2001  Paul Kienzle
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

## ind = sub2ind (dims, s1, s2, ...)
## ind = sub2ind (dims, S)
##
## Convert SUBscripts into a linear INDex.  If S is a matrix, use
## one column per subscript.
##
## See also: ind2sub

## Author:        Paul Kienzle <pkienzle@kienzle.powernet.co.uk>

function ind = sub2ind (dims, s, ...)

  if nargin-1 == length (dims)

    ind = s(:);
    n = length ( ind );
    scale = cumprod(dims(:));
    va_start();
    for i=1:nargin-2
      v = va_arg();
      if (length(v) != n)
	error("sub2ind: each index must have the same length");
      endif
      ind = ind + (v(:)-1)*scale(i);
    endfor
    ind = reshape(ind, size(s));
    
  elseif nargin == 2
    
    if ( columns(s) != length(dims))
      error("sub2ind: needs one column per dimension\n");
    endif
    scale = cumprod(dims(:));
    ind = (s-1) * [ 1; scale(1:length(dims)-1) ] + 1;

  else
    
    error("sub2ind: needs one index per dimension\n");
    
  endif

endfunction
