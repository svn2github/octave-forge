## Copyright (C) 1999,2000  Kai Habel
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
## @deftypefn {Loadable Function} {@var{tri}=} delaunay (@var{x}, @var{y})
## The return matrix of size [n, 3] contains a set triangles which are
## described by the indices to the data point x and y vector.
## The triangulation satisfies the Delaunay circumcircle criterion.
## No other data point is in the circumcircle of the defining triangle.
##
## @example
## x = rand(1,10);
## y = rand(size(x));
## T = delaunay(x,y);
## X = [ x(T(:,1)); x(T(:,2)); x(T(:,3)); x(T(:,1)) ];
## Y = [ y(T(:,1)); y(T(:,2)); y(T(:,3)); y(T(:,1)) ];
## axis([0,1,0,1]);
## plot(X,Y,'b;;',x,y,'r*;;');
## @end example
## @end deftypefn
## @seealso{voronoi, delaunay3, delaunayn}

## Author:	Kai Habel <kai.habel@gmx.de>

function tri = delaunay (x,y)

  if (nargin != 2)
    usage ("delaunay(x,y)");
  endif

  if (is_vector(x) && is_vector(y) && (length(x) == length(y)) )
    tri = delaunayn([x(:), y(:)]);
  else
    error("input arguments must be vectors of same size");
  endif

endfunction
