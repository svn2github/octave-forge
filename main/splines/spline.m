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
## @deftypefn {Function File} {@var{pp} = } spline (@var{x}, @var{y})
## @deftypefnx {Function File} {@var{yi} = } spline (@var{x}, @var{y}, @var{xi})
## cubic spline interpolation
##
## @seealso{ppval, csapi, csape}
## @end deftypefn


## Author:  Kai Habel <kai.habel@gmx.de>
## Date: 3. dec 2000
## 2001-02-08 Paul Kienzle
##   * copied from csapi.m

function ret = spline (x, y, xi)

  ret = csape (x, y, 'not-a-knot');

  if (nargin == 3)
    ret = ppval (ret, xi);
  endif

endfunction

%!demo
%! x = 0:10; y = sin(x);
%! xspline = 0:0.1:10; yspline = spline(x,y,xspline);
%! title("spline fit to points from sin(x)");
%! plot(xspline,sin(xspline),";original;",...
%!      xspline,yspline,"-;interpolation;",...
%!      x,y,"+;interpolation points;");
%! %--------------------------------------------------------
%! % confirm that interpolated function matches the original

%!shared x,y
%! x = [0:10]'; y = sin(x);
%!assert (spline(x,y,x), y);
%!assert (spline(x,y,x'), y');
%!assert (spline(x',y',x'), y');
%!assert (spline(x',y',x), y);
%!assert (isempty(spline(x',y',[])));
%!assert (isempty(spline(x,y,[])));
%!assert (spline(x,[y,y],x), [spline(x,y,x),spline(x,y,x)])
