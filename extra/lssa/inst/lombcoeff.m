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
## @deftypefn {Function File} {c =} lombcoeff (time, mag, freq)
##
## Return the coefficient of the Lomb periodogram (unnormalized) for the
## (@var{time},@var{mag}) series for the @var{freq} provided.
##
## @seealso{lombnormcoeff}
## @end deftypefn


function coeff = lombcoeff (T, X, o)

  oT = o .* T;

  theta = atan2 (sum (sin (2 * oT)), 
                 sum (cos (2 * oT))) ./ (2 * o);

  coeff = (sum (X .* cos (oT - theta)) ^2 / 
           sum (cos (oT - theta) .^2) + 
           sum (X .* sin (oT - theta)) ^2 / 
           sum (sin (oT - theta) .^2));

endfunction


%!shared t, x, o, maxfreq
%! maxfreq = 4 / (2 * pi);
%! t = linspace (0, 8);
%! x = (2 .* sin (maxfreq .* t) + 
%!      3 .* sin ((3/4) * maxfreq .* t) - 
%!      0.5 .* sin ((1/4) * maxfreq .* t) - 
%!      0.2 .* cos (maxfreq .* t) + 
%!      cos ((1/4) * maxfreq .* t));
%! o = [maxfreq , (3/4 * maxfreq) , (1/4 * maxfreq)];
%!assert (lombcoeff (t, x, maxfreq), 10788.9848389923, 5e-10);
%!assert (lombcoeff (t, x, 3/4*maxfreq), 12352.6413413457, 5e-10);
%!assert (lombcoeff (t, x, 1/4*maxfreq), 13673.4098969780, 5e-10);
