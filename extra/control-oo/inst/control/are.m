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
## Adapted for LTI Syncope by Lukas Reichlin, October 2009

function x = are (a, b, c, opt)

  if (nargin == 3 || nargin == 4)
    if (nargin == 4)
      if (! (ischar (opt)
	     && (strcmp (opt, "N") || strcmp (opt, "P")
		 || strcmp (opt, "S") || strcmp (opt, "B")
		 || strcmp (opt, "n") || strcmp (opt, "p")
		 || strcmp (opt, "s") || strcmp (opt, "b"))))
        warning ("are: opt has an invalid value; setting to B");
        opt = "B";
      endif
    else
      opt = "B";
    endif
    if ((n = issquare(a)) == 0)
      error ("are: a is not square");
    endif

    if (isctrb (a, b) == 0)
      warning ("are: a, b are not controllable");
    endif
    if ((m = issquare (b)) == 0)
      b = b * b';
      m = rows (b);
    endif
    if (isobsv (a, c) == 0)
      warning ("are: a,c are not observable");
    endif
    if ((p = issquare (c)) == 0)
      c = c' * c;
      p = rows (c);
    endif
    if (n != m || n != p)
      error ("are: a, b, c not conformably dimensioned.");
    endif

    ## Should check for controllability/observability here
    ## use Boley-Golub (Syst. Contr. Letters, 1984) method, not the
    ##
    ##                     n-1
    ## rank ([ B A*B ... A^   *B]) method

    ## RE: isctrb, isobsv use arnoldi/krylov

    [d, h] = balance ([a, -b; -c, -a'], opt);
    [u, s] = schur (h, "A");
    u = d * u;
    n1 = n + 1;
    n2 = 2 * n;
    x = u (n1:n2, 1:n) / u (1:n, 1:n);
  else
    print_usage ();
  endif

endfunction
