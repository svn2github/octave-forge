## Copyright (C) 2000 Paul Kienzle
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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## pcolor([x, y,] c)
## Displays an array of color patches with color defined by c and
## coordinates defined by x,y.  The polygon: 
##   [x(i,j),y(i,j) x(i+1,j),y(i+1,j) x(i+1,j+1),y(i+1,j+1) x(i,j+1),y(i,j+1)]
## uses color c(i,j), or uses a bilinear interpolation of colors at the
## four corners.
##
## If x,y are not given, assume they would define a uniform grid.
## This is all that is presently implemented.
function pcolor(varargin)
  if nargin > 1
    warning("pcolor: x,y ignored.");
  endif
  imagesc(varargin{:});
endfunction
