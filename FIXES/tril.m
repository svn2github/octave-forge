## Copyright (C) 1996, 1997 John W. Eaton
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, write to the Free
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} tril (@var{a}, @var{k})
## @deftypefnx {Function File} {} triu (@var{a}, @var{k})
## Return a new matrix formed by extracting extract the lower (@code{tril})
## or upper (@code{triu}) triangular part of the matrix @var{a}, and
## setting all other elements to zero.  The second argument is optional,
## and specifies how many diagonals above or below the main diagonal should
## also be set to zero.
##
## The default value of @var{k} is zero, so that @code{triu} and
## @code{tril} normally include the main diagonal as part of the result
## matrix.
##
## If the value of @var{k} is negative, additional elements above (for
## @code{tril}) or below (for @code{triu}) the main diagonal are also
## selected.
##
## The absolute value of @var{k} must not be greater than the number of
## sub- or super-diagonals.
##
## For example,
##
## @example
## @group
## tril (ones (3), -1)
##      @result{}  0  0  0
##          1  0  0
##          1  1  0
## @end group
## @end example
##
## @noindent
## and
##
## @example
## @group
## tril (ones (3), 1)
##      @result{}  1  1  0
##          1  1  1
##          1  1  1
## @end group
## @end example
## @end deftypefn
## @seealso{triu and diag}

## Author: jwe

function x = triu (x, k)

  if (nargin < 1 || nargin > 2)
    usage ("triu (x, k)");
  endif
  if (nargin == 1)
    k = 0;
  endif

  [nr, nc] = size (x);
  if ( nr*nc > 0 )
    x ( ones(nr,1)*[1:nc] - [1:nr]'*ones(1,nc) > k ) = 0;
  endif

endfunction
