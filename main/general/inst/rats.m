## Copyright (C) 2001 Paul Kienzle
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
## @deftypefn {Function File} {@var{s}} = rats (@var{x}, @var{tol})
## 
## Convert @var{x} into a rational approximation represented as a string.
## You can convert the string back into a matrix as follows:
##
## @example
##    eval(["[",rats(hilb(4)),"];"])
## @end example
##
## The optional second argument defines the tolerance to that the
## rational approximation will be calculated to.
## @end deftypefn
## @seealso{rat}

function T = rats(x, tol)
  if nargin != 1 && nargin != 2
    usage("S = rats(x, tol)");
  endif

  ## default norm
  if (nargin < 2)
    tol = 1e-6 * norm(x(:),1);
  endif

  try
    [n, d] = rat (permute (x, [2, 1, 3:ndims(x)]), tol);
  catch
    [n, d] = rat(x', tol);
  end
  sz = size (x);
  nc = sz(2);
  len = prod (sz);

  S = sprintf("%d/%d ", [n(:), d(:)]');
  if (len == 1)
    T = S;
  else
    index = findstr(S, "/1 ");
    if (index)
      S = toascii(S);
      S([index, index+1]) = [];
      S = char(S);
    endif
    index = find(S == " ");
    shift = [index(1), diff(index)];
    cellsize = max(shift);
    shift = cellsize - shift;
    assign = ones(size(S));
    index = index(1:len-1);
    assign([1,index]) = assign([1,index]) + ceil(shift/2);
    assign(index) = assign(index) + floor(shift(1:len-1)/2);
    assign = cumsum(assign);
    T = char(toascii(" ")*ones(1, len*cellsize+1));
    T(assign+1) = S;
    T(nc*cellsize+1:nc*cellsize:len*cellsize) = "\n";
    T(1)="\n";
  endif

endfunction
