## Copyright (C) 1998 Ariel Tankus
## 
## This program is free software.
## This file is part of the Image Processing Toolbox for Octave
##
## This program is free software; you can redistribute it and/or
## modify it under the terms of the GNU General Public License
## as published by the Free Software Foundation; either version 2
## of the License, or (at your option) any later version.
## 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
## 
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
##

## deal    Split the input vector into the corresponding number of output
##         parameters.  Possible usage: in functions where several input
##         arguments can be gathered to a single argument.
##
##         [...] = deal(v)
##         v - input vector.
##         [x1, x2, ..., xn] - outputs, each contains a single element of
##                             the vector v.
##

## Author: Ariel Tankus.
## Created: 13.11.98.

## pre 2.1.39 function [...] = deal(v)
function [varargout] = deal(v) ## pos 2.1.39

for i=1:nargout
  ## pre 2.1.39     vr_val(v(i));
  varargout{i} = v(i); ## pos 2.1.39
end
