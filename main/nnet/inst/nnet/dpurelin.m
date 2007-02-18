## Copyright (C) 2005 Michel D. Schmid     <michaelschmid@users.sourceforge.net>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} @var{a} = dpurelin (@var{n})
## @code{dpurelin}, first derivative of purelin
## @example
##
## purelin is a linear transfer function used by neural networks
## @end example
##
## @end deftypefn

## Author: mds
## $LastChangedDate: 2006-08-20 21:47:51 +0200 (Sun, 20 Aug 2006) $
## $Rev: 38 $

function a = dpurelin(n)

   [nRows, nColumns] = size(n);
   a = ones(nRows,nColumns);

endfunction