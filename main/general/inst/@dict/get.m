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

## -*- texinfo -*-
## @deftypefn{Function File} {} get (d, key, defv)
## Queries for the values of specified key(s). Unlike indexing, however,
## this does not throw an error if a key is missing but rather substitutes
## a default value. If @var{key} is a cell array, @var{defv} should be either
## a cell array of the same shape as @var{key}, or a singleton cell.
## Non-cell values will be converted to a singleton cell.
## @end deftypefn

function val = get (d, key, defv = [])
  if (nargin < 2 || nargin > 3)
    print_usage ();
  endif

  lookup = __lookup_compat__; # FIXME: remove when 3.3.x is required.

  if (ischar (key))
    i = lookup (d.keys, key, "m");
    if (i)
      val = d.values{i};
    else
      val = defv;
    endif
  elseif (iscellstr (key))
    i = lookup (d.keys, key, "m");
    mask = i != 0;
    val(mask) = d.values{i(mask)};
    if (! iscell (defv))
      defv = {defv};
    endif
    val = merge (mask, val, defv);
  else
    error ("invalid key value");
  endif
endfunction

