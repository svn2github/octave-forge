## Copyright (C) 2012 Benjamin Lewis  <benjf5@gmail.com>
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
## @deftypefn {Function File} {c =} lscorrcoeff (abc1, ord1, abc2, ord2, time, freq)
## @deftypefnx {Function File} {c =} lscorrcoeff (abc1, ord1, abc2, ord2, time, freq, window)
## @deftypefnx {Function File} {c =} lscorrcoeff (abc1, ord1, abc2, ord2, time, freq, window, winradius)
##
## Return the coefficient of the wavelet correlation of time
## series (@var{abc1}, @var{ord1}) and (@var{abc2}, @var{ord2}).
## @var{window} is used to apply a windowing function, its
## default is cubicwgt if left blank, and its radius is 1,
## as defined as the default for @var{winradius}.
##
## @end deftypefn

## Demo with sin, cos as Nir suggested.
%!demo
%! x = 1:10;
%! y = sin(x);
%! z = cos(x);
%! a = lscorrcoeff(x,y,x,z,0.5,0.9)
%! ## This generates the correlation coefficient at time 0.5 and circular freq. 0.9


## nucorrcoeff, computes a coefficient of the wavelet correlation of two time series

function coeff = lscorrcoeff(x1, y1, x2, y2, t, o, wgt = @cubicwgt, wgtrad = 1)
  so = 0.05 * o;
  ## This code can only, as of currently, work on vectors; I haven't figured out a way to make it work on a matrix.
  if( ( ndims(x1) == 2 ) && ! ( rows(x1) == 1 ) )
    x1 = reshape(x1,1,length(x1));
    y1 = reshape(y1,1,length(y1));
    x2 = reshape(x2,1,length(x2));
    y2 = reshape(y2,1,length(y2));
  endif
  ## The first solution that comes to mind is admittedly slightly ugly and has a data footprint of O(2n)
  ## but it is vectorised.
  mask = ;
  mask = find( ( abs( x1 - t ) * so ) < wgtrad );
  rx1 = x1(mask); ## I've kept the variable names from the R function here
  ry1 = y1(mask); ## Needs to have a noisy error if length(y1) != length(x1) -- add this!
  mask = find( ( abs( x2 - t ) * so ) < wgtrad );
  rx2 = x2(mask);
  ry2 = y2(mask);
  ## I've used the same mask for all of these as it's an otherwise unimportant variable ... can this leak memory?
  length(rx1) ##printing this length is probably used as a warning if 0 is returned; I included it
  ## in particular to maintain an exact duplicate of the R function.
  s = sum( wgt( ( rx1 - t ) .* so ) ) * sum( wgt( ( rx2 - t ) .* so ) );
  if s != 0
    coeff = sum( wgt((rx1-t).*so).*exp(i*o.*rx1).*ry1) *
    sum(wgt((rx2-t).*so).*exp(i*o.*rx2).*conj(ry2)) / s;
  else
    coeff = 0;
  endif

endfunction
