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
## @deftypefn {Function File} {@var{X} =} bitset (@var{a},@var{n})
## @deftypefnx {Function File} {@var{X} =} bitset (@var{a},@var{n},@var{v})
## sets or resets bit(s) @var{N} of unsigned integers in @var{A}.
## @var{v} = 0 resets and @var{v} = 1 sets the bits.
## The lowest significant bit is: @var{n} = 1
##
## @example
## dec2bin (bitset(10,1))
## @result{} 1011
## @end example
##
## @seealso{bitand,bitor,bitxor,bitget,bitcmp,bitshift,bitmax}
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>

function X = bitset (A, n, value)
  
  if (nargin < 2 || nargin > 3)
    usage ("bitset (A, n, v)");
  endif

  if (nargin == 2)
	value = 1;
  endif
  
  if (n < 1 || n > (log2(bitmax) + 1) )
    msg = sprintf ("n must be in range [1,%d]",round(log2(bitmax)+1));
    error (msg);
  endif

  if (!is_matrix (A) || is_complex (A))
    error ("first argument must be a real value");
  else
	X = bitand (pow2 (n - 1), value);
	Y = bitand (A, bitmax - pow2 (n - 1));
	X = bitor (X, Y);
  endif

endfunction
