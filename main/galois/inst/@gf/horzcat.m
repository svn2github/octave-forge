## Copyright (C) 2011 David Bateman
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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} horzcat (@dots{x})
## Concatenate Galois arrays.
## @end deftypefn

function y = horzcat (varargin)
  [varargin{:}] = promote_and_check (varargin {:});
  y = varargin{1};;
  args = cell (1, nargin);
  for i = 1 : nargin
    args{i} = varargin{i}._x;
  endfor
  y._x = horzcat (args {:});
endfunction

%!assert([gf(0,3), gf(1,3)], gf([0,1],3))
%!assert(horzcat(gf(0,3),gf(1,3)), gf([0,1],3))
