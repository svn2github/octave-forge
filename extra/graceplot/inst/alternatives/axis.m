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
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} axis (@var{limits})
## Set axis limits for plots.
##
## The argument @var{limits} should be a 2, 4, or 6 element vector.  The
## first and second elements specify the lower and upper limits for the x
## axis.  The third and fourth specify the limits for the y axis, and the
## fifth and sixth specify the limits for the z axis.
##
## If your plot is already drawn, then you need to use @code{replot} before
## the new axis limits will take effect.  You can get this to happen
## automatically by setting the built-in variable @code{automatic_replot}
## to a nonzero value.
##
## Without any arguments, @code{axis} turns autoscaling on.
##
## The vector argument specifying limits is optional, and additional
## string arguments may be used to specify various axis properties.  For
## example,
##
## @example
## axis ([1, 2, 3, 4], "square");
## @end example
##
## @noindent
## forces a square aspect ratio, and
##
## @example
## axis ("labely", "tic");
## @end example
##
## @noindent
## turns tic marks on for all axes and tic mark labels on for the y-axis
## only.
##
## @noindent
## The following options control the aspect ratio of the axes.
##
## @table @code
## @item "square"
## Force a square aspect ratio.
## @item "equal"
## Force x distance to equal y-distance.
## @item "normal"
## Restore the balance.
## @end table
##
## @noindent
## The following options control the way axis limits are interpreted.
##
## @table @code
## @item "auto" 
## Set the specified axes to have nice limits around the data
## or all if no axes are specified.
## @item "manual" 
## Fix the current axes limits.
## @item "tight"
## Fix axes to the limits of the data (not implemented).
## @end table
##
## @noindent
## The option @code{"image"} is equivalent to @code{"tight"} and
## @code{"equal"}.
##
## @noindent
## The following options affect the appearance of tic marks.
##
## @table @code
## @item "on" 
## Turn tic marks and labels on for all axes.
## @item "off"
## Turn tic marks off for all axes.
## @item "tic[xyz]"
## Turn tic marks on for all axes, or turn them on for the
## specified axes and off for the remainder.
## @item "label[xyz]"
## Turn tic labels on for all axes, or turn them on for the 
## specified axes and off for the remainder.
## @item "nolabel"
## Turn tic labels off for all axes.
## @end table
## Note, if there are no tic marks for an axis, there can be no labels.
##
## @noindent
## The following options affect the direction of increasing values on
## the axes.
##
## @table @code
## @item "ij"
## Reverse y-axis, so lower values are nearer the top.
## @item "xy" 
## Restore y-axis, so higher values are nearer the top. 
## @end table
## @end deftypefn

## Author: jwe
## Modified to work with Grace by Teemu Ikonen <tpikonen@pcu.helsinki.fi>
## Created: 28.7.2003

function curr_axis = axis (ax, varargin)

  ## This may not be correct if someone has used the gnuplot interface
  ## directly...

  global __current_axis__ = [-10, 10, -10, 10];

  ## To return curr_axis properly, octave needs to take control of scaling.
  ## It isn't hard to compute good axis limits:
  ##   scale = 10 ^ floor (log10 (max - min) - 1);
  ##   r = scale * [floor (min / scale), ceil (max / scale)];
  ## However, with axis("manual") there is little need to know the current
  ## limits.

  if (nargin == 0)
#    __gnuplot_set__ autoscale;
    warning("Not implemented in Grace");
    curr_axis = __current_axis__;

  elseif (ischar (ax))
    ax = tolower (ax);
    len = length (ax);

    ## 'matrix mode' to reverse the y-axis
    if (strcmp (ax, "ij"))
      __grcmd__("yaxes invert on");
    elseif (strcmp (ax, "xy"))
      __grcmd__("yaxes invert off");

      ## aspect ratio
    elseif (strcmp (ax, "image"))
#      __gnuplot_set__ size ratio -1; 
#      __gnuplot_set__ autoscale; ## XXX FIXME XXX should be the same as "tight"
    warning("Not implemented in Grace");
    elseif (strcmp (ax, "equal"))
#      __gnuplot_set__ size ratio -1;
    warning("Not implemented in Grace");
    elseif (strcmp (ax, "square"))
#      __gnuplot_set__ size ratio 1;
      warning("Not implemented in Grace");
    elseif (strcmp (ax, "normal"))
#      __gnuplot_set__ size noratio;
      warning("Not implemented in Grace");

      ## axis limits
    elseif (len >= 4 && strcmp (ax(1:4), "auto"))
      if (len > 4)
#      	eval (sprintf ("__gnuplot_set__ autoscale %s;", ax(5:len)));
	warning("Not implemented in Grace");
      else
#	__gnuplot_set__ autoscale;
	warning("Not implemented in Grace");
      endif
    elseif (strcmp (ax, "manual"))
      ## fixes the axis limits, like axis(axis) should;
#      __gnuplot_set__ xrange [] writeback;
#      __gnuplot_set__ yrange [] writeback;
#      __gnuplot_set__ zrange [] writeback;
      ## XXX FIXME XXX if writeback were set in plot, no need to replot here.
#      replot; 
#      __gnuplot_set__ noautoscale x;
#      __gnuplot_set__ noautoscale y;
#      __gnuplot_set__ noautoscale z;
      warning("Not implemented in Grace");
    elseif (strcmp (ax, "tight"))
      ## XXX FIXME XXX if tight, plot must set ranges to limits of the
      ## all the data on the current plot, even if from a previous call.
      ## Instead, just let gnuplot do as it likes.
#      __gnuplot_set__ autoscale;
      warning("Not implemented in Grace");

      ## tic marks
    elseif (strcmp (ax, "on"))
#      __gnuplot_set__ xtics;
#      __gnuplot_set__ ytics;
#      __gnuplot_set__ ztics;
#      __gnuplot_set__ format;
      warning("Not implemented in Grace");
    elseif (strcmp (ax, "off"))
#      __gnuplot_set__ noxtics;
#      __gnuplot_set__ noytics;
#      __gnuplot_set__ noztics;
      warning("Not implemented in Grace");
    elseif (strcmp (ax, "tic"))
#      __gnuplot_set__ xtics;
#      __gnuplot_set__ ytics;
#      __gnuplot_set__ ztics;
      warning("Not implemented in Grace");
    elseif (len > 3 && strcmp (ax(1:3), "tic"))
#       if (any (ax == "x"))
# 	__gnuplot_set__ xtics;
#       else
# 	__gnuplot_set__ noxtics;
#       endif
#       if (any (ax == "y"))
# 	__gnuplot_set__ ytics;
#       else
# 	__gnuplot_set__ noytics;
#       endif
#       if (any (ax == "z"))
# 	__gnuplot_set__ ztics;
#       else
# 	__gnuplot_set__ noztics;
#       endif
      warning("Not implemented in Grace");

    elseif (strcmp (ax, "label"))
#      __gnuplot_set__ format;
      warning("Not implemented in Grace");
    elseif (strcmp (ax, "nolabel"))
#      __gnuplot_set__ format "\\0";
      warning("Not implemented in Grace");
    elseif (len > 5 && strcmp (ax(1:5), "label"))
#       if (any (ax == "x"))
# 	__gnuplot_set__ format x;
#       else
# 	__gnuplot_set__ format x "\\0";
#       endif
#       if (any (ax == "y"))
# 	__gnuplot_set__ format y;
#       else
# 	__gnuplot_set__ format y "\\0";
#       endif
#       if (any (ax == "z"))
# 	__gnuplot_set__ format z;
#       else
# 	__gnuplot_set__ format z "\\0";
#       endif
      warning("Not implemented in Grace");
    else
      warning ("unknown axis option '%s'", ax);
    endif

  elseif (isvector (ax))

    len = length (ax);

#    if (len != 2 && len != 4 && len != 6)
#      error ("axis: expecting vector with 2, 4, or 6 elements");
#    endif

    if (len != 2 && len != 4)
      error ("axis: expecting vector with 2 or 4 elements");
    endif

    __current_axis__ = reshape (ax, 1, len);

    if (len > 1)
      __grcmd__(sprintf ("world xmin %g; world xmax %g", ax(1), ax(2)));
    endif

    if (len > 3)
      __grcmd__(sprintf ("world ymin %g; world ymax %g", ax(3), ax(4)));
    endif

#    if (len > 5)
#      eval (sprintf ("__gnuplot_set__ zrange [%g:%g];", ax(5), ax(6)));
#    endif

  else
#    error ("axis: expecting no args, or a vector with 2, 4, or 6 elements");
    error ("axis: expecting no args, or a vector with 2 or 4 elements");
  endif

  if (nargin > 1)
    axis (varargin{:});
  endif
endfunction

%!demo
%! t=0:0.01:2*pi; x=sin(t);
%!
%! subplot(221);    title("normal plot");
%! plot(t, x, ";;");
%!
%! subplot(222);    title("square plot");
%! axis("square");  plot(t, x, ";;");
%!
%! subplot(223);    title("equal plot");
%! axis("equal");   plot(t, x, ";;");
%! 
%! subplot(224);    title("normal plot again");
%! axis("normal");  plot(t, x, ";;");

%!demo
%! t=0:0.01:2*pi; x=sin(t);
%!
%! subplot(121);   title("ij plot");
%! axis("ij");     plot(t, x, ";;");
%!
%! subplot(122);   title("xy plot");
%! axis("xy");     plot(t, x, ";;");

%!demo
%! t=0:0.01:2*pi; x=sin(t);
%!
%! subplot(331);   title("x tics & labels");
%! axis("ticx");   plot(t, x, ";;");
%!
%! subplot(332);   title("y tics & labels");
%! axis("ticy");   plot(t, x, ";;");
%!
%! subplot(334);     title("x & y tics, x labels");
%! axis("labelx","tic");   plot(t, x, ";;");
%!
%! subplot(335);     title("x & y tics, y labels");
%! axis("labely","tic");   plot(t, x, ";;");
%!
%! subplot(337);     title("x tics, no labels");
%! axis("nolabel","ticx");   plot(t, x, ";;");
%!
%! subplot(338);     title("y tics, no labels");
%! axis("nolabel","ticy");   plot(t, x, ";;");
%!
%! subplot(333);     title("no tics or labels");
%! axis("off");    plot(t, x, ";;");
%!
%! subplot(336);     title("all tics but no labels");
%! axis("nolabel","tic");    plot(t, x, ";;");
%!
%! subplot(339);     title("all tics & labels");
%! axis("on");       plot(t, x, ";;");

%!demo
%! t=0:0.01:2*pi; x=sin(t);
%!
%! subplot(321);    title("axes at [0 3 0 1]")
%! axis([0,3,0,1]); plot(t, x, ";;");
%!
%! subplot(322);    title("auto");
%! axis("auto");    plot(t, x, ";;");
%!
%! subplot(323);    title("manual");
%! plot(t, x, ";sine [0:2pi];"); hold on;
%! axis("manual");
%! plot(-3:3,-3:3, ";line (-3,-3)->(3,3);"); hold off;
%!
%! subplot(324);    title("axes at [0 3 0 1], then autox");
%! axis([0,3,0,1]); axis("autox");
%! plot(t, x, ";sine [0:2pi];");
%!
%! subplot(325);    title("axes at [3 6 0 1], then autoy");
%! axis([3,6,0,1]); axis("autoy");
%! plot(t, x, ";sine [0:2p];");
%!
%! subplot(326);    title("tight");
%! axis("tight");   plot(t, x, ";;");
%! % The last plot should not have any whitespace outside the data
%! % limits, but "tight" isn't implemented yet.
