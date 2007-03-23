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
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{table} =} create_lookup_table (@var{x}, @var{y})
## Creates a lookup table betwen the vectors @var{x} and @var{y}. If @var{x}
## is not in increasing order, the vectors are sorted before being stored.
## @end deftypefn

function table = create_lookup_table (x, y)
  if any(size(x) != size(y))
    error("create_lookup_table: tables must have the same dimension");
  elseif ! isvector(x)
    error("create_lookup_table: tables must be vectors");
  else
    ## This assumes that fsort is overloading sort for fixed point types
    [table.x, idx] = sort(x);
    table.y = y(idx);
  endif
endfunction
