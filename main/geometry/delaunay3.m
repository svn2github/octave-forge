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
## A matrix of size [n, 4] is returned. Each row contains a 
## set of tetrahedron which are
## described by the indices to the data point vectors (x,y,z).
## @end deftypefn
## @seealso{delaunay,delaunayn}

## Author:	Kai Habel <kai.habel@gmx.de>

function tetr = delaunay3 (x,y,z)

  if (nargin != 3)
    usage ("delaunay(x,y,z)");
  endif

  if (is_vector(x) && is_vector(y) &&is_vector(z) && \
      (length(x) == length(y)) && (length(x) == length(z))) 
    tetr = delaunayn([x(:),y(:),z(:)]);
  endif

endfunction
