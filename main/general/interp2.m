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
## @deftypefn {Function File} {@var{zi}=} interp2 (@var{x}, @var{y}, @var{z}, @var{xi}, @var{yi})
## @deftypefnx {Function File} {@var{zi}=} interp2 (@var{Z}, @var{xi}, @var{yi})
## @deftypefnx {Function File} {@var{zi}=} interp2 (@var{Z}, @var{n})
## @deftypefnx {Function File} {@var{zi}=} interp2 (... , '@var{method}')
## Two-dimensional interpolation. @var{X},@var{Y} and @var{Z} describe a
## surface function. If @var{X} and @var{Y} are vectors their length
## must correspondent to the size of @var{Z}. If they are matrices they
## must have the 'meshgrid' format. 
##
## ZI = interp2 (X, Y, Z, XI, YI, ...) returns a matrix corresponding
## to the points described by the matrices @var{XI}, @var{YI}. 
##
## If the last argument is a string, the interpolation method can
## be specified. At the moment only 'linear' and 'nearest' methods
## are provided. If it is omitted 'linear' interpolation  is 
## assumed.
##
## ZI = interp2 (Z, XI, YI) assumes X = 1:rows(Z) and Y = 1:columns(Z)
## 
## ZI = interp2 (Z, n) interleaves the Matrix Z n-times. If n is ommited
## n = 1 is assumed
##
## @seealso{interp1}
## @end deftypefn

## Author:	Kai Habel <kai.habel@gmx.de>

function ZI = interp2 (X, Y, Z, XI, YI, method)

  if (nargin > 6 || nargin == 0)
    usage ("interp2 (X, Y, Z, XI, YI, method)");
  endif

  if (nargin > 4)
    if (is_vector (X) && is_vector (Y))
      [rz, cz] = size (Z);
      if (rz != length (Y) || cz != length (X))
        error ("length of X and Y must match the size of Z");
      endif
      [X, Y] = meshgrid (X, Y);
    elseif !( (size (X) == size (Y)) && (size (X) == size (Z)) )
      error ("X,Y and Z must be matrices of same size");
    endif
  
  elseif (((nargin == 4) || (nargin == 3)) && !isstr (Z))
   
    if (nargin == 4)
      if (isstr (XI))
        method = XI;
      else
        usage("interp2 (z,xi,yi,'format'");
      endif
    endif
    XI = Y;
    YI = Z;
    Z = X;
    [X, Y] = meshgrid(1:columns(Z), 1:rows(Z));
  else
    if (nargin == 1)
      n = 1;
    elseif (nargin == 2)
      if (isstr (Y))
        method = Y;
        n = 1;
      elseif (is_scalar (Y))
        n = Y;
      endif
    else
      n = Y;
      if (isstr (Z))
        method = Z;
      endif
    endif
    Z = X;
    [zr, zc] = size (Z);
    [X, Y] = meshgrid (1:zc, 1:zr);
    xi = linspace (1, zc, pow2 (n) * (zc - 1) + 1);
    yi = linspace (1, zr, pow2 (n) * (zr - 1) + 1);
    [XI, YI] = meshgrid (xi, yi);
  endif

  if (! exist ("method"))
    method = "linear";
  endif

  xtable = X(1, :);
  ytable = Y(:, 1);

  if (is_vector (XI) && is_vector (YI))
    [XI, YI] = meshgrid (XI, YI);
  elseif (! (size (XI) == size (YI)))
    error ("XI and YI must be matrices of same size");
  endif

  ytlen = length (ytable);
  xtlen = length (xtable);

  ## get x index of values in XI
  xtable(xtlen) *= (1 + eps);
  xtable(xtlen) > XI(1, :);
  [m, n] = sort ([xtable(:); XI(1, :)']);
  o = cumsum (n <= xtlen);
  xidx = o([find(n > xtlen)])';

  ## get y index of values in YI
  ytable(ytlen) *= (1 + eps);
  [m, n]=sort ([ytable(:); YI(:, 1)]);
  o = cumsum (n <= ytlen);
  yidx = o([find(n > ytlen)]);

  [zr, zc] = size (Z);

  ## mark values outside the lookup table
  xfirst_val = find (XI(1,:) < xtable(1));
  xlast_val  = find (XI(1,:) > xtable(xtlen));
  yfirst_val = find (YI(:,1) < ytable(1));
  ylast_val  = find (YI(:,1) > ytable(ytlen));

  ## set value outside the table preliminary to min max index
  yidx(yfirst_val) = 1;
  xidx(xfirst_val) = 1;
  yidx(ylast_val) = zr - 1;
  xidx(xlast_val) = zc - 1;

  if strcmp (method, "linear")
    ## each quad satisfies the equation z(x,y)=a+b*x+c*y+d*xy
    ##
    ## a-b
    ## | |
    ## c-d
    a = Z(1:zr - 1, 1:zc - 1);
    b = Z(1:zr - 1, 2:zc) - a;
    c = Z(2:zr, 1:zc - 1) - a;
    d = Z(2:zr, 2:zc) - a - b - c;

    ## scale XI,YI values to a 1-spaced grid
    Xsc = (XI .- X(yidx, xidx)) ./ (X(yidx, xidx + 1) - X(yidx, xidx));
    Ysc = (YI .- Y(yidx, xidx)) ./ (Y(yidx + 1, xidx) - Y(yidx, xidx));
    ## apply plane equation
    ZI = a(yidx, xidx) .+ b(yidx, xidx) .* Xsc \
      .+ c(yidx, xidx) .* Ysc .+ d(yidx, xidx) .* Xsc .* Ysc;
  elseif strcmp (method, "nearest")
    i = XI(1, :) - xtable(xidx) > xtable(xidx + 1) - XI(1, :);
    j = YI(:, 1) - ytable(yidx) > ytable(yidx + 1) - YI(:, 1);
    ZI = Z(yidx + j, xidx + i);
  else
    error ("interpolation method not (yet) supported");
  endif

  ## set points outside the table to NaN
  if (! (isempty (xfirst_val) && isempty (xlast_val)))
    ZI(:, [xfirst_val, xlast_val]) = NaN;
  endif
  if (! (isempty (yfirst_val) && isempty (ylast_val)))
    ZI([yfirst_val; ylast_val], :) = NaN;
  endif
endfunction

%!demo
%! A=[13,-1,12;5,4,3;1,6,2];
%! x=[0,1,4]; y=[10,11,12];
%! xi=linspace(min(x),max(x),17);
%! yi=linspace(min(y),max(y),26);
%! mesh(xi,yi,interp2(x,y,A,xi,yi,'linear'));
%! [x,y] = meshgrid(x,y); gset nohidden3d;
%! hold on; plot3(x(:),y(:),A(:),"b*"); hold off;

%!demo
%! A=[13,-1,12;5,4,3;1,6,2];
%! x=[0,1,4]; y=[10,11,12];
%! xi=linspace(min(x),max(x),17);
%! yi=linspace(min(y),max(y),26);
%! mesh(xi,yi,interp2(x,y,A,xi,yi,'nearest'));
%! [x,y] = meshgrid(x,y); gset nohidden3d;
%! hold on; plot3(x(:),y(:),A(:),"b*"); hold off;

%!#demo
%! A=[13,-1,12;5,4,3;1,6,2];
%! x=[0,1,2]; y=[10,11,12];
%! xi=linspace(min(x),max(x),17);
%! yi=linspace(min(y),max(y),26);
%! mesh(xi,yi,interp2(x,y,A,xi,yi,'cubic'));
%! [x,y] = meshgrid(x,y); gset nohidden3d;
%! hold on; plot3(x(:),y(:),A(:),"b*"); hold off;
