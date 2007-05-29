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

function [ h ] = stem (varargin)

  newplot ();

  if (nargin > 1)
    xdata = varargin{1};
    ydata = varargin{2};
    index = 3;
    if (nargin > 2 && isnumeric (varargin{3}))
      zdata = varargin{3};
      index = index+1;
    else
      zdata = [];
    endif
    ax = [];
    if (index <= length (varargin))
      for k = index:2:length(varargin)
        if (ischar (varargin{k}))
          if (strcmp (lower (varargin{k}), "parent"))
            ax = varargin{k+1};
          endif
        else
          error ("invalid property name, expected a string");
        endif
      endfor
    endif
    if (isempty (ax))
      ax = gca;
    endif
    obj = java_new ("org.octave.graphics.StemseriesObject", __get_object__ (ax), xdata, ydata, zdata);
    h = obj.getHandle ();
    if (index <= length (varargin))
      set(h, varargin{index:end});
    else
      __request_drawnow__;
    endif
    obj.validate ();
  else
    print_usage ();
  endif

endfunction
