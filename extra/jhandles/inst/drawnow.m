## Copyright (C) 2007 Michael Goffioul
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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301  USA

function drawnow (term, file)

  h = get(0, 'currentfigure');
  if (! isempty (h) && h != 0 && ishandle (h))
    fig = __get_object__ (h);
    if (nargin == 0)
      fig.redraw ();
    elseif (nargin == 2)
      elt = cellstr (split (term, " "));
      switch elt{1}
      case {"png"}
        fig.print (elt{1}, file);
      otherwise
        error ("unsupported output format: %s", term);
      endswitch
    endif
  endif

endfunction
