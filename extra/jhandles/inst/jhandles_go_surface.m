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

function [ h ] = jhandles_go_surface (ax, varargin)

  x = [];
  y = [];
  z = [];
  others = {};
  args = varargin;

  for k = 1:2:length (args)
    switch args{k}
      case "xdata"
        x = args{k+1};
      case "ydata"
        y = args{k+1};
      case "zdata"
        z = args{k+1};
      otherwise
        others{end+1} = args{k};
        others{end+1} = args{k+1};
    endswitch
  endfor

  if (isvector (x) && isvector (y))
    [x,y] = meshgrid (x, y);
  endif

  ax_obj = __get_object__ (ax);
  surf_obj = java_new ("org.octave.graphics.SurfaceObject", ax_obj, ...
    mat2java (x), mat2java (y), mat2java (z));
  surf_obj.set ("facecolor", "w");
  surf_obj.set ("edgecolor", "flat");
  surf_obj.validate ();

  tmp = surf_obj.getHandle ();
  
  if (length (others) > 0)
    set (tmp, others{:});
  else
    __request_drawnow__;
  endif

  if (nargout > 0)
    h = tmp;
  endif

endfunction
