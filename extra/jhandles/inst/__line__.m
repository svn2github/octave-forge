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

function [ h ] = __line__ (ax, varargin)

  if (nargin > 2)
    if (ischar (varargin{1}))
      xdata = [];
      ydata = [];
      zdata = [];
      others = {};
      for k = 1:length (varargin)
        switch tolower (varargin{k})
          case "xdata"
            xdata = varargin{k+1};
          case "ydata"
            ydata = varargin{k+1};
          case "zdata"
            zdata = varargin{k+1};
          otherwise
            others{end+1} = varargin{k};
            others{end+1} = varargin{k+1};
        endswitch
      endfor
    else
      xdata = varargin{1};
      ydata = varargin{2};
      index = 3;
      if (nargin > 3 && isnumeric (varargin{3}))
        zdata = varargin{3};
        index = index+1;
      else
        zdata = [];
      endif
      others = {varargin{index:end}};
    endif

    j1 = java_convert_matrix (1);
    j2 = java_unsigned_conversion (1);

    unwind_protect
      obj = java_new ("org.octave.graphics.LineObject", __get_object__ (ax), xdata, ydata, zdata);
    unwind_protect_cleanup
      java_convert_matrix (j1);
      java_unsigned_conversion (j2);
    end_unwind_protect

    h = obj.getHandle ();

    if (length (others) > 0)
      set(h, others{:});
    else
      __request_drawnow__;
    endif
	obj.validate ();
  else
    print_usage ();
  endif

endfunction
