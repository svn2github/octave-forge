## Copyright (C) 2003 Teemu Ikonen
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This software is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this software; see the file COPYING.  If not, write to the Free
## Software Foundation, 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Built-in Function} {} ishold
## Return 1 if the next line will be added to the current plot, or 0 if
## the plot device will be cleared before drawing the next line.
## @end deftypefn
 
## Author: Teemu Ikonen <tpikonen@pcu.helsinki.fi>
## Created: 25.7.2003

function a = ishold()
  a = __grishold__();
endfunction