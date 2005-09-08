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

## __plt3__ is not a user callable function

## Author: Paul Kienzle <kienzle.powernet.co.uk>
## 2001-04-06 Paul Kienzle <kienzle.powernet.co.uk>
##     * gset nohidden3d; vector X,Y, matrix Z => meshgrid(X,Y)

## Modified to use new gnuplot interface in octave > 2.9.0
## Dmitri A. Sergatskov <dasergatskov@gmail.com>
## April 18, 2005

function __plt3__ (x, y, z, fmt)

  if (isvector(x) && isvector(y))
    if (isvector(z))
      x = x(:); y=y(:); z=z(:);
    elseif (length(x) == rows(z) && length(y) == columns(z))
      error("plot3: [length(x), length(y)] must match size(z)");
    else
      [x,y] = meshgrid(x,y);
    endif
  endif

  if (any(size(x) != size(y)) || any(size(x) != size(z)))
    error("plot3: x, y, and z must have the same shape");
  endif

  unwind_protect
    __gnuplot_raw__ ("set parametric;\n");
    __gnuplot_raw__ ("set nohidden3d;\n");
    for i=1:columns(x)
      tmp = [x(:,i), y(:,i), z(:,i)];
      cmd =  ["__gnuplot_splot__ tmp ", fmt, ";\n"];
      eval (cmd);
    endfor
  unwind_protect_cleanup
    __gnuplot_raw__ ("set noparametric;\n"); 
  end_unwind_protect
endfunction
