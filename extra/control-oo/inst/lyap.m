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
## @deftypefn{Function File} {@var{x} =} lyap (@var{a}, @var{q})
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

function x = lyap (a, q)

  if (nargin != 2)
    print_usage ();
  endif

  na = issquare (a);
  nq = issquare (q);
  
  if (! na)
    error ("lyap: a must be square");
  endif

  if (! nq)
    error ("lyap: q must be square")
  endif
  
  if (na != nq)
    error ("lyap: a and q must be of identical size");
  endif
  
  x = slsb03md (a, -q, false);

endfunction


%!shared X, X_exp
%! A = [1, 2; -3, -4];
%! Q = [3, 1; 1, 1];
%! X = lyap (A, Q);
%! X_exp = [ 6.1667, -3.8333;
%!          -3.8333,  3.0000];
%!assert (X, X_exp, 1e-4);