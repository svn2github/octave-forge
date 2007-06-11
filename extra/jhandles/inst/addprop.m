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

function addprop (h, pname, ptype, varargin)

  if (ishandle (h))
    if (ischar (pname))
      if (ischar (ptype))
        __jhandles_add_property (h, pname, ptype, varargin{:});
      else
        error ("invalid property type");
      endif
    else
      error ("invalid property name");
    endif
  else
    error ("invalid handle");
  endif

endfunction
