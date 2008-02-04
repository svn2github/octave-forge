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
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{y} =} float (@var{x})
## Converts a fixed point object to the equivalent floating point object. This
## is equivalent to @code{@var{x}.x} if @code{isfixed(@var{x})} returns true,
## and returns @var{x} otherwise.
## @end deftypefn

function y = float (x)

  if isfixed(x)
    y = x.x;
  else
    y = x;
  endif

endfunction
