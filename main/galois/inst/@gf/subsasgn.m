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

## @deftypefn {Function File} {} subsasgn (@var{val}, @var{idx}, @var{rhs})
## Perform the subscripted assignment operation on the Galois array
## @var{val} according to the subscript specified by @var{idx}.
## @end deftypefn

function s = subsasgn (s, index, val)
  switch (index.type)
    case "()"
      if ((isgalois(val) && (val._m == s._m) && (val._prim_poly == s._prim_poly))
	  || (isnumeric (val) && !iscomplex(val) 
	      && any (val(:) >= 2.^ s._m) && any (val(:) < 0) 
	      && any (val(:) != fix(val(:)))))
	s._x = subsasgn (s._x, index, double (val));
      else
	error ("subsasgn: value must be an array of real integers between 0 and 2.^m - 1");
      endif
    case "."
      error ("subsagn: can not set properties of a galois field directly");
    otherwise
      error ("subsagn: illegal sub-assignment to a galois field");
  endswitch
endfunction

%!test
%! g = gf(0:7,3);
%! g(5:8) = gf(0:3,3);
%! assert(g,gf([0:3,0:3],3))
