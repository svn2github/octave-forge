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
## @deftypefn {Function File} {[@var{l}, @var{p}, @var{e}] =} lqe (@var{sys}, @var{q}, @var{r})
## @deftypefnx {Function File} {[@var{l}, @var{p}, @var{e}] =} lqe (@var{sys}, @var{q}, @var{r}, @var{s})
## @deftypefnx {Function File} {[@var{l}, @var{p}, @var{e}] =} lqe (@var{a}, @var{g}, @var{c}, @var{q}, @var{r})
## @deftypefnx {Function File} {[@var{l}, @var{p}, @var{e}] =} lqe (@var{a}, @var{g}, @var{c}, @var{q}, @var{r}, @var{s})
## @deftypefnx {Function File} {[@var{l}, @var{p}, @var{e}] =} lqe (@var{a}, @var{[]}, @var{c}, @var{q}, @var{r})
## @deftypefnx {Function File} {[@var{l}, @var{p}, @var{e}] =} lqe (@var{a}, @var{[]}, @var{c}, @var{q}, @var{r}, @var{s})
## Linear-quadratic estimator.
##
## @strong{Inputs}
## @table @var
## @item sys
## Continuous or discrete-time LTI model.
## @item a
## State transition matrix of continuous-time system.
## @item b
## Input matrix of continuous-time system.
## @item q
## State weighting matrix.
## @item r
## Input weighting matrix.
## @item s
## Optional cross term matrix.  If @var{s} is not specified, a zero matrix is assumed.
## @item e
## Optional descriptor matrix.  If @var{e} is not specified, an identity matrix is assumed.
## @end table
##
## @strong{Outputs}
## @table @var
## @item l
## Observer gain matrix.
## @item p
## Unique stabilizing solution of the continuous-time Riccati equation.
## @item e
## Closed-loop poles.
## @end table
##
## @strong{Equations}
## @example
## @group
## .
## x = A x + B u,   x(0) = x0
##
##         inf
## J(x0) = INT (x' Q x  +  u' R u  +  2 x' S u)  dt
##          0
##
## L = eig (A - B*G)
## @end group
## @end example
## @seealso{lqr, care, dare, dlqe}
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: April 2012
## Version: 0.1

function [l, p, e] = lqe (a, g, c, q = [], r = [], s = [])

  if (nargin < 3 || nargin > 6)
    print_usage ();
  endif

  if (isa (a, "lti"))
    [l, p, e] = lqr (a.', g, c, q);         # lqe (sys, q, r, s), g=I, works like  lqr (sys.', q, r, s).'
  elseif (isempty (g))
    [l, p, e] = lqr (a.', c.', q, r, s);    # lqe (a, [], c, q, r, s), g=I, works like  lqr (a.', c.', q, r, s).'
  elseif (isempty (s))
    [l, p, e] = lqr (a.', c.', g*q*g.', r);
  else
    [l, p, e] = lqr (a.', c.', g*q*g.', r, g*s);
  endif

  l = l.';

endfunction
