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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## -*- texinfo -*-
## @deftypefn {Loadable Function} {@var{tri}=} delaunay (@var{x}, @var{y})
## @deftypefnx {Loadable Function} {@var{tri}=} delaunay (@var{x}, @var{y}, @var{opt})
## The return matrix of size [n, 3] contains a set triangles which are
## described by the indices to the data point x and y vector.
## The triangulation satisfies the Delaunay circumcircle criterion.
## No other data point is in the circumcircle of the defining triangle.
##
## A third optional argument, which must be a string, contains extra options
## passed to the underlying qhull command.  See the documentation for the 
## Qhull library for details.
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

function ret = delaunay (x,y,opt)

  if ((nargin != 2) && (nargin != 3))
    usage ("delaunay(x,y[,opt])");
  endif

  if (isvector(x) && isvector(y) && (length(x) == length(y)) )
    if (nargin == 2)
      tri = delaunayn([x(:), y(:)]);
    elseif ischar(opt)
      tri = delaunayn([x(:), y(:)], opt);
    else
      error("third argument must be a string");
    endif
  else
    error("first two input arguments must be vectors of same size");
  endif

  if nargout == 0
    x = x(:).'; y = y(:).';
    X = [ x(tri(:,1)); x(tri(:,2)); x(tri(:,3)); x(tri(:,1)) ];
    Y = [ y(tri(:,1)); y(tri(:,2)); y(tri(:,3)); y(tri(:,1)) ];
    plot(X,Y,'b;;',x,y,'r*;;');
  else
    ret = tri;
  endif


endfunction
