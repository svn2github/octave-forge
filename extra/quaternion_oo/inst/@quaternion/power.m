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
## power operator of quaternions.  Used by Octave for "q.^x".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.1


function a = power (a, b)

  if (b == -1 && isa (a, "quaternion"))
    norm2 = norm2 (a);
    a.w = a.w ./ norm2;
    a.x = -a.x ./ norm2;
    a.y = -a.y ./ norm2;
    a.z = -a.z ./ norm2;
  else
    error ("quaternion: power: case not implemeted");
  endif

  ## TODO: q1 .^ q2

endfunction