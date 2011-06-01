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
## @deftypefn  {Function File} {} promote_and_check (@dots{})
## Undocumented internal function
## @end deftypefn

function [varargout] = promote_and_check (varargin)
  for i = 1 : nargin
    arg = varargin{i};
    if (isa (arg, "gf"))
      m = arg._m;
      p = arg._prim_poly;
      break;
    endif
  endfor
  varargout = cell(1, nargout);
  for i = 1 : nargin
    arg = varargin{i};
    if (! isa (arg, "gf"))
      varargout{i} = gf (arg, m, p);
    else
      if (arg._m != m)
	error ("galois field orders must match");
      endif
      if (arg._prim_poly != p)
	error ("galois field primitive polynomials must match");
      endif
      varargout{i} = arg;
    endif
  endfor
endfunction
