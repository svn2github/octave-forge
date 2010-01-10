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
## @deftypefnx{Function File} {@var{x} =} dlyap (@var{a}, @var{b}, @var{c})
## Solve discrete-time Lyapunov or Sylvester equations.
## Uses SLICOT SB03MD and SB04QD by courtesy of NICONET e.V.
## <http://www.slicot.org>
## @example
## @group
## AXA' - X + B = 0   (Lyapunov Equation)
##
## AXB' - X + C = 0   (Sylvester Equation)
## @end group
## @end example
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: January 2010
## Version: 0.1

function x = dlyap (a, b, c)

  if (nargin == 2)

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
    
  elseif (nargin == 3)
    
    n = issquare (a);
    m = issquare (b);
    [crows, ccols] = size (c);
    
    if (! n)
      error ("dlyap: a must be square");
    endif
    
    if (! m)
      error ("dlyap: b must be square");
    endif
    
    if (crows != n || ccols != m)
      error ("dlyap: c must be a (%dx%d) matrix", n, m);
    endif
  
    x = slsb04qd (-a, b, c);  # AXB' - X = -C

  else
    print_usage ();
  endif

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

## Sylvester
%!shared X, X_exp
%! A = [1.0   2.0   3.0 
%!      6.0   7.0   8.0 
%!      9.0   2.0   3.0];
%!
%! B = [7.0   2.0   3.0 
%!      2.0   1.0   2.0 
%!      3.0   4.0   1.0];
%!
%! C = [271.0   135.0   147.0
%!      923.0   494.0   482.0
%!      578.0   383.0   287.0];
%!
%! X = dlyap (-A, B, C);
%!
%! X_exp = [2.0000   3.0000   6.0000
%!          4.0000   7.0000   1.0000
%!          5.0000   3.0000   2.0000];
%!
%!assert (X, X_exp, 1e-4);