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
## @deftypefn {Built-in Function} {} uminus (@var{x})
## Unary minus operator equivalent to @w{@code{- x}}. This is a 
## null operator for the Galois fields @w{@code{GF(2^@var{m})}}.
## @end deftypefn

function y = uminus (g)
  y = g;
endfunction

%!assert(-gf(0:7,3),gf(0:7,3))
