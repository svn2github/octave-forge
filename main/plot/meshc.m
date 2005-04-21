## Copyright (C) 1996, 1997 John W. Eaton
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
## along with this program; see the file COPYING.  If not, write to the
## Free Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} meshc (@var{x}, @var{y}, @var{z})
## Plot a mesh given matrices @var{x}, and @var{y} from @code{meshdom} and
## a matrix @var{z} corresponding to the @var{x} and @var{y} coordinates of
## the mesh.  If @var{x} and @var{y} are vectors, then a typical vertex
## is (@var{x}(j), @var{y}(i), @var{z}(i,j)).  Thus, columns of @var{z}
## correspond to different @var{x} values and rows of @var{z} correspond
## to different @var{y} values.
## @end deftypefn
## @seealso{plot, semilogx, semilogy, loglog, polar, meshgrid, meshdom,
## contour, bar, stairs, gplot, gsplot, replot, xlabel, ylabel, and title}

## Author: John W. Eaton
## Modified: 2000-11-17 Paul Kienzle <kienzle.powernet.co.uk>
##   copied from Octave 2.1.31 mesh.m, with contours turned on
##   if added to octave, make __mesh__.m which takes the usual paramters
##   in addition to 'surface' and 'contour' so that this code gets reused.

## Modified to use new gnuplot interface in octave > 2.9.0
## Replaced 'mesh" with "meshc" in misc. error strings
## Dmitri A. Sergatskov <dasergatskov@gmail.com>
## April 18, 2005

function meshc (x, y, z)

  ## XXX FIXME XXX -- the plot states should really just be set
  ## temporarily, probably inside an unwind_protect block, but there is
  ## no way to determine their current values.

  if (nargin == 1)
    z = x;
    if (is_matrix (z))
      __gnuplot_raw__ ("set nokey;\n");
      __gnuplot_raw__ ("set hidden3d;\n");
      __gnuplot_raw__ ("set data style lines;\n");
      __gnuplot_raw__ ("set surface;\n");
      __gnuplot_raw__ ("set contour;\n");
      __gnuplot_raw__ ("set noparametric;\n");
      __gnuplot_raw__ ("set view 60, 30, 1, 1;\n");
      __gnuplot_splot__ z'
    else
      error ("meshc: argument must be a matrix");
    endif
  elseif (nargin == 3)
    if (is_vector (x) && is_vector (y) && is_matrix (z))
      xlen = length (x);
      ylen = length (y);
      if (xlen == columns (z) && ylen == rows (z))
        if (rows (y) == 1)
          y = y';
        endif
        len = 3 * xlen;
        zz = zeros (ylen, len);
        k = 1;
        for i = 1:3:len
          zz(:,i)   = x(k) * ones (ylen, 1);
          zz(:,i+1) = y;
          zz(:,i+2) = z(:,k);
          k++;
        endfor
	__gnuplot_raw__ ("set nokey;\n");
	__gnuplot_raw__ ("set hidden3d;\n");
	__gnuplot_raw__ ("set data style lines;\n");
	__gnuplot_raw__ ("set surface;\n");
	__gnuplot_raw__ ("set contour;\n");
	__gnuplot_raw__ ("set parametric;\n");
	__gnuplot_raw__ ("set view 60, 30, 1, 1;\n");
        __gnuplot_splot__ zz
        __gnuplot_raw__ ("set noparametric;\n");
      else
        msg = "meshc: rows (z) must be the same as length (y) and";
        msg = sprintf ("%s\ncolumns (z) must be the same as length (x)", msg);
        error (msg);
      endif
    elseif (is_matrix (x) && is_matrix (y) && is_matrix (z))
      xlen = columns (z);
      ylen = rows (z);
      if (xlen == columns (x) && xlen == columns (y) &&
        ylen == rows (x) && ylen == rows(y))
        len = 3 * xlen;
        zz = zeros (ylen, len);
        k = 1;
        for i = 1:3:len
          zz(:,i)   = x(:,k);
          zz(:,i+1) = y(:,k);
          zz(:,i+2) = z(:,k);
          k++;
        endfor
	__gnuplot_raw__ ("set nokey;\n");
	__gnuplot_raw__ ("set hidden3d;\n");
	__gnuplot_raw__ ("set data style lines;\n");
	__gnuplot_raw__ ("set surface;\n");
	__gnuplot_raw__ ("set contour;\n");
	__gnuplot_raw__ ("set parametric;\n");
	__gnuplot_raw__ ("set view 60, 30, 1, 1;\n");
        __gnuplot_splot__ zz
        __gnuplot_raw__ ("set noparametric;\n");
      else
        error ("meshc: x, y, and z must have same dimensions");
      endif
    else
      error ("meshc: x and y must be vectors and z must be a matrix");
    endif
  else
    usage ("meshc (z)");
  endif

endfunction
