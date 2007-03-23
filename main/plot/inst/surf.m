## Copyright (C) 2000 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

## Surface plot.  
##
## E.g.,
##
##    surf(peaks);
##
## Note that subsequent calls to mesh/meshc will also display a surface plot
## unless you do clf to clear the figure between plots.
##
## If you are getting warnings from gnuplot either install gnuplot 3.8i or set
##     global gnuplot_has_pm3d=0
## in your ~/.octaverc file.

## Modified to use new gnuplot interface in octave > 2.9.0
## Dmitri A. Sergatskov <dasergatskov@gmail.com>
## April 18, 2005

function surf(varargin)
   global gnuplot_has_pm3d;
   if !exist("gnuplot_has_pm3d") || gnuplot_has_pm3d!=0,
      __gnuplot_raw__ ("set pm3d at s ftriangles hidden3d 100;\n");
      __gnuplot_raw__ ("set line style 100 lt 5 lw 0.5;\n");
      __gnuplot_raw__ ("set nohidden3d;\n");
      __gnuplot_raw__ ("set nosurf;\n");
   endif
   mesh(varargin{:});
endfunction
