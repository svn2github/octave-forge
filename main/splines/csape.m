## Copyright (C) 2000,2001  Kai Habel
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
## @deftypefn {Function File} {@var{pp} = } csape (@var{x}, @var{y}, @var{cond}, @var{valc})
## cubic spline interpolation with various end conditions.
## creates the pp-form of the cubic spline.
##
## the following end conditions as given in @var{cond} are possible. 
## @table @asis
## @item 'complete'    
##    match slopes at first and last point as given in @var{valc}
## @item 'not-a-knot'     
##    third derivatives are continuous at the second and second last point
## @item 'periodic' 
##    match first and second derivative of first and last point
## @item 'second'
##    match second derivative at first and last point as given in @var{valc}
## @item 'variational'
##    set second derivative at first and last point to zero (natural cubic spline)
## @end table
##
## @seealso{ppval, spline}
## @end deftypefn

## Author:  Kai Habel <kai.habel@gmx.de>
## Date: 23. nov 2000
## Algorithms taken from G. Engeln-Muellges, F. Uhlig:
## "Numerical Algorithms with C", Springer, 1996

## Paul Kienzle, 19. feb 2001,  csape supports now matrix y value

function pp = csape (x, y, cond, valc)

  x = x(:);
  n = length(x);

  transpose = (columns(y) == n);
  if (transpose) y = y'; endif

  a = y;
  b = c = zeros (size (y));
  h = diff (x);
  idx = ones (columns(y),1);

  if (nargin < 3 || strcmp(cond,"complete"))
    # specified first derivative at end point
    if (nargin < 4)
      valc = [0, 0];
    endif

    dg = 2 * (h(1:n - 2) .+ h(2:n - 1));
    dg(1) = dg(1) - 0.5 * h(1);
    dg(n - 2) = dg(n-2) - 0.5 * h(n - 1);

    e = h(2:n - 2);

    g = 3 * diff (a(2:n,:)) ./ h(2:n - 1,idx)\
      - 3 * diff (a(1:n - 1,:)) ./ h(1:n - 2,idx);
    g(1,:) = 3 * (a(3,:) - a(2,:)) / h(2) \
        - 3 / 2 * (3 * (a(2,:) - a(1,:)) / h(1) - valc(1));
    g(n - 2,:) = 3 / 2 * (3 * (a(n,:) - a(n - 1,:)) / h(n - 1) - valc(2))\
        - 3 * (a(n - 1,:) - a(n - 2,:)) / h(n - 2);

    c(2:n - 1,:) = trisolve(dg,e,g);
    c(1,:) = (3 / h(1) * (a(2,:) - a(1,:)) - 3 * valc(1) 
	      - c(2,:) * h(1)) / (2 * h(1)); 
    c(n,:) = - (3 / h(n - 1) * (a(n,:) - a(n - 1,:)) - 3 * valc(2) 
		+ c(n - 1,:) * h(n - 1)) / (2 * h(n - 1));
    b(1:n - 1,:) = diff (a) ./ h(1:n - 1, idx)\
      - h(1:n - 1,idx) / 3 .* (c(2:n,:) + 2 * c(1:n - 1,:));
    d = diff (c) ./ (3 * h(1:n - 1, idx));

  elseif (strcmp(cond,"variational") || strcmp(cond,"second"))

    if ((nargin < 4) || strcmp(cond,"variational"))
      ## set second derivatives at end points to zero
      valc = [0, 0];
    endif

    c(1,:) = valc(1) / 2;
    c(n,:) = valc(2) / 2;

    g = 3 * diff (a(2:n,:)) ./ h(2:n - 1, idx)\
      - 3 * diff (a(1:n - 1,:)) ./ h(1:n - 2, idx);

    g(1,:) = g(1,:) - h(1) * c(1,:);
    g(n - 2,:) = g(n-2,:) - h(n - 1) * c(n,:);

    dg = 2 * (h(1:n - 2) .+ h(2:n - 1));
    e = h(2:n - 2); 
    
    c(2:n - 1,:) = trisolve (dg,e,g);
    b(1:n - 1,:) = diff (a) ./ h(1:n - 1,idx)\
      - h(1:n - 1,idx) / 3 .* (c(2:n,:) + 2 * c(1:n - 1,:));
    d = diff (c) ./ (3 * h(1:n - 1, idx));
  
  elseif (strcmp(cond,"periodic"))

    h = [h; h(1)];

    ## XXX FIXME XXX --- the following gives a smoother periodic transition:
    ##    a(n,:) = a(1,:) = ( a(n,:) + a(1,:) ) / 2;
    a(n,:) = a(1,:);

    tmp = diff (shift ([a; a(2,:)], -1));
    g = 3 * tmp(1:n - 1,:) ./ h(2:n,idx)\
      - 3 * diff (a) ./ h(1:n - 1,idx);

    if (n > 3)
      dg = 2 * (h(1:n - 1) .+ h(2:n));
      e = h(2:n - 1);
      c(2:n,idx) = trisolve(dg,e,g,h(1),h(1));
    elseif (n == 3)
      A = [2 * (h(1) + h(2)), (h(1) + h(2));
          (h(1) + h(2)), 2 * (h(1) + h(2))];
      c(2:n,idx) = A \ g;
    endif

    c(1,:) = c(n,:);
    b = diff (a) ./ h(1:n - 1,idx)\
      - h(1:n - 1,idx) / 3 .* (c(2:n,:) + 2 * c(1:n - 1,:));
    b(n,:) = b(1,:);
    d = diff (c) ./ (3 * h(1:n - 1, idx));
    d(n,:) = d(1,:);

  elseif (strcmp(cond,"not-a-knot"))

    if (n > 4)

      dg = 2 * (h(1:n - 2) .+ h(2:n - 1));
      dg(1) = dg(1) - h(1);
      dg(n - 2) = dg(n-2) - h(n - 1);

      ldg = udg = h(2:n - 2);
      udg(1) = udg(1) - h(1);
      ldg(n - 3) = ldg(n-3) - h(n - 1);
 
    elseif (n == 4)

      dg = [h(1) + 2 * h(2), 2 * h(2) + h(3)];
      ldg = h(2) - h(3);
      udg = h(2) - h(1);

    endif
    g = zeros(n - 2,columns(y));
    g(1,:) = 3 / (h(1) + h(2)) * (a(3,:) - a(2,:)\
          - h(2) / h(1) * (a(2,:) - a(1,:)));
    if (n > 4)
      g(2:n - 3,:) = 3 * diff (a(3:n - 1,:)) ./ h(3:n - 2,idx)\
        - 3 * diff (a(2:n - 2,:)) ./ h(2:n - 3,idx);
    endif
    g(n - 2,:) = 3 / (h(n - 1) + h(n - 2)) *\
 	(h(n - 2) / h(n - 1) * (a(n,:) - a(n - 1,:)) -\
	 (a(n - 1,:) - a(n - 2,:)));
    c(2:n - 1,:) = trisolve(ldg,dg,udg,g);
    c(1,:) = c(2,:) + h(1) / h(2) * (c(2,:) - c(3,:));
    c(n,:) = c(n - 1,:) + h(n - 1) / h(n - 2) * (c(n - 1,:) - c(n - 2,:));
    b = diff (a) ./ h(1:n - 1, idx)\
      - h(1:n - 1, idx) / 3 .* (c(2:n,:) + 2 * c(1:n - 1,:));
    d = diff (c) ./ (3 * h(1:n - 1, idx));

  else
    msg = sprintf("unknown end condition: %s",cond);
    error (msg);
  endif

  d = d(1:n-1,:); c=c(1:n-1,:); b=b(1:n-1,:); a=a(1:n-1,:);
  coeffs = [d(:), c(:), b(:), a(:)];
  pp = mkpp (x, coeffs);

endfunction


%!shared x,y,cond
%! x = linspace(0,2*pi,15)'; y = sin(x);

%!assert (ppval(csape(x,y),x), y, 10*eps);
%!assert (ppval(csape(x,y),x'), y', 10*eps);
%!assert (ppval(csape(x',y'),x'), y', 10*eps);
%!assert (ppval(csape(x',y'),x), y, 10*eps);
%!assert (ppval(csape(x,[y,y]),x), \
%!	  [ppval(csape(x,y),x),ppval(csape(x,y),x)], 10*eps)

%!test cond='complete';
%!assert (ppval(csape(x,y,cond),x), y, 10*eps);
%!assert (ppval(csape(x,y,cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x), y, 10*eps);
%!assert (ppval(csape(x,[y,y],cond),x), \
%!	  [ppval(csape(x,y,cond),x),ppval(csape(x,y,cond),x)], 10*eps)

%!test cond='variational';
%!assert (ppval(csape(x,y,cond),x), y, 10*eps);
%!assert (ppval(csape(x,y,cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x), y, 10*eps);
%!assert (ppval(csape(x,[y,y],cond),x), \
%!	  [ppval(csape(x,y,cond),x),ppval(csape(x,y,cond),x)], 10*eps)

%!test cond='second';
%!assert (ppval(csape(x,y,cond),x), y, 10*eps);
%!assert (ppval(csape(x,y,cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x), y, 10*eps);
%!assert (ppval(csape(x,[y,y],cond),x), \
%!	  [ppval(csape(x,y,cond),x),ppval(csape(x,y,cond),x)], 10*eps)

%!test cond='periodic';
%!assert (ppval(csape(x,y,cond),x), y, 10*eps);
%!assert (ppval(csape(x,y,cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x), y, 10*eps);
%!assert (ppval(csape(x,[y,y],cond),x), \
%!	  [ppval(csape(x,y,cond),x),ppval(csape(x,y,cond),x)], 10*eps)

%!test cond='not-a-knot';
%!assert (ppval(csape(x,y,cond),x), y, 10*eps);
%!assert (ppval(csape(x,y,cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x'), y', 10*eps);
%!assert (ppval(csape(x',y',cond),x), y, 10*eps);
%!assert (ppval(csape(x,[y,y],cond),x), \
%!	  [ppval(csape(x,y,cond),x),ppval(csape(x,y,cond),x)], 10*eps)
