## Copyright (C) 2006 Frederick (Rick) A Niles, Søren Hauberg
##
## This file is intended for use with Octave.
##
## This file can be redistriubted under the terms of the GNU General
## Public License.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{IN}, @var{ON}] = } inpolygon (@var{X}, @var{Y}, @var{xv}, @var{xy})
##
## For a polygon defined by (@var{xv},@var{yv}) points, determine if the
## points (X,Y) are inside or outside the polygon.  @var{X}, @var{Y},
## @var{IN} must all have the same dimensions. The optional output @var{ON}
## will give point on the polygon. 
##
## @end deftypefn

## Author: Frederick (Rick) A Niles <niles@rickniles.com>
## Created: 14 November 2006

## Vectorized by Søren Hauberg <soren@hauberg.org>

## The method for determining if a point is in in a polygon is based on
## the algorithm shown on
## http://local.wasp.uwa.edu.au/~pbourke/geometry/insidepoly/ and is
## credited to Randolph Franklin.

function [IN, ON] = inpolygon (X, Y, xv, yv)

  if ( !(isreal(X) && isreal(Y) && ismatrix(Y) && ismatrix(Y) && size_equal(X, Y)) )
    error( "inpolygon: first two arguments must be real matrices of same size");
  elseif ( !(isreal(xv) && isreal(yv) && isvector(xv) && isvector(yv) && size_equal(X, Y)) )
    error( "inpolygon: last two arguments must be real vectors of same size");
  endif

  npol = length(xv);
  
  ## Disable warning caused by divede-by-zero
  dbz = warning("query", "Octave:divide-by-zero");
  warning("off", "Octave:divide-by-zero");
  
  unwind_protect
    IN = zeros (size(X), "logical");
    j = npol;
    for i = 1:npol
      idx = ((((yv(i) <= Y) & (Y < yv(j))) |
             ((yv(j) <= Y) & (Y < yv(i)))) &
            (X < (xv(j) - xv(i)) .* (Y - yv(i)) ./ (yv(j) - yv(i)) + xv(i)));
      IN(idx) = !IN(idx);
      j = i;
    endfor
  
    if (nargout == 2)
      ON = zeros (size(X), "logical");
      j = npol;
      for i=1:npol
        a = (yv(i)-yv(j))./(xv(i)-xv(j));
        idx = ( ( ((Y >= yv(i)) & (Y <= yv(j))) | ((Y >= yv(j)) & (Y <= yv(i))) ) &
                ( ((X >= xv(i)) & (X <= xv(j))) | ((X >= xv(j)) & (X <= xv(i))) ) &
                ( (Y == a.*(X-xv(i)) + yv(i)) | isinf(a) ) );
        ON(idx) = true;
        j = i;
      endfor
    endif
  unwind_protect_cleanup
    warning(dbz.state, "Octave:divide-by-zero");
  end_unwind_protect
endfunction

%!demo
%!  xv=[ 0.05840, 0.48375, 0.69356, 1.47478, 1.32158, \
%!       1.94545, 2.16477, 1.87639, 1.18218, 0.27615, \
%!       0.05840 ];
%!  yv=[ 0.60628, 0.04728, 0.50000, 0.50000, 0.02015, \
%!       0.18161, 0.78850, 1.13589, 1.33781, 1.04650, \
%!       0.60628 ];
%! xa=[0:0.1:2.3];
%! ya=[0:0.1:1.4];
%! [x,y]=meshgrid(xa,ya);
%! [IN,ON]=inpolygon(x,y,xv,yv);
%! 
%! inside=IN & !ON;
%! plot(xv,yv)
%! hold on
%! plot(x(inside),y(inside),"@g")
%! plot(x(~IN),y(~IN),"@m")
%! plot(x(ON),y(ON),"@b")
%! hold off
%! disp("Green points are inside polygon, magenta are outside,");
%! disp("and blue are on boundary.");

%!demo
%!  xv=[ 0.05840, 0.48375, 0.69356, 1.47478, 1.32158, \
%!       1.94545, 2.16477, 1.87639, 1.18218, 0.27615, \
%!       0.05840, 0.73295, 1.28913, 1.74221, 1.16023, \
%!       0.73295, 0.05840 ];
%!  yv=[ 0.60628, 0.04728, 0.50000, 0.50000, 0.02015, \
%!       0.18161, 0.78850, 1.13589, 1.33781, 1.04650, \
%!       0.60628, 0.82096, 0.67155, 0.96114, 1.14833, \
%!       0.82096, 0.60628];
%! xa=[0:0.1:2.3];
%! ya=[0:0.1:1.4];
%! [x,y]=meshgrid(xa,ya);
%! [IN,ON]=inpolygon(x,y,xv,yv);
%! 
%! inside=IN & ~ ON;
%! plot(xv,yv)
%! hold on
%! plot(x(inside),y(inside),"@g")
%! plot(x(~IN),y(~IN),"@m")
%! plot(x(ON),y(ON),"@b")
%! hold off
%! disp("Green points are inside polygon, magenta are outside,");
%! disp("and blue are on boundary.");

