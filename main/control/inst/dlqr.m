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
## @deftypefn {Function File} {[@var{g}, @var{x}, @var{l}] =} dlqr (@var{sys}, @var{q}, @var{r})
## @deftypefnx {Function File} {[@var{g}, @var{x}, @var{l}] =} dlqr (@var{sys}, @var{q}, @var{r}, @var{s})
## @deftypefnx {Function File} {[@var{g}, @var{x}, @var{l}] =} dlqr (@var{a}, @var{b}, @var{q}, @var{r})
## @deftypefnx {Function File} {[@var{g}, @var{x}, @var{l}] =} dlqr (@var{a}, @var{b}, @var{q}, @var{r}, @var{s})
## Linear-quadratic regulator for discrete-time systems.
##
## @strong{Inputs}
## @table @var
## @item sys
## Continuous or discrete-time LTI model.
## @item a
## State transition matrix of discrete-time system.
## @item b
## Input matrix of discrete-time system.
## @item q
## State weighting matrix.
## @item r
## Input weighting matrix.
## @item s
## Optional cross term matrix. If @var{s} is not specified, a zero matrix is assumed.
## @end table
##
## @strong{Outputs}
## @table @var
## @item g
## State feedback matrix.
## @item x
## Unique stabilizing solution of the discrete-time Riccati equation.
## @item l
## Closed-loop poles.
## @end table
##
## @example
## @group
## x[k+1] = A x[k] + B u[k],   x[0] = x0
##
##         inf
## J(x0) = SUM (x' Q x  +  u' R u  +  2 x' S u)
##         k=0
##
## L = eig (A - B*G)
## @end group
## @end example
## @seealso{dare, care, lqr}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2009
## Version: 0.1

function [g, x, l] = dlqr (a, b, q, r = [], s = [])

  if (nargin < 3 || nargin > 5)
    print_usage ();
  endif

  if (isa (a, "lti"))
    s = r;
    r = q;
    q = b;
    [a, b, c, d, tsam] = ssdata (a);
  elseif (nargin < 4)
    print_usage ();
  else
    tsam = 1;  # any value > 0 could be used here
  endif

  if (tsam > 0)
    [x, l, g] = dare (a, b, q, r, s);
  else
    [x, l, g] = care (a, b, q, r, s);
  endif

endfunction