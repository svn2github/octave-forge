## Copyright (C) 2006 Michel D. Schmid <michaelschmid@users.sourceforge.net>
##
## This program is part of octnnettb.
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
## @deftypefn {Function File} {}[@var{a} = tansig (@var{n})
## A neural feed-forward network will be trained with @code{trainlm}
##
## @end deftypefn

## @seealso{purelin}

## Author: Michel D. Schmid <michaelschmid@users.sourceforge.net>
## $LastChangedDate: 2006-08-20 21:47:51 +0200 (Sun, 20 Aug 2006) $
## $Rev: 38 $


function a = tansig(n)

  ## see MATLAB(TM) online help
  a = 2 ./ (1 + exp(-2*n)) - 1;
  ## attention with critical values ==> infinite values
  ## must be set to 1
  i = find(!finite(a));
  a(i) = sign(n(i));

endfunction