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
## @deftypefn {Function File} {@var{X} =} bitshift (@var{a},@var{k})
## @deftypefnx {Function File} {@var{X} =} bitshift (@var{a},@var{k},@var{n})
## return a @var{k} bit shift of @var{n}- digit unsigned
## integers in @var{a}. A positive @var{k} leads to a left shift.
## A negative value to a right shift. If @var{N} is omitted it defaults
## to log2(bitmax)+1. 
## @var{N} must be in range [1,log2(bitmax)+1] usually [1,33]
## 
##
## @example
## bitshift(eye(3),1))
## @result{} 
## @group
## 2 0 0
## 0 2 0
## 0 0 2
## @end group
##
## bitshift(10,[-2, -1, 0, 1, 2])
## @result{} 2   5  10  20  40
##
## bitshift ([1, 10],2,[3,4])
## @result{} 4  8
## @end example
##
## @seealso{bitand,bitor,bitxor,bitset,bitget,bitcmp,bitmax}
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>

## Bug fixed by Paul Kienzle <pkienzle@kienzle.powernet.co.uk> 
## log2(bitmax) must be rounded to nearest integer 

function X = bitshift (A,k,n)
  
  if ((nargin < 2) | (nargin > 3))
    usage ("bitshift(A,n,k)");
  endif

  if (nargin == 3)
    n = fix (n);
    if ( is_scalar(n) & (!is_scalar(k)) )
      if (!is_scalar (A) & ((ndims (A) != ndims (k)) || any(size (A) != size (k))))
        error ("size of A and k must match");
      endif 
      n = n .* ones (size (k));
    elseif (!is_scalar (n)) & is_scalar (k)
      if (!is_scalar (A) & ((ndims (A) != ndims (n)) || any(size (A) != size (n))))
        error ("size of A and n must match");
      endif
      k = fix (k) .* ones (size (n));
    elseif ((ndims (n) != ndims (n)) || any(size (n) != size (n)))
      error ("size of n and k must match");
    endif
  else
    n = round (log2 (bitmax) * ones (size (k)));
  endif

  if !(is_matrix (A)) || is_complex (A)
    error ("first argument must be a real value");
  else
	X = fix (A .* pow2 (k));
	X = bitand (X, pow2 (n) - 1);
  endif

endfunction
