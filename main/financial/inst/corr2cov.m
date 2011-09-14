## Copyright (C) 2011 Hong Yu <hyu0401@hotmail.com>
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} @var{cov} = corr2cov (@var{sigma}, @var{corr})
## Convert standard deviation @var{sigma} and correlation coefficients @var{corr}
## to covariance @var{cov}.
##
## Note that the rate @var{r} is specified as a fraction (i.e., 0.05,
## not 5 percent).
## @seealso{corrcoef, cov, cov2corr, std}
## @end deftypefn

function ret = corr2cov (sigma, corr)

  if ( nargin != 2 )
    print_usage ();
  endif

  if ( rows(corr) != columns(corr) )
    error("correlation coefficients must be a NxN matrix");
  elseif ( rows(sigma) != 1 )
    error("sigma must be a 1xN vector (single row) with the standard deviation values");
  elseif ( columns(sigma) < columns(1) )
    error("sigma: must be 1xN \ncorr: must be nxn"); 
  endif

  sigma = sigma(:);
  ret   = corr .* (sigma * sigma');

endfunction

