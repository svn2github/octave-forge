## Copyright (C) 2010, 2011   Lukas F. Reichlin
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
## Subscripted reference for quaternions.  Used by Octave for "q.w".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.2

function ret = subsref (q, s)

  switch (s(1).type)
    case "."                # q.w
      switch (tolower (s.subs))
        case {"w", "s"}     # scalar part
          ret = q.w;
        case {"x", "i"}
          ret = q.x;
        case {"y", "j"}
          ret = q.y;
        case {"z", "k"}
          ret = q.z;
        case "v"            # vector part, scalar part set to zero
          q.w = zeros (size (q.w), class (q.w));
          ret = q;
        otherwise
          error ("quaternion: invalid subscript name");
      endswitch

    case "()"               # q(...)
      w = subsref (q.w, s);
      x = subsref (q.x, s);
      y = subsref (q.y, s);
      z = subsref (q.z, s);
      ret = quaternion (w, x, y, z);
      
    otherwise
      error ("quaternion: invalid subscript type");
  endswitch

endfunction
