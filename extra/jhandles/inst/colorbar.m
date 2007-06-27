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

function [ h ] = colorbar (varargin)

  ax = [];
  
  if (length (varargin) > 1)
    idx = find (strcmpi ({varargin{1:2:end}}, "peer"));
    if (! isempty (idx))
      idx = 2*(idx-1)+1;
      ax = varargin{idx+1};
      varargin(idx) = [];
      varargin(idx) = [];
    endif
  endif

  if (isempty (ax))
    ax = gca ();
  endif

  cflag = true;
  if (length (varargin) > 0 && ischar (varargin{1}) && strcmp (varargin{1}, "off"))
    cflag = false;
  endif

  tmp = __jhandles_go_colorbar (ax, cflag);
  if (cflag && length (varargin) > 0)
    set (tmp, varargin{:});
  else
    __request_drawnow__;
  endif

  if (nargout > 0)
    if (cflag)
      h = tmp;
    else
      h = [];
    endif
  endif

endfunction
