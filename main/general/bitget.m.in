## Copyright (C) 2000  Kai Habel
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
## @deftypefn {Function File} {@var{X} =} bitget (@var{a},@var{n})
## returns the status of bit(s) @var{n} of unsigned integers in @var{a}
## the lowest significant bit is @var{n} = 1.
##
## @example
## bitget(100,8:-1:1)
## @result{} 0  1  1  0  0  1  0  0 
## @end example
## @seealso{bitand,bitor,bitxor,bitset,bitcmp,bitshift,bitmax}
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>

function X = bitget (A,n)
  
  if (nargin != 2)
    usage ("bitget(A,n)");
  endif

  m = n(:);
  if (any(m < 1) || any(m > (log2(bitmax) + 1)) )
    msg = sprintf ("n must be in range [1,%d]",round(log2(bitmax)+1));
    error (msg);
  endif

  if (!(is_matrix (A)) || is_complex (A))
    error ("first argument must be a real value");
  else
	X = bitand (A, pow2 (n - 1)) != 0;
  endif

endfunction
