## Copyright (C) 2011 David Bateman
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} display (@var{g})
## Displays a Galois array.
## @end deftypefn

function display (g)

  if (!isempty (inputname(1)))
    fprintf("%s = \n",inputname(1));
  endif
  if (g._m == 1)
    fprintf ("GF(2) array.");
  else
    fprintf ("GF(2^%d) array. Primitive Polynomial = ", g._m);
    p = g._prim_poly;
    m = g._m;
    first = true;
    for i = m + 1 : -1 : 1
      if (bitget (p, i) != 0)
	if (i > 1)
	  if (first)
	    first = false;
	    fprintf("D")
	  else
	    fprintf("+D")
	  endif
	  if (i != 2)
	    fprintf("^%d", i - 1);
	  endif
	else
	  if (first)
	    first = false;
	    fprintf("1");
	  else
	    fprintf("+1");
	  endif
	endif
      endif
    endfor
    fprintf (" (decimal %d)", p);
  endif
  fprintf("\n\nArray elements = \n\n");
  disp (g._x);
  fprintf("\n");
endfunction
