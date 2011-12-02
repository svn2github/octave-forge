## Copyright (C) 2011   Lukas F. Reichlin
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
## Subscripted assignment for quaternions.
## Used by Octave for "q.key = value".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2011
## Version: 0.1

function q = subsasgn (q, idx, val)

  switch (idx(1).type)
    case "()"
      if (length (idx(1).subs) == 1 && isa (q, "quaternion"))  # required by horzcat, vertcat, cat, ...
        q(idx(1).subs{:}) = val;
      else                                                     # general case
        val = quaternion (val);
        w = subsasgn (q.w, idx, val.w);
        x = subsasgn (q.x, idx, val.x);
        y = subsasgn (q.y, idx, val.y);
        z = subsasgn (q.z, idx, val.z);
        q = quaternion (w, x, y, z);
      endif

    case "."
      if (! is_real_array (val))
        error ("quaternion: subsasgn: invalid type");
      endif
      if (! size_equal (q.w, val))
      ## if (! size_equal (subsref (q.w, idx(2:end)), val))
        error ("quaternion: subsasgn: invalid size");
      endif
      switch (tolower (idx(1).subs))
        case {"w", "s"}
          ## q.w = subsasgn (q.w, idx(2:end), val);
          q.w = val;
        case {"x", "i"}
          ## q.x = subsasgn (q.x, idx(2:end), val);
          q.x = val;
        case {"y", "j"}
          ## q.y = subsasgn (q.y, idx(2:end), val);
          q.y = val;
        case {"z", "k"}
          ## q.z = subsasgn (q.z, idx(2:end), val);
          q.z = val;
        otherwise
          error ("quaternion: subsasgn: invalid subscript name");
      endswitch

    otherwise
      error ("quaternion: subsasgn: under construction");
  endswitch

  ## TODO: q.x(:, 1) = matrix
  ##       wait until the jwe's bugfix makes it into a release
  ##       probably Octave 3.6.0

endfunction
