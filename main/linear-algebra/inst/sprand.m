## Copyright (C) 2004-2011 Paul Kienzle
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or (at
## your option) any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.
##
## Original version by Paul Kienzle distributed as free software in the
## public domain.

## -*- texinfo -*-
## @deftypefn  {Function File} {} sprand (@var{m}, @var{n}, @var{d})
## @deftypefnx {Function File} {} sprand (@var{s})
## Generate a random sparse matrix.  The size of the matrix will be
## @var{m} by @var{n}, with a density of values given by @var{d}.
## @var{d} should be between 0 and 1.  Values will be uniformly
## distributed between 0 and 1.
##
## If called with a single matrix argument, a sparse random matrix is generated, 
## with the same sparsity pattern as the matrix @var{S}.
## @seealso{sprandn}
## @end deftypefn

## Author: Paul Kienzle <pkienzle@users.sf.net>
##
## Changelog:
##
## Piotr Krzyzanowski <przykry2004@users.sf.net>
##      2004-09-27      use Paul's hint to allow larger random matrices
##                      at the price of sometimes lower density than desired
## David Bateman
##      2004-10-20      Texinfo help and copyright message
##
## Piotr Krzyzanowski <przykry2004@users.sf.net>
## 	2011-03-13	Use sample() function to provide exactly 
##			the density needed even when m*n is very large
##			under a reasonable assumption d is not too large;
##                      Assertions and a demo.

function S = sprand (m, n, d)

  if (nargin != 1 && nargin != 3)
    print_usage ();
  endif

  if (nargin == 1)
    [i, j, v] = find (m);
    [nr, nc] = size (m);
    S = sparse (i, j, rand (size (v)), nr, nc);
    return;
  endif

  if (!(isscalar (m) && m == fix (m) && m > 0))
    error ("sprand: M must be an integer greater than 0");
  endif

  if (!(isscalar (n) && n == fix (n) && n > 0))
    error ("sprand: N must be an integer greater than 0");
  endif

  if (d < 0 || d > 1)
    error ("sprand: density D must be between 0 and 1");
  endif

  mn = n*m;
  ## how many entries in S would be satisfactory?
  k = round (d*mn);
  idx = sample(k,mn); 
  ## idx contains k random numbers in [0,mn-1]
  j = floor (idx/m); % j in 0..n-1
  idx = idx - j*m; % idx takes the role of "i", i in 0..m-1
  if (isempty (idx))
    S = sparse (m, n);
  else
    idx = idx + 1; % indices should begin from "1"
    j = j + 1;
    S = sparse (idx, j, rand (k, 1), m, n);
  endif

endfunction

%!assert (issparse(sprand(10,10,0.1)));
%!assert (nnz(sprand(10,10,0.1)) <= 10);
%!assert (nnz(sprand(1e4,10,0.1)) <= 1e4);
%!assert (nnz(sprand(10,1e4,0.1)) <= 1e4);
%!assert (nnz(sprand(1e2,1e2,5e-2)) <= 5e2);
%!demo
%! s = sprand(1e2,1e2,5e-2);
%! spy(s);
%! % s should be a sparse 100x100 matrix with at most 500 nonzero entries
