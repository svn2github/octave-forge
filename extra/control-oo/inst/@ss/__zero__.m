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
## Transmission zeros of SS object.
## Uses SLICOT AB08ND by courtesy of NICONET e.V.
## <http://www.slicot.org>

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2009
## Version: 0.1

function [zer, gain] = __zero__ (sys)

  [alphar, alphai, beta] = slab08nd (sys.a, sys.b, sys.c, sys.d);

  zer = (alphar + i*alphai) ./ beta;

  lz = length (zer);
  n = rows (sys.a);
  m = columns (sys.b);
  p = rows (sys.c);

  if (lz == n)
    gain = sys.d;
  else
    gain = sys.c * (sys.a^(n-1-lz)) * sys.b;
  endif

endfunction