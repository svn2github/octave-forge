## Copyright (C) 2008 David Bateman
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
## @deftypefn {Function File} {[@var{l}, @var{c}, @var{m}, @var{msg}] =} colstyle (@var{s})
## Parse a linespec and return its components. The linetype is returned
## as the variable @var{l}, the color as @var{c} and the marker type as
## @var{m}. If the linespec is incorrectly parsed, do not return an
## error but rather return the error as the argument @var{msg}.
## @end deftypefn

function [l, c, m, msg] = colstyle (s)
  try
    opt = __pltopt__ ("colstyle", s);
    msg = [];
    l = opt.linestyle;
    c = opt.color;
    m = opt.marker;

    if (isvector(c) && length (c) == 3)
      if (all (c == [0, 0, 0]))
	c = "k";
      elseif (all (c == [1, 0, 0]))
	c = "r";
      elseif (all (c == [0, 1, 0]))
	c = "g";
      elseif (all (c == [0, 0, 1]))
	c = "b";
      elseif (all (c == [1, 1, 0]))
	c = "y";
      elseif (all (c == [1, 0, 1]))
	c = "m";
      elseif (all (c == [0, 1, 1]))
	c = "c";
      elseif (all (c == [0, 1, 1]))
	c = "w";
      endif
    endif
  catch
    l = [];
    c = [];
    m = [];
    msg = lasterr ();
  end_try_catch
endfunction
