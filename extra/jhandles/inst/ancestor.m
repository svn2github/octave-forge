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

function [ p ] = ancestor (h, type, toplevel)

  if (nargin == 2 || nargin == 3)
    p = [];
    if (ischar (type))
      type = { type };
    endif
    if (iscellstr (type))
      look_first = true;
      if (nargin == 3)
        if (ischar (toplevel) && strcmp (toplevel, "toplevel"))
          look_first = false;
        else
          error ("3rd argument must be `toplevel'");
        endif
      endif
      while (true)
        if (isempty (h) || ! ishandle (h))
          break
        endif
        if (any (strcmpi (get (h, "type"), type)))
          p = h;
          if (look_first)
            break
          endif
        endif
		h = get (h, "Parent");
      endwhile
    else
      error ("`type' argument must be a string or cell array of strings");
    endif
  else
    print_usage ();
  endif

endfunction
