## Copyright (C) 2009   Lukas F. Reichlin
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
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program. If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{est} =} estim (@var{sys}, @var{l})
## @deftypefnx {Function File} {@var{est} =} estim (@var{sys}, @var{l}, @var{sensors}, @var{known})
## Return state estimator for a given estimator gain
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2009
## Version: 0.1

function est = estim (sys, l, sensors = [], known = [])

  if (nargin < 2 || nargin > 4)
    print_usage ();
  endif

  if (! isa (sys, "lti"))
    error ("estim: first argument must be a LTI system");
  endif

  [a, b, c, d, tsam] = ssdata (sys);

  if (isempty (sensors))
    sensors = 1 : rows (c);
  endif

  m = length (known);
  n = rows (a);
  p = length (sensors);

  b = b(:, known);
  c = c(sensors, :);
  d = d(sensors, known);

  f = a - l*c;
  g = [b - l*d, l];
  h = [c; eye(n)];
  j = [d, zeros(p, p); zeros(n, m), zeros(n, p)];

  est = ss (f, g, h, j, tsam);

  ## TODO: inname, stname, outname

endfunction