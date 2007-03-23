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
## @deftypefn {Function File} {[@var{s}, @var{i}] =} fsort (@var{x})
## Return a copy of the fixed point variable @var{x} with the elements
## arranged in increasing order.  For matrices, @code{fsort} orders the 
## elements in each column.
##
## For example,
##
## @example
## @group
## fsort (fixed(4,0,[1, 2; 2, 3; 3, 1]))
##     @result{}  1  1
##         2  2
##         3  3
## @end group
## @end example
##
## The @code{fsort} function may also be used to produce a matrix
## containing the original row indices of the elements in the sorted
## matrix.  For example,
##
## @example
## @group
## [s, i] = sort ([1, 2; 2, 3; 3, 1])
##      @result{} s = 1  1
##             2  2
##             3  3
##      @result{} i = 1  3
##             2  1
##             3  2
## @end group
## @end example
## @end deftypefn

## PKG_ADD: dispatch ("sort", "fsort", "fixed scalar")
## PKG_ADD: dispatch ("sort", "fsort", "fixed matrix")
## PKG_ADD: dispatch ("sort", "fsort", "fixed complex")
## PKG_ADD: dispatch ("sort", "fsort", "fixed complex matrix")

function [s, i] = fsort (x)
   if (!isfixed(x))
     error("fsort: input argument not of fixed point type");
   endif
   [a, i] = sort(x.x);
   if isvector(a)
     s = x(i);
   else
     s = x;
     for j=1:size(i,2)
       s(:,j) = s(i(:,j),j);
     endfor
   endif
endfunction
