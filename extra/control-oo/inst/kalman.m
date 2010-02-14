## Copyright (C) 2009 - 2010   Lukas F. Reichlin
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
## @deftypefnx {Function File} {[@var{est}, @var{g}, @var{x}] =} kalman (@var{sys}, @var{q}, @var{r}, @var{s}, @var{sensors}, @var{known})
## Design Kalman estimator for LTI systems.
## @seealso{care, dare, estim, lqr}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2009
## Version: 0.2

function [est, k, x] = kalman (sys, q, r, s = [], sensors = [], known = [])

  ## TODO: type "current" for discrete-time systems

  if (nargin < 3 || nargin > 6 || ! isa (sys, "lti"))
    print_usage ();
  endif

  [a, b, c, d] = ssdata (sys);

  if (isempty (sensors))
    sensors = 1 : rows (c);
  endif

  stoch = 1 : columns (b);
  stoch(known) = [];

  c = c(sensors, :);
  g = b(:, stoch);
  h = d(sensors, stoch);

  if (isempty (s))
    rbar = r + h*q*h';
    sbar = g * q*h'
  else
    rbar = r + h*s + s'*h' + h*q*h'; 
    sbar = g * (q*h' + s);
  endif

  if (isct (sys))
    [x, l, k] = care (a', c', g*q*g', rbar, sbar);
  else
    [x, l, k] = dare (a', c', g*q*g', rbar, sbar);
  endif

  k = k';

  est = estim (sys, k, sensors, known);

endfunction


%!shared m, m_exp, g, g_exp, x, x_exp
%! sys = ss (-2, 1, 1, 3);
%! [est, g, x] = kalman (sys, 1, 1, 1);
%! [a, b, c, d] = ssdata (est);
%! m = [a, b; c, d];
%! m_exp = [-2.25, 0.25; 1, 0; 1, 0];
%! g_exp = 0.25;
%! x_exp = 0;
%!assert (m, m_exp, 1e-2);
%!assert (g, g_exp, 1e-2);
%!assert (x, x_exp, 1e-2);