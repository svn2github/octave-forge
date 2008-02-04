## Copyright (C) 1996, 1997 John W. Eaton
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
## @deftypefn {Function File} {} __plt2__ (@var{x1}, @var{x2}, @var{fmt})
## @end deftypefn

## Author: jwe

function __plt2__ (x1, x2, fmt)

  if (nargin < 2 || nargin > 3)
    usage ("__plt2__ (x1, x2, fmt)");
  endif

  if (nargin == 2)
    fmt = "";
  endif

  if (! ischar (fmt))
    error ("__plt2__: fmt must be a string");
  endif

  if (any (any (imag (x1))))
    x1 = real (x1);
  endif
  if (any (any (imag (x2))))
    x2 = real (x2);
  endif
  if (isscalar (x1))
    if (isscalar (x2))
      __plt2ss__ (x1, x2, fmt);
    endif
  elseif (isvector (x1))
    if (isvector (x2))
      __plt2vv__ (x1, x2, fmt);
    elseif (ismatrix (x2))
      __plt2vm__ (x1, x2, fmt);
    endif
  elseif (ismatrix (x1))
    if (isvector (x2))
      __plt2mv__ (x1, x2, fmt);
    elseif (ismatrix (x2))
      __plt2mm__ (x1, x2, fmt);
    endif
  endif

endfunction
