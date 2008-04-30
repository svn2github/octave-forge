## Copyright (C) 2008 Jonathan Stickel
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
## along with this program; If not, see <http://www.gnu.org/licenses/>. 

## -*- texinfo -*-
## @deftypefn {Function File} {@var{cve}|@var{stdevdif} =} tkrgdatasmscatwrap (@var{log10lambda}, @var{xm}, @var{ym}, @var{n}, @var{o}, @var{range}, 'cve'|'stdev'[, @var{stdev}])
##
##  Wrapper function for tkrgdatasmscat in order to minimize over @var{lambda}
##  w.r.t. cross-validation error OR the squared difference between the
##  standard deviation of data from the smooth data and the given
##  standard deviation.
## @end deftypefn



function out = tkrgdatasmscatwrap (log10lambda, xm, ym, N, d, range, mintype, stdev)

  lambda = 10^(log10lambda);
  
  if ( strcmp(mintype,"stdev") )
    [x, y] = tkrgdatasmscat(xm, ym, lambda, N, d, range);
    dx = (max(x)-min(x))/(N-1);
    idx = round((xm - min(x)) / dx) + 1;
    stdevd = std(ym-y(idx));
    out = (stdevd - stdev)^2;
  else
    [x, y, cve] = tkrgdatasmscat(xm, ym, lambda, N, d, range);
    out = cve;
  endif

endfunction
