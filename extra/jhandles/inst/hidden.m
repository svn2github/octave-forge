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

function hidden (mode)

  if (nargin == 0)
    mode = "swap";
  elseif (nargin > 1)
    print_usage ();
  endif

  for h = get (gca (), "children");
    htype = lower (get (h, "type"));
    if (strcmp (htype, "surface"))
      fc = get (h, "facecolor");
      if ((! ischar (fc) && is_white (fc)) || (ischar (fc) && strcmp (fc, "none")))
        switch (mode)
        case "on"
          set(h, "facecolor", "w");
        case "off"
          set(h, "facecolor", "none");
        case "swap"
          if (ischar (fc))
            set(h, "facecolor", "w");
          else
            set(h, "facecolor", "none");
          endif
        endswitch
      endif
    endif
  endfor

endfunction

function [ ret ] = is_white (color)

  r = color.getRed ();
  g = color.getGreen ();
  b = color.getBlue ();
  ret = (r == 255 && g == 255 && b == 255);

endfunction
