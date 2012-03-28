## Copyright (C) 1998, 2000, 2005, 2007
##               Auburn University.  All rights reserved.
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} qderiv (omega)
## Derivative of a quaternion.
##
## Let Q be a quaternion to transform a vector from a fixed frame to
## a rotating frame.  If the rotating frame is rotating about the 
## [x, y, z] axes at angular rates [wx, wy, wz], then the derivative
## of Q is given by
##
## @example
## Q' = qderivmat (omega) * Q
## @end example
##
## If the passive convention is used (rotate the frame, not the vector),
## then
##
## @example
## Q' = -qderivmat (omega) * Q
## @end example
## @end deftypefn

## Author: A. S. Hodel <a.s.hodel@eng.auburn.edu>
## Adapted-By: jwe

function Dmat = qderivmat (Omega)

  if (nargin != 1)
    print_usage ();
  endif

  Omega = vec (Omega);

  if (length (Omega) != 3)
    error ("qderivmat: Omega must be a length 3 vector");
  endif

  Dmat = 0.5 * [      0.0,  Omega(3), -Omega(2),  Omega(1);
                -Omega(3),       0.0,  Omega(1),  Omega(2);
                 Omega(2), -Omega(1),       0.0,  Omega(3);
                -Omega(1), -Omega(2), -Omega(3),       0.0 ];
endfunction
