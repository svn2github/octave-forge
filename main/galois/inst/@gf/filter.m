## Copyright (C) 2011 David Bateman
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {y =} filter (@var{b}, @var{a}, @var{x})
## @deftypefnx {Function File} {[@var{y}, @var{sf}] =} filter (@var{b}, @var{a}, @var{x}, @var{si})
## 
## Digital filtering of vectors in a Galois Field. Returns the solution to
## the following linear, time-invariant difference equation over a Galois
## Field:
## @iftex
## @tex
## $$
## \\sum_{k=0}^N a_{k+1} y_{n-k} = \\sum_{k=0}^M b_{k+1} x_{n-k}, \\qquad
##  1 \\le n \\le P
## $$
## @end tex
## @end iftex
## @ifinfo
## 
## @smallexample
##    N                   M
##   SUM a(k+1) y(n-k) = SUM b(k+1) x(n-k)      for 1<=n<=length(x)
##   k=0                 k=0
## @end smallexample
## @end ifinfo
## 
## @noindent
## where
## @ifinfo
##  N=length(a)-1 and M=length(b)-1.
## @end ifinfo
## @iftex
## @tex
##  $a \\in \\Re^{N-1}$, $b \\in \\Re^{M-1}$, and $x \\in \\Re^P$.
## @end tex
## @end iftex
## An equivalent form of this equation is:
## @iftex
## @tex
## $$
## y_n = -\\sum_{k=1}^N c_{k+1} y_{n-k} + \\sum_{k=0}^M d_{k+1} x_{n-k}, \\qquad
##  1 \\le n \\le P
## $$
## @end tex
## @end iftex
## @ifinfo
## 
## @smallexample
##             N                   M
##   y(n) = - SUM c(k+1) y(n-k) + SUM d(k+1) x(n-k)  for 1<=n<=length(x)
##            k=1                 k=0
## @end smallexample
## @end ifinfo
## 
## @noindent
## where
## @ifinfo
##  c = a/a(1) and d = b/a(1).
## @end ifinfo
## @iftex
## @tex
## $c = a/a_1$ and $d = b/a_1$.
## @end tex
## @end iftex
## 
## If the fourth argument @var{si} is provided, it is taken as the
## initial state of the system and the final state is returned as
## @var{sf}.  The state vector is a column vector whose length is
## equal to the length of the longest coefficient vector minus one.
## If @var{si} is not supplied, the initial state vector is set to all
## zeros.
## @end deftypefn

function [y, sf] = filter (b, a, x, si)
  if (nargin == 3)
    [a, b, x] = promote_and_check (a, b, x);
    if (rows(x) == 1)
      si = gf (zeros (1, max (length (a), length (b)) - 1), a._m, a._prim_poly);
    else
      si = gf (zeros (max (length (a), length (b)) - 1, 1), a._m, a._prim_poly);
    endif
  elseif (nargin > 4)
    [a, b, x, si] = promote_and_check (a, b, x, si);
  else
    print_usage();
  endif

  if (! (isvector (a) && isvector (b) && isvector (x) && isvector (si)))
    error ("filter: arguments must be vectors")
  endif

  if (numel (a) > numel (b))
    if (rows (b) == 1)
      b = [b, zeros(1,numel(a)-numel(b))];
    else
      b = [b; zeros(numel(a)-numel(b)),1];
    endif
  elseif (numel (a) < numel (b))
    if (rows (a) == 1)
      a = [a, zeros(1,numel(b)-numel(a))];
    else
      a = [a; zeros(numel(b)-numel(a)),1];
    endif
  endif

  [y, sf] = __gfilter__ (b._x, a._x, x._x, si._x, a._m, a._alpha_to, a._index_of);

  sf = gf (sf, x._m, x._prim_poly);
  y = gf (y, x._m, x._prim_poly);

endfunction

%!test
%! b = gf([2, 0, 0, 1, 0, 2, 0, 1], 2);
%! a = gf([2, 0, 1, 1], 2);
%! x = gf([1, zeros(1,20)], 2);
%! y = filter(b, a, x);
%! assert(y, gf([1, 0, 3, 0, 2, 3, 1, 0, 1, 3, 3, 1, 0, 1, 3, 3, 1, 0, 1, 3, 3], 2))
