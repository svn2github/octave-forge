## Copyright (C) 1999 David M. Doolin 
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

## A = polyarea(X,Y)
##
## Determines area of a polygon by triangle method.
##
## input:
##   polygon:  x, y form vertex pairs, one polygon per column.
##
## output:
##   area:  Area of polygons.
##
## todo:  Add moments for centroid, etc.
##
## bugs and limitations:  
##        Probably ought to be an optional check to make sure that
##        traversing the vertices doesn't make any sides cross 
##        (Is simple closed curve the technical definition of this?). 

## Author: doolin $  doolin@ce.berkeley.edu
## Date: 1999/04/14 15:52:20 $
## Modified-by: 
##    2000-01-15 Paul Kienzle <pkienzle@kienzle.powernet.co.uk>
##    * use matlab compatible interface
##    * return absolute value of area so traversal order doesn't matter

function a = polyarea (x, y)
  if (nargin != 2)
    usage ("polyarea (x, y)");
  elseif any (size(x) != size(y))
    error ("polyarea: x and y must have the same shape");
  else
    a = abs ( sum (x .* shift (y,-1))  - sum (y .* shift (x, -1)) ) / 2;
  endif
endfunction
