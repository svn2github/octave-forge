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

## This replaces the missing functionality of "lookup" if on Octave 3.2.

function lookup_func = __lookup_compat__ ()
  persistent octave32 = issorted ({version, "3.3.x"});
  if (octave32)
    lookup_func = @__my_lookup__;
  else
    lookup_func = @lookup;
  endif
endfunction

function ind = __my_lookup__ (table, y, opt = "")

  mopt = any (opt == 'm');
  bopt = any (opt == 'b');

  opt(opt == 'm' | opt == 'b') = [];

  ind = lookup (table, y, opt);
  if (numel (table) > 0)
    if (ischar (table) || iscellstr (table))
      match = strcmp (table(max (1, ind)), y);
    else
      match = table(max (1, ind)) == y;
    endif
  else
    match = false (size (y));
  endif

  if (mopt)
    ind(! match) = 0;
  elseif (bopt)
    ind = match;
  endif
endfunction




