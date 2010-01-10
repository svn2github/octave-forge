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
## @deftypefn{Function File} {@var{x} =} lyap (@var{a}, @var{b})
## @deftypefnx{Function File} {@var{x} =} lyap (@var{a}, @var{b}, @var{c})
## Solve continuous-time Lyapunov or Sylvester equations.
## Uses SLICOT SB03MD and SB04MD by courtesy of NICONET e.V.
## <http://www.slicot.org>
## @example
## @group
## AX + XA' + B = 0   (Lyapunov Equation)
##
## AX + XB + C = 0    (Sylvester Equation)
## @end group
## @end example
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: January 2010
## Version: 0.1

function x = lyap (a, b, c)

  if (nargin == 2)  # Lyapunov equation

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
  
    [x, scale] = slsb03md (a, -b, false);  # AX + XA' = -B
    
    x /= scale;  # 0 < scale <= 1
    
  elseif (nargin == 3)  # Sylvester equation
  
    n = issquare (a);
    m = issquare (b);
    [crows, ccols] = size (c);
    
    if (! n)
      error ("lyap: a must be square");
    endif
    
    if (! m)
      error ("lyap: b must be square");
    endif
    
    if (crows != n || ccols != m)
      error ("lyap: c must be a (%dx%d) matrix", n, m);
    endif
  
    x = slsb04md (a, b, -c);  # AX + XB = -C
  
  else
    print_usage ();
  endif

endfunction


## Lyapunov
%!shared X, X_exp
%! A = [1, 2; -3, -4];
%! Q = [3, 1; 1, 1];
%! X = lyap (A, Q);
%! X_exp = [ 6.1667, -3.8333;
%!          -3.8333,  3.0000];
%!assert (X, X_exp, 1e-4);

## Sylvester
%!shared X, X_exp
%! A = [2.0   1.0   3.0
%!      0.0   2.0   1.0
%!      6.0   1.0   2.0];
%!
%! B = [2.0   1.0
%!      1.0   6.0];
%!
%! C = [2.0   1.0
%!      1.0   4.0
%!      0.0   5.0];
%!
%! X = lyap (A, B, -C);
%!
%! X_exp = [-2.7685   0.5498
%!          -1.0531   0.6865
%!           4.5257  -0.4389];
%!
%!assert (X, X_exp, 1e-4);
