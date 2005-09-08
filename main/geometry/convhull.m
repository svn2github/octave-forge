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
## @deftypefn {Loadable Function} {@var{H} =} convhull (@var{x}, @var{y})
## @deftypefnx {Loadable Function} {@var{H} =} convhull (@var{x}, @var{y}, @var{opt})
## Returns the index vector to the points of the enclosing convex hull.  The
## data points are defined by the x and y vectors.
##
## A third optional argument, which must be a string, contains extra options
## passed to the underlying qhull command.  See the documentation for the 
## Qhull library for details.
##
## @end deftypefn
## @seealso{delaunay, convhulln}

## Author:	Kai Habel <kai.habel@gmx.de>

function H = convhull (x,y,opt)

  if ((nargin != 2) && (nargin != 3))
    usage ("convhull(x,y[,opt])");
  endif

  if (isvector(x) && isvector(y) && (length(x) == length(y)) )
    if (nargin == 2)
      i = convhulln([x(:), y(:)]);
    elseif ischar(opt)
      i = convhulln([x(:), y(:)], opt);
    else
      error("third argument must be a string");
    endif
  else
    error("first two input arguments must be vectors of same size");
  endif

  n = rows(i);
  i=i'(:);
  H = zeros(n + 1,1);

  H(1) = i(1);
  next_i = i(2);
  i(2) = 0;
  for k = 2:n
    next_idx = find (i == next_i);

    if (rem (next_idx, 2) == 0)
      H(k) = i(next_idx);
      next_i = i(next_idx - 1);
      i(next_idx - 1) = 0;
    else
      H(k) = i(next_idx);
      next_i = i(next_idx + 1);
      i(next_idx + 1) = 0;
    endif
  endfor

  H(n+1)=H(1);
endfunction
