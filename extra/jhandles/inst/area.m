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

function [ h ] = area (varargin)

  if (nargin > 0)
    idx = 1;
    ax = [];
    x = y = [];
    bv = 0;
    args = {};
    # check for axes parent
    if (ishandle (varargin{idx}) && strcmp (get (varargin{idx}, "Type"), "axes"))
      ax = varargin{idx};
      idx++;
    endif
    # check for (X) or (X,Y) arguments and possible base value
    if (nargin >= idx && ismatrix (varargin{idx}))
      y = varargin{idx};
      idx++;
      if (nargin >= idx)
        if (isscalar (varargin{idx}))
          bv = varargin{idx};
          idx++;
        elseif (ismatrix (varargin{idx}))
          x = y;
          y = varargin{idx};
          idx++;
          if (nargin >= idx && isscalar (varargin{idx}))
            bv = varargin{idx};
            idx++;
          endif
        endif
      endif
    else
      print_usage ();
    endif
    # check for additional args
    if (nargin >= idx)
      args = {varargin{idx:end}};
    endif
    # create areaseries object
    if (isempty (ax))
      ax = gca ();
    else
      axes (ax);
    endif
    newplot ();
	if (isempty (x))
      x = repmat ([1:size(y, 1)]', 1, size(y, 2));
	endif
    tmp = __jhandles_go_areaseries (ax, x, y, bv, args{:});
    if (nargout > 0)
      h = tmp;
    endif
  else
    print_usage ();
  endif

endfunction
