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

## S = rat(x,tol)
## Convert x into a rational approximation represented as a string.  You
## can convert the string back into a matrix as follows:
##
##    eval(["[",rats(hilb(4)),"];"])

function T = rats(x)
  if nargin != 1
    usage("S = rats(x)");
  endif

  [n, d] = rat(x');
  [nr, nc] = size(x);

  len = nr*nc;
  S = sprintf("%d/%d ", [n(:), d(:)]');
  if (len == 1)
    T = S;
  else
    index = findstr(S, "/1 ");
    if (index)
      S = toascii(S);
      S([index, index+1]) = [];
      S = setstr(S);
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
    T = setstr(toascii(" ")*ones(1, nr*nc*cellsize+1));
    T(assign+1) = S;
    T(nc*cellsize+1:nc*cellsize:nr*nc*cellsize) = "\n";
    T(1)='\n';
  endif

endfunction