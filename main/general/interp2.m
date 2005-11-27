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
## must correspondent to the size of @var{Z}. @var{X} and @var{Y} must be
## monotonic. If they are matrices they  must have the 'meshgrid' format. 
##
## ZI = interp2 (X, Y, Z, XI, YI, ...) returns a matrix corresponding
## to the points described by the matrices @var{XI}, @var{YI}. 
##
## If the last argument is a string, the interpolation method can
## be specified. The method can be 'linear', 'nearest' or 'cubic'.
## If it is omitted 'linear' interpolation  is assumed.
##
## ZI = interp2 (Z, XI, YI) assumes X = 1:rows(Z) and Y = 1:columns(Z)
## 
## ZI = interp2 (Z, n) interleaves the Matrix Z n-times. If n is ommited
## n = 1 is assumed
##
## @seealso{interp1}
## @end deftypefn

## Author:	Kai Habel <kai.habel@gmx.de>
## 2005-03-02 Thomas Weber <weber@num.uni-sb.de> 
##     * Add test cases
## 2005-03-02 Paul Kienzle <pkienzle@users.sf.net>
##     * Simplify
## 2005-04-23 Dmitri A. Sergatskov <dasergatskov@gmail.com>
##     * Modified demo and test for new gnuplot interface
## 2005-09-07 Hoxide <hoxide_dirac@yahoo.com.cn>
##     * Add bicubic interpolation method
##     * Fix the eat line bug when the last element of XI or YI is negative or zero.
## 2005-11-26 Pierre Baldensperger <balden@libertysurf.fr>
##     * Rather big modification (XI,YI no longer need to be
##       "meshgridded") to be consistent with the help message
##       above and for compatibility.


function ZI = interp2 (varargin)
  Z = X = Y = XI = YI = [];
  n = [];
  method = "linear";

  switch nargin
  case 1
    Z = varargin{1};
  case 2
    if ischar(varargin{2})
      [Z,method] = deal(varargin{:});
    else
      [Z,n] = deal(varargin{:});
    endif
  case 3
    if ischar(varargin{3})
      [Z,n,method] = deal(varargin{:});
    else
      [Z,XI,YI] = deal(varargin{:});
    endif
  case 4
    [Z,XI,YI,method] = deal(varargin{:});
  case 5
    [X,Y,Z,XI,YI] = deal(varargin{:});
  case 6 
    [X,Y,Z,XI,YI,method] = deal(varargin{:});
  otherwise
    usage ("interp2 (X, Y, Z, XI, YI, method)");
  endswitch

  % Type checking.
  if !ismatrix(Z), error("interp2 expected matrix Z"); endif
  if !isempty(n) && !isscalar(n), error("interp2 expected scalar n"); endif
  if !ischar(method), error("interp2 expected string 'method'"); endif

  % Define X,Y,XI,YI if needed
  [zr, zc] = size (Z);
  if isempty(X),  X=[1:zc]; Y=[1:zr]; endif
  if !isnumeric(X) || !isnumeric(Y), error("interp2 expected numeric X,Y"); endif
  if !isempty(n), p=2^n; XI=[p:p*zc]/p; YI=[p:p*zr]'/p; endif
  if !isnumeric(XI) || !isnumeric(YI), error("interp2 expected numeric XI,YI"); endif

  % If X and Y vectors produce a grid from them
  if isvector (X) && isvector (Y)
    [X, Y] = meshgrid (X, Y);
  elseif ! all(size (X) == size (Y))
    error ("X and Y must be matrices of same size");
  endif
  if any(size (X) != size (Z))
    error ("X and Y size must match Z dimensions");
  endif

  % If Xi and Yi are vectors of different orientation build a grid
  if (rows(XI)==1 && columns(YI)==1) || (columns(XI)==1 && rows(YI)==1)
    [XI, YI] = meshgrid (XI, YI);
  elseif any(size(XI) != size(YI))
    error ("XI and YI must be matrices of same size");
  endif

  shape = size(XI);
  XI = reshape(XI, 1, prod(shape));
  YI = reshape(YI, 1, prod(shape));

  xidx = lookup(X(1, 2:end-1), XI) + 1;
  yidx = lookup(Y(2:end-1, 1), YI) + 1;

  if strcmp (method, "linear")
    ## each quad satisfies the equation z(x,y)=a+b*x+c*y+d*xy
    ##
    ## a-b
    ## | |
    ## c-d
    a = Z(1:(zr - 1), 1:(zc - 1));
    b = Z(1:(zr - 1), 2:zc) - a;
    c = Z(2:zr, 1:(zc - 1)) - a;
    d = Z(2:zr, 2:zc) - a - b - c;

    idx = sub2ind(size(a),yidx,xidx);

    ## scale XI,YI values to a 1-spaced grid
    Xsc = (XI - X(1, xidx)) ./ (X(1, xidx + 1) - X(1, xidx));
    Ysc = (YI - Y(yidx, 1)') ./ (Y(yidx + 1, 1) - Y(yidx, 1))';

    ## apply plane equation
    ZI = a(idx) + b(idx).*Xsc + c(idx).*Ysc + d(idx).*Xsc.*Ysc;

  elseif strcmp (method, "nearest")
    xtable = X(1, :);
    ytable = Y(:, 1)';
    ii = (XI - xtable(xidx) > xtable(xidx + 1) - XI);
    jj = (YI - ytable(yidx) > ytable(yidx + 1) - YI);
    idx = sub2ind(size(Z),yidx+jj,xidx+ii);
    ZI = Z(idx);

  elseif strcmp (method, "cubic")
    ## FIXME bicubic doesn't handle arbitrary XI, YI
    ZI = bicubic(X, Y, Z, XI(1,:), YI(:,1));

  else
    error ("interpolation method not (yet) supported");
  endif

  ## set points outside the table to NaN

  ZI( XI < X(1,1) | XI > X(1,end) | YI < Y(1,1) | YI > Y(end,1) ) = NaN;

  ZI = reshape(ZI,shape);


endfunction

%!demo
%! A=[13,-1,12;5,4,3;1,6,2];
%! x=[0,1,4]; y=[10,11,12];
%! xi=linspace(min(x),max(x),17);
%! yi=linspace(min(y),max(y),26);
%! mesh(xi,yi,interp2(x,y,A,xi,yi,'linear'));
%! [x,y] = meshgrid(x,y); 
%! __gnuplot_raw__ ("set nohidden3d;\n")
%! hold on; plot3(x(:),y(:),A(:),"b*"); hold off;

%!demo
%! A=[13,-1,12;5,4,3;1,6,2];
%! x=[0,1,4]; y=[10,11,12];
%! xi=linspace(min(x),max(x),17);
%! yi=linspace(min(y),max(y),26);
%! mesh(xi,yi,interp2(x,y,A,xi,yi,'nearest'));
%! [x,y] = meshgrid(x,y); 
%! __gnuplot_raw__ ("set nohidden3d;\n")
%! hold on; plot3(x(:),y(:),A(:),"b*"); hold off;

%!#demo
%! A=[13,-1,12;5,4,3;1,6,2];
%! x=[0,1,2]; y=[10,11,12];
%! xi=linspace(min(x),max(x),17);
%! yi=linspace(min(y),max(y),26);
%! mesh(xi,yi,interp2(x,y,A,xi,yi,'cubic'));
%! [x,y] = meshgrid(x,y); 
%! __gnuplot_raw__ ("set nohidden3d;\n")
%! hold on; plot3(x(:),y(:),A(:),"b*"); hold off;

%!test % simple test
%!  x = [1,2,3];
%!  y = [4,5,6,7];
%!  [X, Y] = meshgrid(x,y);
%!  Orig = X.^2 + Y.^3;
%!  xi = [1.2,2, 1.5];
%!  yi = [6.2, 4.0, 5.0]';
%!
%!  Expected = ...
%!    [243,   245.4,  243.9;
%!      65.6,  68,     66.5;
%!     126.6, 129,    127.5];
%!  Result = interp2(x,y,Orig, xi, yi);
%!
%!  assert(Result, Expected, 1000*eps);

%!test % 2^n form
%!  x = [1,2,3];
%!  y = [4,5,6,7];
%!  [X, Y] = meshgrid(x,y);
%!  Orig = X.^2 + Y.^3;
%!  xi = [1:0.25:3]; yi = [4:0.25:7]';
%!  Expected = interp2(x,y,Orig, xi, yi);
%!  Result = interp2(Orig,2);
%!  
%!  assert(Result, Expected, 10*eps);

%!test % matrix slice
%!  A = eye(4);
%!  assert(interp2(A,[1:4],[1:4]),[1,1,1,1]);

%!test % non-gridded XI,YI
%!  A = eye(4);
%!  assert(interp2(A,[1,2;3,4],[1,3;2,4]),[1,0;1,0]);

%!test % for values outside of boundaries
%!  x = [1,2,3];
%!  y = [4,5,6,7];
%!  [X, Y] = meshgrid(x,y);
%!  Orig = X.^2 + Y.^3;
%!  xi = [0,4];
%!  yi = [3,8]';
%!  assert(interp2(x,y,Orig, xi, yi),[nan,nan;nan,nan]);

%!test % for values at boundaries
%!  A=[1,2;3,4];
%!  x=[0,1]; 
%!  y=[2,3]';
%!  assert(interp2(x,y,A,x,y,'linear'), A);
%!  assert(interp2(x,y,A,x,y,'nearest'), A);

