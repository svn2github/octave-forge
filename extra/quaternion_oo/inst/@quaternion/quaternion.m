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
## @deftypefn {Function File} {@var{q} =} quaternion (@var{w})
## @deftypefnx {Function File} {@var{q} =} quaternion (@var{x}, @var{y}, @var{z})
## @deftypefnx {Function File} {@var{q} =} quaternion (@var{w}, @var{x}, @var{y}, @var{z})
## Constructor for quaternions - create or convert to quaternion
##
## @example
## q = w + x*i + y*j + z*k
## @end example
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.1


function q = quaternion (a, b, c, d)

  switch (nargin)
    case 1
      if (isa (a, "quaternion"))
        q = a;
        return;
      elseif (isnumeric (a))
        z = zeros (size (a), class (a));
        q = class (struct ("w", a, "x", z, "y", z, "z", z), "quaternion");
        return;
      else
        print_usage ();
      endif

    case 3
      s_a = size (a);

      if (any (s_a != size (b)) || any (s_a != size (c)));
        error ("quaternion: arguments must have identical sizes");
      endif

      c_a = class (a);

      if (isnumeric (a) && strcmp (c_a, class (b)) && strcmp (c_a, class (c)))
        z = zeros (s_a, c_a);
        q = class (struct ("w", z, "x", a, "y", b, "z", c), "quaternion");
        return;
      else
        error ("quaternion: arguments must be numeric and of the same type");
      endif

    case 4
      s_a = size (a);

      if (any (s_a != size (b)) || any (s_a != size (c)) || any (s_a != size (d)));
        error ("quaternion: arguments must have identical sizes");
      endif

      c_a = class (a);

      if (isnumeric (a) && strcmp (c_a, class (b)) && \
          strcmp (c_a, class (c)) && strcmp (c_a, class (d)))
        q = class (struct ("w", a, "x", b, "y", c, "z", d), "quaternion");
        return;
      else
        error ("quaternion: arguments must be numeric and of the same type");
      endif

    otherwise
      print_usage ();
  endswitch

endfunction
