## Copyright (C) 2002 David Bateman
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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## -*- texinfo -*-
## @deftypefn {Function File} {} gdeconv (@var{y}, @var{a})
## Deconvolve two Galois vectors.
##
## @code{[b, r] = gdeconv (y, a)} solves for @var{b} and @var{r} such that
## @code{y = gconv (a, b) + r}.
##
## If @var{y} and @var{a} are polynomial coefficient vectors, @var{b} will
## contain the coefficients of the polynomial quotient and @var{r} will be
## a remander polynomial of lowest order.
## @end deftypefn
## @seealso{gconv,deconv,conv}

## PKG_ADD: dispatch ("deconv", "gdeconv", "galois");
function [b, r] = gdeconv (y, a)


  if (nargin != 2)
    usage ("gdeconv(a, b)");
  endif

  if (!isgalois (y) && !isgalois (a))
    error("gdeconv: at least one argument must be a galois variable");
  elseif (!isgalois (y))
    y = gf(y, a.m, a.prim_poly);
  elseif (!isgalois (a))
    a = gf(a, y.m, y.prim_poly);
  elseif (a.m != y.m && a.prim_poly != y.prim_poly)
    error("gdeconv: both vectors must be in the same galois field");
  endif
  
  if (min(size(a)) > 1 || min(size(y)) > 1)
    error("gdeconv: both arguments must be vectors");
  endif

  la = length (a);
  ly = length (y);

  lb = ly - la + 1;

  ## Ensure that both vectors are row vectors.
  if (rows (a) > 1)
    a = greshape (a, 1, la);
  endif
  if (rows (y) > 1)
    y = greshape (y, 1, ly);
  endif
  
  if (ly > la)
    b = gfilter (y, a, [1, (zeros (1, ly - la))]);
  elseif (ly == la)
    b = gfilter (y, a, 1);
  else
    b = gf(0, y.m, y.prim_poly);
  endif

  lc = la + length (b) - 1;
  if (ly == lc)
    r = y - gconv (a, b);
  else
    ## Can't concatenate galois variables like this yet
    ## r = [(zeros (1, lc - ly)), y] - gconv (a, b);
    r = gf([(zeros (1, lc - ly)), y], y.m, y.prim_poly) - gconv (a, b);
  endif

endfunction
