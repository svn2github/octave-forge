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
## @deftypefn{Function File} {[@var{y}, @var{t}, @var{x}] =} step (@var{sys})
## @deftypefnx{Function File} {[@var{y}, @var{t}, @var{x}] =} step (@var{sys}, @var{t})
## @deftypefnx{Function File} {[@var{y}, @var{t}, @var{x}] =} step (@var{sys}, @var{tfinal})
## @deftypefnx{Function File} {[@var{y}, @var{t}, @var{x}] =} step (@var{sys}, @var{tfinal}, @var{dt})
## Step response of LTI system.
## If no output arguments are given, the response is printed on the screen.
##
## @strong{Inputs}
## @table @var
## @item sys
## LTI model.
## @item t
## Time vector. Should be evenly spaced. If not specified, it is calculated by
## the poles of the system to reflect adequately the response transients.
## @item tfinal
## Optional simulation horizon. If not specified, it is calculated by
## the poles of the system to reflect adequately the response transients.
## @item dt
## Optional sampling time. Be sure to choose it small enough to capture transient
## phenomena. If not specified, it is calculated by the poles of the system.
## @end table
##
## @strong{Outputs}
## @table @var
## @item y
## Output response array. Has as many rows as time samples (length of t)
## and as many columns as outputs.
## @item t
## Time row vector.
## @item x
## State trajectories array. Has length(t) rows and as many columns as states.
## @end table
##
## @seealso{impulse, initial, lsim}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: October 2009
## Version: 0.1

function [y_r, t_r, x_r] = step (sys, tfinal = [], dt = [])

  ## TODO: multiplot feature:   step (sys1, "b", sys2, "r", ...)

  if (nargin == 0 || nargin > 3)
    print_usage ();
  endif

  [y, t, x] = __time_response__ (sys, "step", ! nargout, tfinal, dt);

  if (nargout)
    y_r = y;
    t_r = t;
    x_r = x;
  endif

endfunction
