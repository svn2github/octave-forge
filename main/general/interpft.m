## Copyright (C) 2001 Paul Kienzle
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

## y = interpft (x, n)
## Resample x with n points using Fourier interpolation.
## The data x must be equally spaced and n >= length(x).
## y = interpft (x, n, m)
## Resample matrix x to NxM useing Fourier interpolation

## Author: Paul Kienzle
## 2001-02-11
##    * initial version
## 2002-03-17 aadler
##    * added code to work on matrices as well 
## $Id$

function z = interpft (x, n, m)
  if (nargin < 2 || nargin > 3)
    usage ("y=interpft (x, n)");
  endif

  transpose = ( rows (x) == 1 );
  if (transpose) x = x (:); endif

if nargin==2
  [nr, nc] = size (x);
  if n > nr
    y = fft (x) / nr;
    k = floor (nr / 2);
    z = n * ifft ( [ y(1:k,:); zeros(n-nr,nc); y(k+1:nr) ] );
  elseif n < nr
    warning ("interpft: Poor results possible: n should be bigger than x");
    ## XXX FIXME XXX the following doesn't work so well
    y = fft (x) / nr;
    k = ceil (n / 2);
    z = n * ifft ( [ y(1:k,:); y(nr-k+2:nr) ] );
  else
    z = x;
  endif

else
   # this code is for matrices as well as vectors,
   # it could replace the first code except
   # 1) it depends on sparse being available
   # 2) it's slightly slower
   save_empty_list_elements_ok= empty_list_elements_ok;
   unwind_protect
   empty_list_elements_ok= 1;

   ny= n;
   if nargin==2; my=1; else; my= m; endif

   [nx,mx]= size(x);

   if nx < ny
      nhx= ceil( nx/2 );
      yconv= sparse( [ 1:nhx, ny-(nx-1-nhx:-1:0) ], 1:nx, 1, ny, nx );
   elseif  nx > ny
      nhy= ceil( ny/2 );
      yconv= sparse( 1:ny, [ 1:nhy, nx-(ny-1-nhy:-1:0) ], 1, ny, nx );
   elseif  nx == ny
      yconv= sparse( 1:ny, 1:nx, 1, ny, nx);
   end

   if mx < my
      mhx= ceil( mx/2 );
      xconv= sparse( 1:mx, [ 1:mhx, my-(mx-1-mhx:-1:0) ], 1, mx, my );
   elseif  mx > my
      mhy= ceil( my/2 );
      xconv= sparse( [ 1:mhy, mx-(my-1-mhy:-1:0) ], 1:my, 1, mx, my );
   elseif  mx == my
      xconv= sparse( 1:mx, 1:my, 1, mx, my);
   end

   z= ifft2( yconv*fft2(x)*xconv) * (ny*my)/(nx*mx);

   unwind_protect_cleanup
      empty_list_elements_ok= save_empty_list_elements_ok;
   end_unwind_protect

endif

  if isreal (x), z = real (z); endif
  if transpose, z = z.'; endif

endfunction

%!demo
%! t = 0 : 0.3 : pi; dt = t(2)-t(1);
%! n = length (t); k = 100;
%! ti = t(1) + [0 : k-1]*dt*n/k;
%! y = sin (4*t + 0.3) .* cos (3*t - 0.1);
%! yp = sin (4*ti + 0.3) .* cos (3*ti - 0.1);
%! plot (ti, yp, 'g;sin(4t+0.3)cos(3t-0.1);', ...
%!       ti, interp1 (t, y, ti, 'spline'), 'b;spline;', ...
%!       ti, interpft (y ,k), 'c;interpft;', ...
%!       t, y, 'r+;data;');

%!#demo
%! t = 0:0.3:pi; dt = t(2)-t(1);
%! n = length(t); k = 100;
%! ti = t(1)+[0:k-1]*dt*n/k;
%! y = sin (4*t+0.3).*cos(3*t-0.1);
%! yp = sin (4*ti+0.3).*cos(3*ti-0.1);
%! plot (ti, yp, 'g;sin(4t+0.3)cos(3t-0.1);', ...
%!       t, interp1(ti,yp,t,'spline'), 'bx;spline;', ...
%!       t, interpft(yp, n), 'co;interpft;', ...
%!       t, y, 'r+;data;')
