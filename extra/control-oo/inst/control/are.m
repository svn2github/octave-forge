## Copyright (C) 1993, 1994, 1995, 2000, 2002, 2004, 2005, 2006, 2007
##               Auburn University.  All rights reserved.
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{x} =} are (@var{a}, @var{b}, @var{c}, @var{opt})
## Solve the Algebraic Riccati Equation
## @iftex
## @tex
## $$
## A^TX + XA - XBX + C = 0
## $$
## @end tex
## @end iftex
## @ifinfo
## @example
## a' * x + x * a - x * b * x + c = 0
## @end example
## @end ifinfo
##
## @strong{Inputs}
## @noindent
## for identically dimensioned square matrices
## @table @var
## @item a
## @var{n} by @var{n} matrix;
## @item b
##   @var{n} by @var{n} matrix or @var{n} by @var{m} matrix; in the latter case
##   @var{b} is replaced by @math{b:=b*b'};
## @item c
##   @var{n} by @var{n} matrix or @var{p} by @var{m} matrix; in the latter case
##   @var{c} is replaced by @math{c:=c'*c};
## @item opt
## (optional argument; default = @code{"B"}):
## String option passed to @code{balance} prior to ordered Schur decomposition.
## @end table
##
## @strong{Output}
## @table @var
## @item x
## solution of the @acronym{ARE}.
## @end table
##
## @strong{Method}
## Laub's Schur method (@acronym{IEEE} Transactions on
## Automatic Control, 1979) is applied to the appropriate Hamiltonian
## matrix.
## @seealso{balance, dare}
## @end deftypefn

## Author: A. S. Hodel <a.s.hodel@eng.auburn.edu>
## Created: August 1993

## Adapted-By: Lukas Reichlin <lukas.reichlin@gmail.com>
## Date: October 2009
## Version: 0.1

function x = are (a, b, c, opt = "B")

  if (nargin < 3 || nargin > 4)
    print_usage ();
  endif

  if (nargin == 4)
    if (ischar (opt))
      opt = upper (opt(1));
      if (opt != "B" && opt != N && opt != "P" && opt != "S")
        warning ("are: opt has invalid value ""%s""; setting to ""B""", opt);
        opt = "B";
      endif
    else
      warning ("are: invalid argument opt, setting to ""B""");
      opt = "B";
    endif
  endif

  n = issquare (a);
  m = issquare (b);
  p = issquare (c);

  if (! n)
    error ("are: matrix a is not square");
  endif

  if (! isctrb (a, b))
    warning ("are: matrices a and b are not controllable");
  endif

  if (! m)
    b = b * b';  # b must be symmetric
    m = rows (b);
  endif

  if (! isobsv (a, c))
    warning ("are: matrices a and c are not observable");
  endif

  ## to allow lqe design, don't force
  ## b to be positive semi-definite

  if (! p)
    c = c' * c;  # c must be symmetric
    p = rows (c);
  endif

  if (n != m || n != p)
    error ("are: matrices a, b and c not conformably dimensioned");
  endif

  [d, h] = balance ([a, -b; -c, -a'], opt);
  [u, s] = schur (h, "A");

  u = d * u;
  n1 = n + 1;
  n2 = 2 * n;

  x = u(n1:n2, 1:n) / u(1:n, 1:n);

endfunction
