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
## @deftypefn {Function File} {[@var{x}, @var{l}, @var{g}] =} care (@var{a}, @var{b}, @var{q}, @var{r})
## @deftypefnx {Function File} {[@var{x}, @var{l}, @var{g}] =} care (@var{a}, @var{b}, @var{q}, @var{r}, @var{s})
## Return unique stabilizing solution x of the continuous-time
## riccati equation as well as the closed-loop poles l and the
## corresponding gain matrix g.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2009
## Version: 0.1

function [x, l, g] = care (a, b, q, r, s = [], opt = "B")

  if (nargin < 4 || nargin > 6)
    print_usage ();
  endif

  if (nargin == 6)
    if (ischar (opt))
      opt = upper (opt(1));
      if (opt != "B" && opt != N && opt != "P" && opt != "S")
        warning ("dare: opt has invalid value ""%s""; setting to ""B""", opt);
        opt = "B";
      endif
    else
      warning ("dare: invalid argument opt, setting to ""B""");
      opt = "B";
    endif
  endif

  [n, m] = size (b);
  p = issquare (q);
  m1 = issquare (r);

  if (! m1)
    error ("care: r is not square");
  elseif (m1 != m)
    error ("care: b, r are not conformable");
  endif

  if (! p)
    q = q' * q;
  endif

  ## incorporate cross term into a and q
  if (isempty (s))
    s = zeros (n, m);
    ao = a;
    qo = q;
  else
    [n2, m2] = size (s);

    if (n2 != n || m2 != m)
      error ("care: s (%dx%d) must be identically dimensioned with b (%dx%d)",
              n2, m2, n, m);
    endif

    ao = a - (b/r)*s';
    qo = q - (s/r)*s';
  endif

  ## check stabilizability
  if (! isstabilizable (ao, b, [], 0))
    error ("care: a and b not stabilizable");
  endif

  ## check detectability
  dflag = isdetectable (ao, qo, [], 0);

  if (dflag == 0)
    warning ("care: a and q not detectable");
  elseif (dflag == -1)
    error ("care: a and q have poles on imaginary axis");
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