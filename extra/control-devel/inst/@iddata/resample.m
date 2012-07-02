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
## @deftypefn {Function File} {@var{dat} =} resample (@var{dat}, @var{p}, @var{q})
## @deftypefnx {Function File} {@var{dat} =} resample (@var{dat}, @var{p}, @var{q}, @var{n})
## Return @var{k}-th difference of outputs and inputs of dataset @var{dat}.
## If @var{k} is not specified, default value 1 is taken.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: June 2012
## Version: 0.1

function dat = resample (dat, p, q, n = 0)

  if (nargin < 3 || nargin > 4)
    print_usage ();
  endif
  
  ## requires signal package
  
  h = fir1 (n, 1/q);

  dat.y = cellfun (@(y) resample (y, p, q, h), dat.y, "uniformoutput", false);
  dat.u = cellfun (@(u) resample (u, p, q, h), dat.u, "uniformoutput", false);

endfunction
