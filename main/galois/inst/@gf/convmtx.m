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
## @deftypefn {Function File} {} convmtx (@var{a}, @var{n})
##
## Create matrix to perform repeated convolutions with the same vector
## in a Galois Field. If @var{a} is a column vector and @var{x} is  a 
## column vector of length @var{n}, in a Galois Field then 
##
## @code{convmtx(@var{a}, @var{n}) * @var{x}}
##
## gives the convolution of of @var{a} and @var{x} and is the
## same as @code{conv(@var{a}, @var{x})}. The difference is if
## many vectors are to be convolved with the same vector, then
## this technique is possibly faster.
##
## Similarly, if @var{a} is a row vector and @var{x} is a row 
## vector of length @var{n}, then
##
## @code{@var{x} * convmtx(@var{a}, @var{n})}
##
## is the same as @code{conv(@var{x}, @var{a})}.
## @end deftypefn
## @seealso{conv}

function b = convmtx (a, n)

  if (!isgalois (a))
    error("convmtx: argument must be a galois variable");
  endif

  b = gf(convmtx(a._x, n), a._m, a._prim_poly);
endfunction

%!test
%! grow = gf (0:7, 3);
%! b = gf([1,0,0,1,0,1,0,1],3);
%! a = gf([1,0,1,1],3);
%! x = gf([1,zeros(1,99)],3);
%! y1 = conv(grow+1, grow);
%! y2 = grow * convmtx(grow+1, length(grow));
%! assert (all(y1 == y2));


