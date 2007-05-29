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

function shading (varargin)

  if (nargin == 1)
    ax = gca ();
    mode = varargin{1};
  elseif (nargin == 2)
    ax = varargin{1};
    mode = varargin{2};
  else
    print_usage ();
  endif

  if (! ishandle (ax))
    error ("invalid axes handle");
  endif

  for h = get (ax, "children")
    htype = lower (get (h, "type"));
    if (strcmp (htype, "surface") || strcmp (htype, "patch"))
      switch (mode)
      case "interp"
        set (h, "facecolor", "interp", "edgecolor", "none");
      case "flat"
        set (h, "facecolor", "flat", "edgecolor", "none");
      case "faceted"
        set (h, "facecolor", "flat", "edgecolor", "k");
      case "mesh"
        set(h, "facecolor", "w", "edgecolor", "flat");
      endswitch
    endif
  endfor

endfunction
