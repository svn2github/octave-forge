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
## Matrix multiplication of LTI objects. If necessary, object conversion
## is done by sysgroup. Used by the parser for "lti1 * lti2".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: September 2009
## Version: 0.1

function sys = mtimes (sys2, sys1)

  [p1, m1] = size (sys1);
  [p2, m2] = size (sys2);

  if (m2 != p1)
    error ("lti: mtimes: system dimensions incompatible: (%dx%d) * (%dx%d)",
            p2, m2, p1, m1);
  end

  M22 = zeros (m2, p2);
  M21 = eye (m2, p1);
  M12 = zeros (m1, p2);
  M11 = zeros (m1, p1);

  M = [M22, M21;
       M12, M11];

  out_idx = 1 : p2;
  in_idx = m2 + (1 : m1);

  sys = __sysgroup__ (sys2, sys1);
  sys = __sysconnect__ (sys, M);
  sys = __sysprune__ (sys, out_idx, in_idx);

endfunction


%!shared sysmat, sysmat_exp
%!
%! sys1 = ss ([0, 1; -3, -2], [0; 1], [-5, 1], [2]);
%! sys2 = ss ([-10], [1], [-40], [5]);
%!
%! sysa = sys2 * sys1;
%!
%! [A, B, C, D] = ssdata (sysa);
%! sysmat = [A, B; C, D];
%!
%! ## expected values computed by the "dark side"
%! A_exp = [ -10   -5    1
%!             0    0    1
%!             0   -3   -2 ];
%!
%! B_exp = [   2
%!             0
%!             1 ];
%!
%! C_exp = [ -40  -25    5 ];
%!
%! D_exp = [  10 ];
%!
%! sysmat_exp = [A_exp, B_exp; C_exp, D_exp];
%!
%!assert (sysmat, sysmat_exp)

