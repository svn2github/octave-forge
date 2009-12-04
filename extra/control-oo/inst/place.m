## Copyright (C) 2009   Lukas F. Reichlin
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
## @deftypefn {Function File} {@var{f} =} place (@var{sys}, @var{p})
## @deftypefnx {Function File} {@var{f} =} place (@var{a}, @var{b}, @var{p})
## Pole assignment for a given matrix pair (A,B) such that eig (A-B*F) = P.
## Uses SLICOT SB01BD by courtesy of NICONET e.V.
## Special thanks to Peter Benner from TU Chemnitz for his advice.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: December 2009
## Version: 0.1

function f = place (a, b, p)

  ## TODO: add possibility to specify alpha as a fourth parameter

  if (nargin == 2)  # place (sys, p)
    p = b;
    [a, b, c, d, tsam] = ssdata (a);
  elseif (nargin == 3)  # place (a, b, p)
    if (! isnumeric (a) || ! isnumeric (b) || ! issquare (a) || rows (a) != rows (b))
      error ("place: matrices a and b not conformal");
    endif
    tsam = 0;  # assume continuous system
  else
    print_usage ();
  endif

  if (! isnumeric (p) || ! isvector (p) || isempty (p))
    error ("place: p must be a vector");
  endif
  
  p = sort (p(:));  # complex conjugate pairs must appear together
  wr = real (p);
  wi = imag (p);
  
  n = rows (a);  # number of states
  np = length (p);  # number of given eigenvalues
  
  if (np > n)
    error ("place: at most %d eigenvalues can be assigned for the given matrix a (%dx%d)",
            n, n, n);
  endif
  
  if (tsam > 0)
    alpha = 0;
  else
    alpha = - norm (a, inf);
  endif

  [f, iwarn] = slsb01bd (a, b, wr, wi, tsam, alpha);
  f = -f;  # A + B*F --> A - B*F
  
  if (iwarn)
    warning ("place: %d violations of the numerical stability condition NORM(F) <= 100*NORM(A)/NORM(B)",
              iwarn);
  endif

endfunction


%!shared A, B, C, P, Kexpected
%! A = [0, 1; 3, 2];
%! B = [0; 1];
%! C = [2, 1];  # C is needed for ss; it doesn't matter what the value of C is
%! P = [-1, -0.5];
%! Kexpected = [3.5, 3.5];
%!assert (place (ss (A, B, C), P), Kexpected, 2*eps);
%!assert (place (A, B, P), Kexpected, 2*eps);