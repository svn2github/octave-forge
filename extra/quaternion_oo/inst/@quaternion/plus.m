## Copyright (C) 2010   Lukas F. Reichlin
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## Addition of two quaternions. Used by Octave for "q1 + q2"

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.1


function a = plus (a, b)

  if (! isa (a, "quaternion"))
    a = quaternion (a);
  endif

  if (! isa (b, "quaternion"))
    b = quaternion (b);
  endif

  a.w = a.w + b.w;
  a.x = a.x + b.x;
  a.y = a.y + b.y;
  a.z = a.z + b.z;

endfunction