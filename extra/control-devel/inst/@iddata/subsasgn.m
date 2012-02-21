## Copyright (C) 2012   Lukas F. Reichlin
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
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## Subscripted assignment for LTI objects.
## Used by Octave for "sys.property = value".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: February 2012
## Version: 0.1

function dat = subsasgn (dat, idx, val)

  switch (idx(1).type)
    case "."
      if (length (idx) == 1)
        dat = set (dat, idx.subs, val);
      else
        prop = idx(1).subs;
        dat = set (dat, prop, subsasgn (get (dat, prop), idx(2:end), val));
      endif
    otherwise
      error ("iddata: subsasgn: invalid subscripted assignment type");
  endswitch

endfunction