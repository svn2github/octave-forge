## Copyright (C) 2010   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {@var{x} =} dlyap (@var{a}, @var{b})
## 
## @example
## @group
##
## @end group
## @end example
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: January 2010
## Version: 0.1

function x = dlyap (a, b)

  if (nargin != 2)
    print_usage ();
  endif

  na = issquare (a);
  nb = issquare (b);
  
  if (! na)
    error ("lyap: a must be square");
  endif

  if (! nb)
    error ("lyap: b must be square")
  endif
  
  if (na != nb)
    error ("lyap: a and b must be of identical size");
  endif
  
  x = slsb03md (a, -b, true);  # AXA' - X = -B

endfunction


## Lyapunov
%!shared X, X_exp
%! A = [3.0   1.0   1.0
%!      1.0   3.0   0.0
%!      0.0   0.0   3.0];
%!
%! B = [25.0  24.0  15.0
%!      24.0  32.0   8.0
%!      15.0   8.0  40.0];
%!
%! X = dlyap (A', -B);
%!
%! X_exp = [2.0000   1.0000   1.0000
%!          1.0000   3.0000   0.0000
%!          1.0000   0.0000   4.0000];
%!
%!assert (X, X_exp, 1e-4);