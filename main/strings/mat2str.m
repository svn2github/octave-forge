## Copyright (C) 1996 John W. Eaton
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
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## usage: mat2str (x)
##
## Format x as a string suitable for use in eval.
##
## See also: sprintf, int2str

## Author: John W. Eaton
## Modified by: Ariel Tankus, 15.6.98 .
## Modified by: Paul Kienzle, 15.7.00, to handle matrices. 

function retval = mat2str (x)

  if (nargin == 1)
    [nr, nc] = size(x);
    if (nr*nc == 1)
      retval = sprintf ("%.100g", x);
    else
      retval = sprintf (" %.100g,", x.');
      retval(1) = "[";
      retval(length(retval)) = "]";
      idx = find (retval == ",");
      retval(idx(nc:nc:length(idx))) = ";";
    endif
  else
    usage ("mat2str (x)");
  endif

endfunction
