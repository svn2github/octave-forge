## Copyright (C) 1996, 1997 John W. Eaton
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, write to the Free
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} triu (@var{a}, @var{k})
## See tril.
## @end deftypefn

## Author: jwe

function x = triu (x, k)

  if (nargin < 1 || nargin > 2)
    usage ("triu (x, k)");
  endif
  if (nargin == 1)
    k = 0;
  endif

  [nr, nc] = size (x);
  if ( nr*nc > 0 )
    x ( ones(nr,1)*[1:nc] - [1:nr]'*ones(1,nc) < k ) = 0;
  endif

endfunction
