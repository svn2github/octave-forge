## Copyright (C) 2010   Lukas F. Reichlin
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
## Set or modify properties of FRD objects.

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2010
## Version: 0.1

function sys = __set__ (sys, prop, val)

  switch (prop)                                 # {<internal name>, <user name>}
    case {"h", "r", "resp", "response"}
      if (ndims (val) != 3 && ! isempty (val))  # TODO: share code with @frd/frd.m
        val = reshape (val, 1, 1, []);
      elseif (isempty (val))
        val = zeros (0, 0, 0);
      endif
      __frd_dim__ (val, sys.w);
      sys.H = val;

    case {"w", "f", "freq", "frequency"}
      val = reshape (val, [], 1);
      __frd_dim__ (sys.H, val);
      sys.w = val;

    otherwise
      error ("frd: set: invalid property name");

  endswitch

endfunction