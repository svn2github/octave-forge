## Copyright (C) 2000  Kai Habel
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

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{C}, @var{F}] =} voronoin (@var{pts})
## computes n- dimensinal voronoi facets.  The input matrix @var{pts} 
## of size [n, dim] contains n points of dimension dim.
## @var{C} contains the points of the voronoi facets. The list @var{F}
## contains for each facet the indices of the voronoi points.   
## @end deftypefn
## @seealso{voronoin, delaunay, convhull} 

## Author: Kai Habel <kai.habel@gmx.de>
## First Release: 20/08/2000

function [C, F] = voronoin (pts)

	if (nargin != 1)
		usage ("voronoin (pts)")
	endif
	
	[np,dims] = size (pts);
	if (np > dims)
		[C, F, infi] = __voronoi__ (pts);
	else
		error ("voronoin: number of points must be greater than their dimension")
	endif
endfunction
