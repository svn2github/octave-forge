## Copyright (C) 1998, 1999, 2000, 2002, 2005, 2006, 2007 Auburn University
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
## TODO

## Adapted from: quaternion by A. S. Hodel <a.s.hodel@eng.auburn.edu>
## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.1

function q = rot2q (vv, theta)

  if (nargin != 2 || nargout != 1)
    print_usage ();
  endif

  if (! isvector (vv) || length (vv) != 3)
    error ("vv must be a length three vector");
  endif

  if (! isscalar (theta))
    error ("theta must be a scalar");
  endif

  if (norm (vv) == 0)
    error ("quaternion: vv is zero");
  endif

  if (abs (norm (vv) - 1) > 1e-12)
    warning ("quaternion: ||vv|| != 1, normalizing")
    vv = vv / norm (vv);
  endif

  if (abs (theta) > 2*pi)
    warning ("quaternion: |theta| > 2 pi, normalizing")
    theta = rem (theta, 2*pi);
  endif

  vv = vv * sin (theta / 2);
  d = cos (theta / 2);
  q = quaternion (d, vv(1), vv(2), vv(3));

endfunction