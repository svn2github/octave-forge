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
## @deftypefn {Function File} {} all (@var{x}, @var{dim})
## For a Galois array @var{x}, return true if all of the elements along the
## dimension @var{dim} are non-zero.
## @end deftypefn

function y = all (g, varargin)
  y = all (g._x, varargin{:});
endfunction

%!assert (all (gf (0:3, 2)), false)
%!assert (all (gf (ones(1,4), 2)), true)
