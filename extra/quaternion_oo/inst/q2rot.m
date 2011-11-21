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
## TODO: write help.

## Adapted from: quaternion by A. S. Hodel <a.s.hodel@eng.auburn.edu>
## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.1

function [vv, theta] = q2rot (q)

  if (nargin != 1 || nargout != 2)
    print_usage ();
  endif

  if (abs (norm (q) - 1) > 1e-12)
    warning ("quaternion: ||q||=%e, setting=1 for vv, theta", norm (q));
    q = unit (q);
  endif

  s = q.s;
  x = q.x;
  y = q.y;
  z = q.z;

  theta = acos (s) * 2;

  if (abs (theta) > pi)
    theta = theta - sign (theta) * pi;
  endif

  sin_th_2 = norm ([x, y, z]);

  if (sin_th_2 != 0)
    vv = [x, y, z] / sin_th_2;
  else
    vv = [x, y, z];
  endif

endfunction