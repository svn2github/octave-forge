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
## @deftypefn {Function File} {@var{dat} =} fft (@var{dat})
## @deftypefnx {Function File} {@var{dat} =} fft (@var{dat}, @var{ord})
## Detrend outputs and inputs of dataset @var{dat} by
## removing the best fit of a polynomial of order @var{ord}.
## If @var{ord} is not specified, default value 0 is taken.
## This corresponds to removing a constant.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: April 2012
## Version: 0.1

function dat = fft (dat, n = [])

  if (nargin > 2)       # no need to test nargin == 0, this is handled by built-in fft
    print_usage ();
  endif
  
  if (isempty (n))
    n = num2cell (size (dat, 1));
  else
  
  endif

%  if ((! is_real_scalar (ord) || fix (ord) != ord) && ! ischar (ord))   # chars are handled by built-in detrend
%    error ("iddata: detrend: second argument must be a positve integer");
%  endif

%  dat.y = cellfun (@fft, dat.y, "uniformoutput", false);
%  dat.u = cellfun (@fft, dat.u, "uniformoutput", false);

%  dat.y = cellfun (@(y, n) fft (y, n) / sqrt (n), dat.y, n, "uniformoutput", false);
%  dat.u = cellfun (@(u, n) fft (u, n) / sqrt (n), dat.u, n, "uniformoutput", false);

  dat.y = cellfun (@(y, n) fft (y, n)(1:fix(n/2)+1, :) / sqrt (n), dat.y, n, "uniformoutput", false);
  dat.u = cellfun (@(u, n) fft (u, n)(1:fix(n/2)+1, :) / sqrt (n), dat.u, n, "uniformoutput", false);
  
  % w = (0:fix(n/2)) * (2*pi/tsam/n)
  
  dat.timedomain = false;

%  dat.y = cellfun (@(y) fft (y, n), dat.y, "uniformoutput", false);
%  dat.u = cellfun (@(u) fft (u, n), dat.u, "uniformoutput", false);

endfunction


%!shared DATD, Z
%! DAT = iddata ({[(1:10).', (1:2:20).'], [(10:-1:1).', (20:-2:1).']}, {[(41:50).', (46:55).'], [(61:70).', (-66:-1:-75).']});
%! DATD = detrend (DAT, "linear");
%! Z = zeros (10, 2);
%!assert (DATD.y{1}, Z, 1e-10);
%!assert (DATD.y{2}, Z, 1e-10);
%!assert (DATD.u{1}, Z, 1e-10);
%!assert (DATD.u{2}, Z, 1e-10);
