## Copyright (C) 2008 Jaroslav Hajek
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
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} @var{p} = safeprod (@var{x}, @var{dim})
## @deftypefnx{Function File} [@var{p}, @var{e}] = safeprod (@var{x}, @var{dim})
## This functions sums the array @var{x} along the dimension specified
## by @var{dim}, analogically to @code{sum}, but avoid overflows and underflows 
## if possible. If called with 2 output arguments, @var{p} and @var{e} are
## computed so that the product is @code{@var{p} * 2^@var{e}}.
## @seealso{prod,log2}
## @end deftypefn

## Author: Jaroslav Hajek highegg@gmail.com
## Created: 2008-04-22

function [p, e] = safeprod (x, dim = 1)
  if (nargin < 1 || nargin > 2)
    print_usage ();
  endif

  if (nargout < 2) 
    p = prod (x, dim);
  else
    p = 0;
  endif

  # 0, Inf and NaN are possibly problematic results. If detected, use the safe
  # formula.

  flag = (p == 0 | ! isfinite (p));

  if (any (flag(:)))
    [f, e] = log2 (x);
    p = prod (f, dim);
    e = sum (e, dim);
    if (nargout < 2)
      p = p .* 2.^e;
    endif
  endif

endfunction
