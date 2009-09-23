## Copyright (C) 2009 Jaroslav Hajek
## 
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
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
## @deftypefn{Function File} {} function chop (@var{x}, @var{tol})
## Replaces tiny elements of the vector @var{x} by zeros.
## Equivalent to 
## @example
##   @var{x}(abs(@var{x}) < @var{tol} * norm (@var{x}, Inf)) = 0
## @end example
## @var{tol} specifies the chopping tolerance. It defaults to 
## 1e-10 for double precision and 1e-5 for single precision inputs.
## @end deftypefn

function x = chop (x, tol)
  if (nargin == 1)
    if (isa (x, 'single'))
      tol = 1e-5;
    else
      tol = 1e-10;
    endif
  elseif (nargin != 2)
    print_usage ();
  endif

  if (isfloat (x))
    x(abs(x) < tol*norm (x, Inf)) = 0;
  else
    error ("chop: needs a floating-point argument");
  endif

endfunction
