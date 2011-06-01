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
## @deftypefn {Function File} {} subsref (@var{val}, @var{idx})
## Perform the subscripted element selection operation on the Galois
## array @var{val} according to the subscript specified by @var{idx}.
## @end deftypefn

function b = subsref (a, s)
  ## Convert s.type and s.subs cs-list to cell array before indexing them
  switch {s.type}{1}
    case "()"
      ind = {s.subs}{1};
      b = gf (a._x(ind{:}), a._m, a._prim_poly);
    case "{}"
      error ("galois field can not be indexed with {}");
    case "."
      fld = {s.subs}{1};
      if (strcmp (fld, "x"))
	b = a._x;
      elseif (strcmp (fld, "m"))
	b = a._m;
      elseif (strcmp (fld, "n"))
	b = a._n;
      elseif (strcmp (fld, "prim_poly"))
	b = a._prim_poly;
      elseif (strcmp (fld, "index_of"))
	b = a._index_of;
      elseif (strcmp (fld, "alpha_to"))
	b = a._alpha_to;
      else
	error ("subsref: unrecognized value in galois field");
      endif
  endswitch

  if (numel ({s.type}) > 1)
    snew.type = {s.type}{2:end};
    snew.subs = {s.subs}{2:end};
    b = subsref (b, snew);
  endif
endfunction

%!shared g
%! g = gf(0:7,3,11);

%!assert(g(5:8),gf(4:7,3))
%!assert(g.m,3)
%!assert(g.n,7)
%!assert(g.prim_poly,11)
%!assert(g.index_of,[7;0;1;3;2;6;4;5])
%!assert(g.alpha_to,[1;2;4;3;6;7;5;0])
