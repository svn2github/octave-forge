## Copyright (C) 2003 Motorola Inc and David Bateman
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
## @deftypefn {Function File} {@var{x} =} concat (@var{a}, @var{b})
## @deftypefnx {Function File} {@var{x} =} concat (@var{a}, @var{b}, @var{dim})
## Concatenate two matrices regardless of their type. Due to the implementation
## of the matrix concatenation in Octave being hard-coded for the types it
## knowns, user types can not use the matrix concatenation operator. Thus
## for the @emph{Galois} and @emph{Fixed Point} types, the in-built matrix
## concatenation functions will return a matrix value as their solution.
##
## This function allows these types to be concatenated. If called with a
## user type that is not known by this function, the in-built concatenate
## function is used.
##
## If @var{dim} is 1, then the matrices are concatenated, else if @var{dim}
## is 2, they are stacked.
## @end deftypefn

function y = concat ( a, b, dim)

  if (nargin < 2) || (nargin > 3)
    usage("concat(a, b, [dim])");
  elseif (nargin == 2)
    dim = 1;
  endif

  done = 0;
  ## Protect this with try for the case is the Galois package isn't installed
  try
    if (isgalois(a) || isgalois(b))
      if (isgalois(a))
	m = a.m;
	p = a.prim_poly;
	ax = a.x;
	if isgalois(b)
	  if ((b.m != m) || (b.prim_poly != p))
	    error("concat: incompatiable galois variables");
	  else
	    bx = b.x;
	  endif
	else
	  bx = b;
	endif
      else
	ax = a;
	m = b.m;
	p = b.prim_poly;
	bx = b.x;
      endif
      if (dim == 1)
	y = gf([ax, bx], m, p);
      else
	y = gf([ax; bx], m, p);
      endif
      done = 1;
    endif
  catch
  end

  ## Protect this with try for the case is the fixed package isn't installed
  try
    if (isfixed(a) || isfixed(b))
      if (!isfixed(a))
	a = fixed(a);
      endif
      if (!isfixed(b))
	b = fixed(b);
      endif
      if (dim == 1)
	y = fixed([a.int, b.int], [a.dec, b.dec], [a.x, b.x]);
      else
	y = fixed([a.int; b.int], [a.dec; b.dec], [a.x; b.x]);
      endif
      done = 1;
    endif
  catch
  end

  if (!done)
    fprintf("What are we doing here!!\n");
    if (dim == 1)
      y = [a, b];
    else
      y = [a; b];
    endif
  endif

endfunction
