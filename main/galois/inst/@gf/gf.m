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
## @deftypefn {Function File} {@var{y} =} gf (@var{x})
## @deftypefnx {Function File} {@var{y} =} gf (@var{x}, @var{m})
## @deftypefnx {Function File} {@var{y} =} gf (@var{x}, @var{m}, @var{primpoly})
## Creates a Galois field array GF(2^@var{m}) from the matrix @var{x}. The
## Galois field has 2^@var{m} elements, where @var{m} must be between 1 and 16.
## The elements of @var{x} must be between 0 and 2^@var{m} - 1. If @var{m} is
## undefined it defaults to the value 1.
## 
## The primitive polynomial to use in the creation of Galois field can be
## specified with the @var{primpoly} variable. If this is undefined a default
## primitive polynomial is used. It should be noted that the primitive
## polynomial must be of the degree @var{m} and it must be irreducible.
## 
## The output of this function is recognized as a Galois field by Octave and
## other matrices will be converted to the same Galois field when used in an
## arithmetic operation with a Galois field.
## 
## @end deftypefn
## @seealso{isprimitive,primpoly}

function g = gf (x, m, p)  
  if (nargin < 1 || nargin > 3)
    print_usage ();
  endif
  if (isa (x, "gf"))
    g = x;
  else
    if (nargin < 2)
      m = 1;
    endif
    if (m < 1 || m > 16 || fix(m) != m)
      error ("gf: m must be an integer between 1 and 16");
    endif

    if (nargin < 3)
      p = primpoly (m, "nodisplay");
    else
      if (! isprimitive (p))
	error ("gf: polynomial is not primitive");
      endif
    endif

    if (! isnumeric (x) || iscomplex(x) ||any (x(:)) >= 2.^m || 
	any (x(:)) < 0 || any (x(:) != fix(x(:))))
      error ("gf: x must be an array of real integers between 0 and 2.^m - 1");
    endif

    g._x = double (x);
    g._prim_poly = p;
    g._m = m;
    g._n = 2.^m - 1;
    [g._alpha_to, g._index_of] = cachefield (m, p);
    g = class (g, "gf");
    superiorto ("double");
  endif
endfunction

%!test
%! gcol = gf (0:8, 3);
%! assert (gcol.m, 3);
%! assert (gcol.prim_poly, primpoly (3, "min", "nodisplay"));

%!test
%! gmat = gf (reshape (0:8, 3, 3), 3);
%! assert (gmat.m, 3);
%! assert (gmat.prim_poly, primpoly (3, "min", "nodisplay"));
