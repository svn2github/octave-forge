## Copyright (C) 2000-2001 Paul Kienzle
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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} {} unique (@var{x})
##
## Return the unique elements of @var{x}, sorted in ascending order.
## If @var{x} is a row vector, return a row vector, but if @var{x}
## is a column vector or a matrix return a column vector.
##
## @deftypefnx {Function File} {} unique (@var{A}, 'rows')
##
## Return the unique rows of @var{A}, sorted in ascending order.
##
## @deftypefnx {Function File} {[@var{y}, @var{i}, @var{j}] = } unique (@var{x})
##
## Return index vectors @var{i} and @var{j} such that @code{x(i)==y} and
## @code{y(i)==x}.
##
## @end deftypefn
## @seealso{union, intersect, setdiff, setxor, ismember}

function [y, i, j] = unique (x, r)

  if ( nargin < 1 || nargin > 2 || (nargin == 2 && !strcmp(r,"rows")) )
    usage ("unique (x) or unique (x, 'rows')");
  endif

  if (nargin == 1)
    n = prod(size(x));
  else
    n = rows(x);
  endif

  y = x; 
  if (n < 1)
    i = j = [];
    return
  elseif (n < 2)
    i = j = 1;
    return
  endif

  if isstr(x), y = toascii(y); endif

  if nargin == 2
    [y, i] = sortrows(y);
    match = all( [ y(1:n-1,:) == y(2:n,:) ]' );
    idx = find (match);
    y (idx, :) = [];
  else
    if (rows(y) != 1) y = y(:); endif
    [y, i] = sort(y);
    match = [ y(1:n-1) == y(2:n) ];
    idx = find (match);
    y (idx) = [];
  endif

  ## I don't know why anyone would need reverse indices, but it
  ## was an interesting challenge.  I welcome cleaner solutions.
  if (nargout >= 3)
    j = i;
    j (i) = cumsum ( prepad ( ~match, n, 1 ) );
  endif
  i (idx) = [];

  if isstr(x), y = setstr(y); endif

endfunction
