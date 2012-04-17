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
## @deftypefn {Function File} {@var{dat} =} ifft (@var{dat})
## @deftypefnx {Function File} {@var{dat} =} ifft (@var{dat}, @var{ord})
## Detrend outputs and inputs of dataset @var{dat} by
## removing the best fit of a polynomial of order @var{ord}.
## If @var{ord} is not specified, default value 0 is taken.
## This corresponds to removing a constant.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: April 2012
## Version: 0.1

function dat = ifft (dat)

  if (nargin > 1)       # no need to test nargin == 0, this is handled by built-in fft
    print_usage ();
  endif

  if (dat.timedomain)
    return;
  endif

  [x, ~, ~, e] = size (dat);

  x = x(:);
  n = num2cell (x);
  %nconj = num2cell (x - ! rem (x, 2));
  nconj = num2cell (x - rem (x, 2));


  dat.y = cellfun (@(y, n, nconj) real (ifft ([y; conj(y(nconj:-1:2, :))], [], 1)) * sqrt (n+nconj), dat.y, n, nconj, "uniformoutput", false);
  dat.u = cellfun (@(u, n, nconj) real (ifft ([u; conj(u(nconj:-1:2, :))], [], 1)) * sqrt (n+nconj), dat.u, n, nconj, "uniformoutput", false);

  ## ifft (x, n, dim=1) because x could be a row vector (n=1)
  
  % dat.w = cellfun (@(n, tsam) (0:fix(n/2)).' * (2*pi/abs(tsam)/n), n, dat.tsam, "uniformoutput", false);
  ## abs(tsam) because of -1 for undefined sampling times
  dat.timedomain = true;

endfunction


%!shared DATD, Y, U
%! Y = 1:10;
%! U = 20:-2:1;
%! DAT = iddata (Y, U);
%! DATD = fft (DAT);
%!assert (DATD.y{1}, Y, 1e-10);
%!assert (DATD.u{1}, U, 1e-10);
