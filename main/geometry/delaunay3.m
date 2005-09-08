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
## @deftypefn {Loadable Function} {@var{T} =} delaunay3 (@var{x}, @var{y}, @var{z})
## @deftypefnx {Loadable Function} {@var{T} =} delaunay3 (@var{x}, @var{y}, @var{z}, @var{opt})
## A matrix of size [n, 4] is returned. Each row contains a 
## set of tetrahedron which are
## described by the indices to the data point vectors (x,y,z).
##
## A fourth optional argument, which must be a string, contains extra options
## passed to the underlying qhull command.  See the documentation for the 
## Qhull library for details.
## @end deftypefn
## @seealso{delaunay,delaunayn}

## Author:	Kai Habel <kai.habel@gmx.de>

function tetr = delaunay3 (x,y,z,opt)

  if ((nargin != 3) && (nargin != 4))
    usage ("delaunay3(x,y,z[,opt])");
  endif

  if (isvector(x) && isvector(y) &&isvector(z) && \
      (length(x) == length(y)) && (length(x) == length(z)))
    if (nargin == 3)
      tetr = delaunayn([x(:),y(:),z(:)]);
    elseif ischar(opt)
      tetr = delaunayn([x(:),y(:),z(:)], opt);
    else
      error("fourth argument must be a string");
    endif
  else
    error("first three input arguments must be vectors of same size");
  endif

endfunction
