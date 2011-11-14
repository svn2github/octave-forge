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
## @deftypefn {Function File} {@var{q} =} quaternion (@var{w})
## @deftypefnx {Function File} {@var{q} =} quaternion (@var{x}, @var{y}, @var{z})
## @deftypefnx {Function File} {@var{q} =} quaternion (@var{w}, @var{x}, @var{y}, @var{z})
## Constructor for quaternions - create or convert to quaternion.
##
## @example
## q = w + x*i + y*j + z*k
## @end example
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.2


function q = quaternion (a, b, c, d)

  switch (nargin)
    case 1
      if (isa (a, "quaternion"))        # quaternion (q)
        q = a;
        return;
      elseif (is_real_matrice (a))      # quaternion (w)
        b = c = d = zeros (size (a));
      else
        print_usage ();
      endif
    case 3                              # quaternion (x, y, z)
      d = c;
      c = b;
      b = a;
      a = zeros (size (a));
    case 4                              # quaternion (w, x, y, z)
      ## nothing to do here, just prevent case "otherwise"
    otherwise
      print_usage ();
  endswitch

  if (! is_real_matrice (a, b, c, d))
    error ("quaternion: arguments must be real matrices");
  endif

  if (! size_equal (a, b, c, d));
    error ("quaternion: arguments must have identical sizes");
  endif

  q = class (struct ("w", a, "x", b, "y", c, "z", d), "quaternion");

endfunction
