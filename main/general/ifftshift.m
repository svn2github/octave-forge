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
## Modified-By: David Bateman, add NDArray capability and option dim arg

function retval = ifftshift (V, dim)

  retval = 0;

  if (nargin != 1 && nargin != 2)
    usage ("usage: ifftshift (X, dim)");
  endif

  if (nargin == 2)
    if (!isscalar (dim))
      error ("ifftshift: dimension must be an integer scalar");
    endif
    nd = ndims (V);
    sz = size (V);
    sz2 = floor (sz(dim) / 2);
    idx = cell ();
    for i=1:nd
      idx {i} = 1:sz(i);
    endfor
    idx {dim} = [sz2+1:sz(dim), 1:sz2];
    retval = V (idx{:});
  else
    if (isvector (V))
      x = length (V);
      xx = floor (x/2);
      retval = V([xx+1:x, 1:xx]);
    elseif (ismatrix (V))
      nd = ndims (V);
      sz = size (V);
      sz2 = floor (sz ./ 2);
      idx = cell ();
      for i=1:nd
        idx{i} = [sz2(i)+1:sz(i), 1:sz2(i)];
      endfor
      retval = V (idx{:});
    else
      error ("ifftshift: expecting vector or matrix argument");
    endif
  endif

endfunction
