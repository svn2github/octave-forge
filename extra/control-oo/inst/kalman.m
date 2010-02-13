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
## @deftypefn {Function File} {[@var{est}, @var{g}, @var{x}] =} kalman (@var{sys}, @var{q}, @var{r})
## @deftypefnx {Function File} {[@var{est}, @var{g}, @var{x}] =} kalman (@var{sys}, @var{q}, @var{r}, @var{s})
## Design kalman estimator for LTI systems.
## @seealso{care, dare, estim, lqr}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2009
## Version: 0.1

function [est, g, x] = kalman (sys, q, r, s = [])

  ## TODO: complex case (sensors, known, type "current" or "delayed" for discrete systems)

  if (nargin < 3 || nargin > 4)
    print_usage ();
  endif

  if (! isa (sys, "lti"))
    print_usage ();
  endif

  [a, b, c, d] = ssdata (sys);

  if (isempty (s))
    bs = [];
  else
    bs = b*s;
  endif

  if (isct (sys))
    [x, l, g] = care (a', c', b*q*b', r, bs);
  else
    [x, l, g] = dare (a', c', b*q*b', r, bs);
  endif

  g = g';

  est = estim (sys, g);

endfunction