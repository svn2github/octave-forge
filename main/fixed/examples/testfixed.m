## Copyright (C) 2003 Motorola Inc
## Copyright (C) 2003 David Bateman
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
## @deftypefn {Function File} {} testfixed ()
## 
## Tiny function file demonstrating the use of functions that are defined
## once with floating and fixed point types.
## @end deftypefn

function [b, bf] = testfixed(is,ds,n)
a = randn(n,n);
af = fixed(is,ds,a);
b = myfunc(a,a);
bf = myfunc(af,af);
endfunction

function y = myfunc(a,b)
y = a + b;
endfunction
