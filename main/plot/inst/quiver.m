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
## Software Foundation, 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} quiver (@var{x}, @var{y}, @var{u}, @var{v})
## @deftypefnx {Function File} {} quiver (@var{u}, @var{v})
## Plot the @code{(@var{u}, @var{v})} components of a vector field in 
## an @code{(@var{x}, @var{y})} meshgrid. If the grid is uniform, you can 
## specify @var{x} and @var{y} as vectors.
##
## If @var{x} and @var{y} are undefined they are assumed to be
## @code{(1:@var{m}, 1:@var{n})} where @code{[@var{m}, @var{n}] = 
## size(@var{u})}.
##
## @group
## @example
##   [x,y] = meshgrid(1:2:20);
##   quiver(x,y,sin(2*pi*x/10),sin(2*pi*y/10))
## @end example
## @end group
##
## @seealso{plot, semilogx, semilogy, loglog, polar, mesh, contour,
##           bar, stairs, replot, xlabel, ylabel, title}
## @end deftypefn

## Author: Roberto A. F. Almeida <roberto@calvin.ocfis.furg.br>
## Rewrite: Paul Kienzle <pkienzle@users.sf.net>

function quiver (x, y, u, v)

  if nargin != 2 && nargin != 4
    usage ("quiver ([x, y,] u, v)");
  endif

  if nargin < 4
    u = x; v = y; x = 1:columns(u); y= 1:rows(u);
  endif

  if isvector(x) && isvector(y) && !isvector(u)
    [nr, nc] = size(u);
    if (length(x) != nc || length(y) != nr)
      error ("quiver: x, y vectors must have correct length");
    endif
    [x,y] = meshgrid(x,y);
  endif

  if (any (size(v) != size(u) | size(x) != size(u) | size(y) != size(u)))
    error ("quiver: x, y, u, v must have the same shape");
  endif

  M = [ x(:), y(:), u(:), v(:) ];
  __gnuplot_plot__ M w vec t ""
endfunction

%!demo
%! [x,y] = meshgrid(1:2:20);
%! quiver(x,y,sin(2*pi*x/10),sin(2*pi*y/10))

%!demo
%! axis('equal');
%! x=linspace(0,3,80); y=sin(2*pi*x); theta=2*pi*x+pi/2;
%! quiver(x,y,sin(theta)/10,cos(theta)/10);
%! hold on; plot(x,y,';;'); hold off;
