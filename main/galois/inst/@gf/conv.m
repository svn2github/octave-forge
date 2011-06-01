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
## @deftypefn {Function File} {} conv (@var{a}, @var{b})
## Convolve two Galois vectors.
##
## @code{y = conv (a, b)} returns a vector of length equal to
## @code{length (a) + length (b) - 1}.
## If @var{a} and @var{b} are polynomial coefficient vectors, @code{conv}
## returns the coefficients of the product polynomial.
## @end deftypefn
## @seealso{deconv}

function y = conv (a, b)

  if (nargin != 2)
    usage ("conv(a, b)");
  endif

  if (!isgalois (a) && !isgalois (b))
    error("conv: at least one argument must be a galois variable");
  elseif (!isgalois (a))
    a = gf(a, b._m, b._prim_poly);
  elseif (!isgalois (b))
    b = gf(b, a._m, a._prim_poly);
  elseif (a._m != b._m && a._prim_poly != b._prim_poly)
    error("conv: both vectors must be in the same galois field");
  endif
  
  if (min(size(a)) > 1 || min(size(b)) > 1)
    error("conv: both arguments must be vectors");
  endif

  la = length (a);
  lb = length (b);

  ly = la + lb - 1;

  ## Ensure that both vectors are row vectors.
  if (rows (a) > 1)
    a = reshape (a, 1, la);
  endif
  if (rows (b) > 1)
    b = reshape (b, 1, lb);
  endif

  ## Use the shortest vector as the coefficent vector to filter.
  if (la < lb)
    if (ly > lb)
      ## Can't concatenate galois variables like this yet
      ## x = [b, (zeros (1, ly - lb))];
      x = gf([b, (zeros (1, ly - lb))], b._m, b._prim_poly);
    else
      x = b;
    endif
    y = filter (a, 1, x);
  else
    if(ly > la)
      ## Can't concatenate galois variables like this yet
      ## x = [a, (zeros (1, ly - la))];
      x = gf([a, (zeros (1, ly - la))], a._m, a._prim_poly);
    else
      x = a;
    endif
    y = filter (b, 1, x);
  endif

endfunction

%!test
%! poly1 = gf([2,4,5,1],3);
%! poly2 = gf([1,2],3);
%! mulpoly = conv(poly1, poly2);    ## multiplication
%! poly3 = [poly,remd] = deconv(mulpoly, poly2);
%! assert (isequal(poly1,poly3))
%! assert (!any (remd))

