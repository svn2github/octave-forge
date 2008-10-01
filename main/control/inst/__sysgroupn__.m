## Copyright (C) 1996, 1998, 2000, 2004, 2005, 2007
##               Auburn University. All rights reserved.
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## Undocumented internal function.

## -*- texinfo -*-
## @deftypefn {Function File} {} __sysgroupn__ (@var{names})
## Locate and mark duplicate names
## inputs:
## names: list of signal names
## kind: kind of signal name (used for diagnostic message purposes only)
## outputs:
## returns names with unique suffixes added; diagnostic warning
## message is printed to inform the user of the new signal name
##
## used internally in sysgroup and elsewhere.
## @end deftypefn

function names = __sysgroupn__ (names, kind)

  ## check for duplicate names
  l = length (names);
  ii = 1;
  while (ii <= l-1)
    st1 = names{ii};
    jj = ii+1;
    while (jj <= l)
      st2 = names{jj};
      if (strcmp (st1, st2))
        warning ("sysgroup: %s name(%d) = %s name(%d) = %s",
		 kind, ii, kind, jj, st1);
        strval = sprintf ("%s_%d", st2, jj)
        names{jj} = strval;
        warning ("sysgroup:     changed %s name %d to %s", kind, jj, strval);
        ## restart the check (just to be sure there's no further duplications)
        ii = 0;
	jj = l;
      endif
      jj++;
    endwhile
    ii++;
  endwhile
endfunction
