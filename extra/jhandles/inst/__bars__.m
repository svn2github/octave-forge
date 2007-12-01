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

function tmp = __bars__ (h, vertical, x, y, xb, yb, width, group, have_color_spec, varargin)

  ycols = columns (y);
  ny = rows (y);
  newargs = varargin;
  if (group)
    layout = "grouped";
  else
    layout = "stacked";
  endif
  if (vertical)
    hmode = "off";
  else
    hmode = "on";
  endif
  tmp = [];

  for i = 1 : ycols
    # group object creation and initialization
    bs = hggroup (h);
    addprop (bs, "CDataMapping", "radio", "scaled|direct", "scaled", "hidden");
    set (bs, "CLimInclude", "on");
    # low-level patch object creation
    if (vertical)
      if (have_color_spec)
        p = patch (bs, xb(:,:,i), yb(:,:,i), newargs {:});
      else
        p = patch (bs, xb(:,:,i), yb(:,:,i), "cdata", i * ones(1, ny), "facecolor", "flat", newargs {:});
      endif
    else
      if (have_color_spec)
        p = patch (bs, yb(:,:,i), xb(:,:,i), newargs {:});
      else
        p = patch (bs, yb(:,:,i), xb(:,:,i), "cdata", i * ones(1, ny) , "facecolor", "flat", newargs {:});
      endif
    endif
    # high-level properties creation
    pp = get (p);
    addprop (bs, "XData", "doublearray", x);
    addprop (bs, "YData", "doublearray", y(:,i));
    addprop (bs, "BarWidth", "double", width);
    addprop (bs, "BarLayout", "radio", "grouped|stacked", layout);
    addprop (bs, "EdgeColor", "colorradio", "flat|interp|none", get (p, "EdgeColor"));
    addprop (bs, "FaceColor", "colorradio", "flat|interp|none", get (p, "FaceColor"));
    addprop (bs, "BarGroup", "handle", "hidden");
    addprop (bs, "Horizontal", "radio", "on|off", hmode);
    # store handle
    tmp = [tmp, bs];
  endfor

endfunction
