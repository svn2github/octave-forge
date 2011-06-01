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
## @deftypefn {Function File} {} lt (@var{a}, @var{b})
## Less than operator for Galois arrays.
## @end deftypefn

function y = lt (a, b)
  [a, b] = promote_and_check (a, b);
  y = a._x < b._x;
endfunction

%!assert(gf(1) < gf(1), false)
%!assert(gf(0) < gf(1), true)
%!assert(gf(1) < gf(0), false)

