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
## @deftypefn {Loadable Function} {@var{y} =} isprimitive (@var{a})
##
## Returns 1 is the polynomial represented by @var{a} is a primitive
## polynomial of GF(2). Otherwise it returns zero.
##
## @end deftypefn
## @seealso{gf,primpoly}

function p = isprimitive (poly)
  if (poly._m != 1)
    error ("isprimitive: polynomials must be in GF(2)");
  endif

  x = poly._x;
  if (isvector (x) && columns(x) == 1)
    x = x.';
  endif
  p = isprimitive (sum (x .*  (2 .^ repmat (0 : columns (x) - 1, 
					    rows(x), 1)), 2));
endfunction
