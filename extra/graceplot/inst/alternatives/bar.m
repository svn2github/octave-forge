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
## @deftypefn {Function File} {} bar (@var{x}, @var{y})
## Given two vectors of x-y data, @code{bar} produces a bar graph.
##
## If only one argument is given, it is taken as a vector of y-values
## and the x coordinates are taken to be the indices of the elements.
##
## If two output arguments are specified, the data are generated but
## not plotted.  For example,
##
## @example
## bar (x, y);
## @end example
##
## @noindent
## and
##
## @example
## [xb, yb] = bar (x, y);
## plot (xb, yb);
## @end example
##
## @noindent
## are equivalent.
## @end deftypefn
## @seealso{plot, semilogx, semilogy, loglog, polar, 
## stairs, xlabel, ylabel, and title}

## Modified to use Grace by: Teemu Ikonen <tpikonen@pcu.helsinki.fi>
## Created: 28.7.2003

## Just replace the gnuplot commands with the Grace Bar plot with the
## right arguments, otherwise this is the same as the orginal bar.m -TI

function [xb, yb] = bar (x, y)

  if (nargin == 1)
    if (isvector (x))
      len = 3 * length (x) + 1;
      tmp_xb = tmp_yb = zeros (len, 1);
      tmp_xb(1) = 0.5;
      tmp_yb(1) = 0;
      k = 1;
      for i = 2:3:len
        tmp_xb(i) = k-0.5;
        tmp_xb(i+1) = k+0.5;
        tmp_xb(i+2) = k+0.5;
        tmp_yb(i) = x(k);
        tmp_yb(i+1) = x(k);
        tmp_yb(i+2) = 0.0;
        k++;
      endfor
# Grace support
      gr_mat = [[1:length(x)]', x(:)];
# Grace ends      
    else
      error ("bar: argument must be a vector");
    endif
  elseif (nargin == 2)
    if (isvector (x) && isvector (y))
      xlen = length (x);
      ylen = length (y);
      if (xlen == ylen)
        len = 3 * xlen + 1;
        tmp_xb = tmp_yb = zeros (len, 1);
        cutoff = zeros (1, xlen-1);
        for i = 1:xlen-1
          cutoff(i) = (x(i) + x(i+1)) / 2.0;
        endfor
        delta_p = cutoff(1) - x(1);
        delta_m = delta_p;
        tmp_xb(1) = x(1) - delta_m;
        tmp_yb(1) = 0.0;
        k = 1;
        for i = 2:3:len
          tmp_xb(i) = tmp_xb(i-1);
          tmp_xb(i+1) = x(k) + delta_p;
          tmp_xb(i+2) = tmp_xb(i+1);
          tmp_yb(i) = y(k);
          tmp_yb(i+1) = y(k);
          tmp_yb(i+2) = 0.0;
          if (k < xlen)
            if (x(k+1) < x(k))
              error ("bar: x vector values must be in ascending order");
            endif
            delta_m = x(k+1) - cutoff(k);
            k++;
            if (k < xlen)
              delta_p = cutoff(k) - x(k);
            else
              delta_p = delta_m;
            endif
          endif
        endfor
# Grace support
	gr_mat = [x(:), y(:)];
# Grace support ends
      else
        error ("bar: arguments must be the same length");
      endif
    else
      error ("bar: arguments must be vectors");
    endif
  else
    usage ("[xb, yb] = bar (x, y)");
  endif
 
  if (nargout == 0)
#    plot (tmp_xb, tmp_yb);
    if(!__grishold__)
      __grcla__();
    endif
    __grnewset__();
    [cur_figure, cur_graph, cur_set] = __grgetstat__();
    __grcmd__(sprintf("focus g%i; g%i type bar; autoscale onread xyaxes", ...
		      cur_graph, cur_graph));
    __grcmd__(sprintf("g%i.s%i line type 0", cur_graph, cur_set));
    ## simple heuristics to set the bar width to be approximately correct
    bar_width = 42.0 / size(gr_mat,1) / 1.5
    __grcmd__(sprintf("g%i.s%i symbol size %g", cur_graph, cur_set,...
		      bar_width));
    __grsendmat__(gr_mat, "bar");
  else
    xb = tmp_xb;
    yb = tmp_yb;
  endif

endfunction
