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
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## Surface + contour plot.  This needs gnuplot 3.8i to work properly.
function surfc(varargin)
   try
      gset pm3d at s ftriangles hidden3d 100;
      gset line style 100 lt 5 lw 0.5;
      gset nohidden3d;
      gset nosurf;
   catch
   end
   meshc(varargin{:});
