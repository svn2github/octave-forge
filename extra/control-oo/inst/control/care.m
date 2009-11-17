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

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2009
## Version: 0.1

function [x, l, g] = care (a, b, q, r, s = [], opt = "B")

  warning ("care: under construction");

  if (nargin < 4 || nargin > 6)
    print_usage ();
  endif


  [n, m] = size (b);

  ## incorporate cross term into a and q
  if (isempty (s))
    s = zeros (n, m);
    ao = a;
    qo = q;
  else
    [n1, m1] = size (s);
    if (n1 != n || m1 != m)
      error ("care: s must be identically dimensioned with b");
    endif

    ao = a - (b/r)*s';
    qo = q - (s/r)*s';
  endif

  ## check qo and r
  if (! issymmetric (qo))
    error ("lqr: q must be symmetric");
  endif

  if (! issymmetric (r))
    error ("lqr: r must be symmetric");
  endif

  ## to allow lqe design, don't force
  ## qo to be positive semi-definite

  if (isdefinite (r) <= 0)
    error ("care: r must be positive definite");
  endif

  ## unique stabilizing solution
  x = are (ao, (b/r)*b', qo, opt);

  ## corresponding gain matrix
  g = r \ (b'*x + s');

  ## closed-loop poles
  l = eig (a - b*g);

endfunction