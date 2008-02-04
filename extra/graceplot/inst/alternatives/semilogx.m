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
## along with this software; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} semilogx (@var{args})
## Make a two-dimensional plot using a log scale for the @var{x} axis.  See
## the description of @code{plot} for a description of the arguments
## that @code{semilogx} will accept.
## @end deftypefn
## @seealso{plot, semilogy, loglog, polar, mesh, contour, bar, stairs,
## __gnuplot_plot__, __gnuplot_splot__, replot, xlabel, ylabel, and title}

## Author: jwe

function semilogx (varargin)

  __plt__ ("semilogx", varargin{:});

endfunction
