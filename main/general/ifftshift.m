## Copyright (C) 1997 by Vincent Cautaerts
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this file.  If not, write to the Free Software Foundation,
## 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} ifftshift (@var{v})
## Undo the action of the fftshift function.  For even length @var{v}, fftshift
## is its own inverse, but odd lengths differ slightly.
## @end deftypefn

## Author: Vincent Cautaerts <vincent@comf5.comm.eng.osaka-u.ac.jp>
## Created: July 1997
## Adapted-By: jwe
## Modified-By: Paul Kienzle, converted from fftshift

function retval = ifftshift (V)

  retval = 0;

  if (nargin != 1)
    usage ("usage: ifftshift (X)");
  endif

  if (is_vector (V))
    x = length (V);
    xx = floor (x/2);
    retval = V([xx+1:x, 1:xx]);
  elseif (is_matrix (V))
    [x, y] = size (V);
    xx = floor (x/2);
    yy = floor (y/2);
    retval = V([xx+1:x, 1:xx], [yy+1:y, 1:yy]);
  else
    error ("ifftshift: expecting vector or matrix argument");
  endif

endfunction
