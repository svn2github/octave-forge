## Copyright (C) 2009   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## Set or modify properties of TF objects.

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2009
## Version: 0.1

function sys = __set__ (sys, prop, val)

  switch (prop)  # {<internal name>, <user name>}
    case {"num"}
      num = __conv2tfpolycell__ (val);
      [p, m] = __tfnddim__ (num, sys.den);
      sys.num = num;

    case {"den"}
      den = __conv2tfpolycell__ (val);
      [p, m] = __tfnddim__ (sys.num, den);
      sys.den = den;

    case {"tfvar", "variable"}
      if (ischar (val))
        sys.tfvar = val;
      else
        error ("tf: set: invalid transfer function variable");
      endif

    otherwise
      error ("set: invalid property name");

  endswitch

endfunction
