## Copyright (C) 2009 VZLU Prague, a.s., Czech Republic
##
## Author: Jaroslav Hajek <highegg@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## This replaces the missing functionality of "merge" if on Octave 3.2.

function merge_func = __merge_compat__ ()
  persistent octave32 = issorted ({"3.0.0", version, "3.3.0"});
  if (octave32)
    merge_func = @__my_merge__;
  else
    merge_func = @merge;
  endif
endfunction

function ret = __my_merge__ (mask, tval, fval)

  if (isscalar (mask))
    if (mask)
      ret = tval;
    else
      ret = fval;
    endif
  else
    if (numel (fval) == 1)
      ret = repmat (fval, size (mask));
    else
      ret = fval;
    endif
    ret(mask) = tval(mask);
  endif
endfunction


