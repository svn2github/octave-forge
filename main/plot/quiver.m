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
## Plot the (u,v) components of a vector field in a (x,y) meshgrid.
##
## You can try:
##
##   a = b = 1:10;
##   [x,y] = meshgrid(a,b);
##   u = rand (10,10);
##   v = rand (10,10);
##   quiver(x,y,u,v)
##
## See also: plot, semilogx, semilogy, loglog, polar, mesh, contour,
##           bar, stairs, gplot, gsplot, replot, xlabel, ylabel, title

## Author: Roberto A. F. Almeida <roberto@calvin.ocfis.furg.br>
## 2001-02-25 Paul Kienzle
##     * change parameter order to correspond to matlab
##     * allow vector x,y,  defaulting to 1:n, 1:m for mxn u
##     * vectorize

## TODO: use gnuplot 'vector' style instead of setting arrows one at a time
function quiver (x, y, u, v)

  if (nargin != 2 && nargin != 4)
    usage ("quiver (x, y, u, v)");
  endif

  if (nargin == 2)
    u = x; v = y; x = 1:columns(u); y= 1:rows(u);
  endif

  if (any(size(u)!=size(v)))
    error ("quiver: u, v must have the same shape.");
  endif

  if is_vector(x) && is_vector(y)
    [nr, nc] = size(u);
    if (length(x) != nc || length(y) != nr)
      error ("quiver: x, y vectors must have correct length");
    endif
    [x,y] = meshgrid(x,y);
  endif

  if (any (size(x) != size(u) | size(y) != size(u)))
    error ("quiver: x, y must have the same shape as u, v");
  endif


  ## Calculating the grid limits.
  
  minx = min (min (x));
  maxx = max (max (x));
  miny = min (min (y));
  maxy = max (max (y));
  
  max_arrow = max ( [max(max (u)) , max(max (v)) , ...
		     abs(min (min (u))) , abs(min (min (v)))] );
  border = max_arrow * 1.2;
  
  limits = [ minx - border, maxx + border, miny - border, maxy + border ];

  axis (limits);
  
  
  ## Ok, now plot the arrows.
  
  gset noarrow;
  gplot 0 title "";
  
  command = sprintf ("gset arrow from %f,%f to %f,%f\n", \
		     [ x(:)'; y(:)'; x(:)'+u(:)'; y(:)'+v(:)' ]);
  eval ( [ "if 1\n", command, "\nendif" ] );
  
  replot;
      
endfunction
