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
## @deftypefn {Function File} {@var{X} =} bitcmp (@var{a},@var{k})
## returns the @var{k}-bit complement of integers in @var{a}. If
## @var{k} is omitted k = log2(bitmax) is assumed.
##
## @example
## bitcmp(7,4)
## @result{} 8
## dec2bin(11)
## @result{} 1011
## dec2bin(bitcmp(11))
## @result{} 11111111111111111111111111110100
## @end example
##
## @seealso{bitand,bitor,bitxor,bitset,bitget,bitcmp,bitshift,bitmax}
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>

function X = bitcmp (A,n)
  
  if (nargin < 1 || nargin > 2)
    usage ("bitcmp(A,n)");
  endif

  if (nargin == 1)
    n = log2 (bitmax);
  endif

  if (!(is_matrix (A)) || is_complex (A))
    error ("first argument must be a real value");
  else
	p = bitmax - pow2 (n) + 1;
	X = bitmax - bitor (A, p);
  endif

endfunction
