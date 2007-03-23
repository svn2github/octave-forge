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
## @deftypefn {Function File} {} groots (@var{v})
##
## For a vector @var{v} with @math{N} components, return
## the roots of the polynomial over a Galois Field
## @iftex
## @tex
## $$
## v_1 z^{N-1} + \cdots + v_{N-1} z + v_N.
## $$
## @end tex
## @end iftex
## @ifinfo
##
## @example
## v(1) * z^(N-1) + ... + v(N-1) * z + v(N).
## @end example
## @end ifinfo
##
## The number of roots returned and their value will be determined 
## by the order and primitive polynomial of the Galios Field
## @end deftypefn
## @seealso{roots}

## PKG_ADD: dispatch ("roots", "groots", "galois");
function r = groots (v)

  if (nargin != 1)
    error("usage: r = groots(v)");
  endif

  if (!isgalois(v))
    error("groots: argument must be a galois variable");
  endif

  if (min (size (v)) > 1 || nargin != 1)
    usage ("groots (v), where v is a galois vector");
  endif

  v = greshape (v, 1, length(v));
  m = v.m;
  prim_poly = v.prim_poly; 
  n = 2^m - 1;
  poly = v;
  nr = 0;
  t = 0;
  r = [];        

  while ((t <= n)  && (length(poly) > 1))
    [npoly, nrem] = gdeconv(poly,gf([1,t],m,prim_poly));
    if (any(nrem))
      t = t + 1;
    else
      nr = nr + 1;
      r(nr) = t;
      poly = npoly;
    endif
  end

  r = gf(r,m,prim_poly);        
    
endfunction
