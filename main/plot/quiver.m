## Copyright (C) 2000 John W. Eaton
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## usage: quiver (x, y, u, v)
## usage: quiver (u, v)
##
## Plot the (u,v) components of a vector field in an (x,y) meshgrid.
## If the grid is uniform, you can specify x and y as vectors.
## You can plot vectors and lines simultaneously, but the lines
## must be plotted with style '-' even though that is the default.
##
## Use clf after you are done plotting vector fields.
##
## Example
##
##   [x,y] = meshgrid(1:2:20);
##   quiver(x,y,sin(2*pi*x/10),sin(2*pi*y/10))
##
## See also: plot, semilogx, semilogy, loglog, polar, mesh, contour,
##           bar, stairs, gplot, gsplot, replot, xlabel, ylabel, title

## Author: Roberto A. F. Almeida <roberto@calvin.ocfis.furg.br>
## 2001-02-25 Paul Kienzle
##     * change parameter order to correspond to matlab
##     * allow vector x,y,  defaulting to 1:n, 1:m for mxn u
##     * vectorize

function quiver (x, y, u, v)

  if (nargin != 2 && nargin != 4)
    usage ("quiver (x, y, u, v)");
  endif

  if (nargin == 2)
    u = x; v = y; x = 1:columns(u); y= 1:rows(u);
  endif

  if is_vector(x) && is_vector(y) && !is_vector(u)
    [nr, nc] = size(u);
    if (length(x) != nc || length(y) != nr)
      error ("quiver: x, y vectors must have correct length");
    endif
    [x,y] = meshgrid(x,y);
  endif

  if (any (size(v) != size(u) | size(x) != size(u) | size(y) != size(u)))
    error ("quiver: x, y, u, v must have the same shape");
  endif

  data = [ x(:), y(:), u(:), v(:) ];
  gset style data vector
  gplot data title ""
endfunction

%!demo
%! [x,y] = meshgrid(1:2:20);
%! quiver(x,y,sin(2*pi*x/10),sin(2*pi*y/10))

%!demo
%! axis('equal');
%! x=linspace(0,3,80); y=sin(2*pi*x); theta=2*pi*x+pi/2;
%! quiver(x,y,sin(theta)/10,cos(theta)/10);
%! hold on; plot(x,y,'-;;'); hold off;

%!demo
%! % Reset the graph after plotting quivers
%! clf
