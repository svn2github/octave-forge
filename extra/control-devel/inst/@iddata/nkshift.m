## Copyright (C) 2012   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{dat} =} nkshift (@var{dat}, @var{nk})
## @deftypefnx {Function File} {@var{dat} =} detrend (@var{dat}, @var{nk} @var{'append'})
## Detrend outputs and inputs of dataset @var{dat} by
## removing the best fit of a polynomial of order @var{ord}.
## If @var{ord} is not specified, default value 0 is taken.
## This corresponds to removing a constant.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: July 2012
## Version: 0.1

function dat = nkshift (dat, nk = 0)

  if (nargin != 2)
    print_usage ();
  endif

  if (! is_real_scalar (nk))
    error ("iddata: nkshift: ");
  endif

  ## TODO: - nk per inputs
  ##       - padding with zeros
  
  snk = sign (nk);
  nk = abs (nk);

  if (snk >= 0)
    dat.y = cellfun (@(y) y(nk+1:end, :), dat.y, "uniformoutput", false);
    dat.u = cellfun (@(u) u(1:end-nk, :), dat.u, "uniformoutput", false);
  else
    dat.y = cellfun (@(y) y(1:end-nk, :), dat.y, "uniformoutput", false);
    dat.u = cellfun (@(u) u(nk+1:end, :), dat.u, "uniformoutput", false);
  endif

endfunction
