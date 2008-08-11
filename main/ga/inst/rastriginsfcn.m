## Copyright (C) 2008 Luca Favatella <slackydeb@gmail.com>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program  is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn{Function File} {} rastriginsfcn (@var{x})
## Rastrigin's function.
## @end deftypefn

## Author: Luca Favatella <slackydeb@gmail.com>
## Version: 1.1

function retval = rastriginsfcn (x)
  retval = 20 + (x(1) ** 2) + (x(2) ** 2) - 10 * (cos (2 * pi * x(1)) + 
                                                  cos (2 * pi * x(2)));
endfunction

%!assert (rastriginsfcn ([0, 0]), 0)