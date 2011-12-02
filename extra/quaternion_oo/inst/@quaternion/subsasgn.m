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
      if (isa (q, "quaternion"))        # required for horzcat, vertcat, cat, ...
        q(idx(1).subs{:}) = val;
      else
        error ("quaternion: subsasgn: (): under construction");
      endif

    otherwise
      error ("quaternion: subsasgn: under construction");
  endswitch


%{
  switch (idx(1).type)
    case "."
      if (length (idx) == 1)
        ret = set (q, idx.subs, val);
      else
        prop = idx(1).subs;
        sys = set (q, prop, subsasgn (get (q, prop), idx(2:end), val));
      endif

    otherwise
      error ("quaternion: subsasgn: invalid subscripted assignment type");

  endswitch

  ## TODO: q.w = matrix
  ##       q.x(:, 1) = matrix

  ## TODO: q(1:2, 3) = quaternion

  switch (s(1).type)
    case "."                                # q.w
      switch (tolower (s(1).subs))
        case {"w", "s"}                     # scalar part
          ## ret = subsref (q.w, s(2:end));
          ret = q.w;
        case {"x", "i"}
          ## ret = subsref (q.x, s(2:end));
          ret = q.x;
        case {"y", "j"}
          ## ret = subsref (q.y, s(2:end));
          ret = q.y;
        case {"z", "k"}
          ## ret = subsref (q.z, s(2:end));
          ret = q.z;
        case "v"                            # vector part, scalar part set to zero
          q.w = zeros (size (q.w), class (q.w));
          ## ret = subsref (q, s(2:end));
          ret = q;
        otherwise
          error ("quaternion: invalid subscript name");
      endswitch

    case "()"                               # q(...)
      w = subsref (q.w, s);
      x = subsref (q.x, s);
      y = subsref (q.y, s);
      z = subsref (q.z, s);
      ret = quaternion (w, x, y, z);
      
    otherwise
      error ("quaternion: invalid subscript type");
  endswitch
%}
endfunction
