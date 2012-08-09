## Copyright (C) 2012 Benjamin Lewis <benjf5@gmail.com>
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*-texinfo-*-
## @deftypefn  {Function File} {a =} cubicwgt {series}
## Return the series as windowed by a cubic polynomial,
## 1 + ( x ^ 2 * ( 2 x - 3 ) ), assuming x is in [-1,1].
## @end deftypefn

## This function implements the windowing function on page 10 of the paper.
## if t is in [-1,1] then the windowed term is a = 1 + ( |t|^2 * ( 2|t| - 3 )
## else the windowed term is 0.
function a = cubicwgt(s) ## where s is the value to be windowed
  a = abs(s);
  a = ifelse( ( a < 1 ), 1 + ( ( a .^ 2 ) .* ( 2 .* a - 3 ) ), a = 0);
endfunction

%!test
%!shared h, m, k
%! h = 2;
%! m = 0.01;
%! k = [ 0 , 3 , 1.5, -1, -0.5, -0.25, 0.75 ];
%!assert( cubicwgt(h), 0 );
%!assert( cubicwgt(m), 1 + m ^ 2 * ( 2 * m - 3 ));
%!assert( cubicwgt(k), [ 1.00000, 0.00000, 0.00000, 0.00000, 0.50000, 0.84375, 0.15625], 1e-6); 
%! ## Tests cubicwgt on two scalars and two vectors; cubicwgt will work
%! ## on any array input. 