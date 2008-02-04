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
## along with this software; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} xlabel (@var{string})
## @deftypefnx {Function File} {} ylabel (@var{string})
## Specify x, and y axis labels for the Grace plot.  
## @end deftypefn
## @seealso{plot, semilogx, semilogy, loglog, polar, 
## bar, stairs, ylabel, and title}

## Author: Teemu Ikonen <tpikonen@pcu.helsinki.fi>
## Created: 28.7.2003

function xlabel(lstr)

  __grcmd__(sprintf("xaxis label \"%s\"", lstr));

endfunction
