## Copyright (C) 2012 Benjamin Lewis <benjf5@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{c} =} lswaveletcoeff (@var{t}, @var{x}, @var{time}, @var{freq})
## @deftypefnx {Function File} {@var{c} =} lswaveletcoeff (@var{t}, @var{x}, @var{time}, @var{freq}, @var{window}=cubicwgt)
## @deftypefnx {Function File} {@var{c} =} lswaveletcoeff (@var{t}, @var{x}, @var{time}, @var{freq}, @var{window}=cubicwgt, @var{winradius}=1)
##
## Return the coefficient of the wavelet transform of the
## complex time series (@var{t}, @var{x}) at time @var{time}
## and frequency @var{freq}; optional variable @var{window}
## provides a windowing function and defaults to cubicwgt,
## while @var{winradius} is the windowing radius, and defaults
## to 1 (the radius of cubicwgt.)
##
## @seealso{lscorrcoeff, lscomplexwavelet, lsrealwavelet}
## 
## @end deftypefn


function coeff = lswaveletcoeff (x, y, t, o, wgt = @cubicwgt, wgtrad = 1)

  so = 0.05 .* o;

  if ((ndims (x) == 2) && ! (rows (x) == 1))
    x = reshape (x, 1, length (x));
    y = reshape (y, 1, length (y));
  endif

  mask = (abs (x - t) * so < wgtrad);
  rx = x(mask);
  ry = y(mask);

  ## Going by the R code, this can use the same mask.
  s = sum (wgt ((x - t) .* so));
  coeff = ifelse (s != 0, 
                  sum (wgt ((rx - t) .* so) .* 
                       exp (i .* o .* (rx - t)) .* ry) ./ s, 
                  0);
  
endfunction


%!shared t, p, x, y, maxfreq
%! maxfreq = 4 / (2 * pi);
%! t = linspace (0, 8);
%! x = (2 .* sin (maxfreq .* t) + 
%!      3 .* sin ((3/4) * maxfreq .* t) - 
%!      0.5 .* sin ((1/4) * maxfreq .* t) - 
%!      0.2 .* cos (maxfreq .* t) + 
%!      cos ((1/4) * maxfreq .* t));
%! y = - x;
%! p = linspace (0, 8, 500);
%!assert (lswaveletcoeff (t, x, 0.5, maxfreq), 
%!        0.383340407638780 + 2.385251997545446i, 5e-10);
%!assert (lswaveletcoeff (t, y, 3.3, 3/4 * maxfreq), 
%!        -2.35465091096084 + 1.01892561714824i, 5e-10);


%!demo
%! ## Generates the wavelet transform coefficient for time 0.5 and circ. freq. 0.9, for row & column vectors.
%! x = 1:10;
%! y = sin (x);
%! xt = x';
%! yt = y';
%! a = lswaveletcoeff (x, y, 0.5, 0.9)
%! b = lswaveletcoeff (xt, yt, 0.5, 0.9)

