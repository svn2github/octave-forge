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
## Binary addition of LTI objects. If necessary, object conversion
## is done by sysgroup. Used by the parser for "lti1 + lti2".
## Operation is also known as "parallel connection".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: September 2009
## Version: 0.1

function sys = plus (sys1, sys2)

  [p1, m1] = size (sys1);
  [p2, m2] = size (sys2);

  if (p1 != p2 || m1 != m2)
    error ("lti: plus: system dimensions incompatible: (%dx%d) + (%dx%d)",
            p1, m1, p2, m2);
  end

  sys = __sysgroup__ (sys1, sys2);

  in_scl = [eye(m1); eye(m2)];
  out_scl = [eye(p1), eye(p2)];

  sys = out_scl * sys * in_scl;

endfunction