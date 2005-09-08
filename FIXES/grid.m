## Copyright (C) 1996 John W. Eaton
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

## usage: grid ("on" | "off" | mode)
##
## Turn grid lines on or off for plotting. Without any argument switch on or
## off grid (depending of previous state).
##
## mode can be "x#y#z#", where # is the number of minor tics between the
## major tics.  If x, y, or z is absent then no grid lines are produced
## for that axis.  If # is absent then there are no grid lines for minor
## tics.  If # is '-', then the current number of minor tics is
## preserved and grid lines are turned on between them.
##
## Use "gset mxtics #" to control the number of minor tics directly.
##
## See also: plot, semilogx, semilogy, loglog, polar, mesh, contour,
##           bar, stairs, gplot, gsplot, replot, xlabel, ylabel, title

## Author: John W. Eaton
## 2001-04-02  Laurent Mazet <mazet@crm.mot.com>
##     * add support for semilog[xy] and loglog minor grid.
##     * add mode feature (suggested by Paul Kienzle).
## 2005-04-23  Dmitri A. Sergatskov <dasergatskov@gmail.com>
##     * modified to use new gnuplot interface in octave > 2.9.0

function grid (mode)

  if (nargin == 0)
    if isempty(gget("grid"))
      mode = "xyz";
    else
      mode = "";
    endif
  elseif (nargin == 1)
    if (ischar (mode))
      if (strcmp ("off", mode))
        mode = "";
      elseif (strcmp ("on", mode))
        mode = "xyz";
      endif
    else
      error ("grid: argument must be a string");
    endif
  else
    error ("usage: grid (\"on\" | \"off\" | mode)");
  endif

  if isempty(mode)

    __gnuplot_raw__ ("unset grid;\n")

  else

    len = length(mode);
    i = 1;
    while i <= len
      if any(mode(i) == "xyz")
	[n, has_n, err, next] = sscanf(mode(i+1:len), "%d", 1);
	if has_n
	  cmd = sprintf("set m%stics %d;", mode(i), n);
	  __gnuplot_raw__ (cmd)
	  cmd = sprintf("set grid %stics m%stics;", mode(i), mode(i));
	  __gnuplot_raw__ (cmd)
	  i = i + next;
	elseif i+1<=len && mode(i+1) == '-'
	  cmd = sprintf("set grid %stics m%stics;", mode(i), mode(i));
	  __gnuplot_raw__ (cmd)
	  i = i + 2;
	else
	  cmd = sprintf("set grid %stics nom%stics;", mode(i), mode(i));
	  __gnuplot_raw__ (cmd)
	  i = i + 1;
	endif
      else
	error("grid: unknown mode %s at character %d", mode, i);
      endif
    endwhile
    if all(mode != "x")
      __gnuplot_raw__ ("set grid noxtics nomxtics;\n")
    endif
    if all(mode != "y")
      __gnuplot_raw__ ("set grid noytics nomytics;\n")
    endif
    if all(mode != "z")
      __gnuplot_raw__ ("set grid noztics nomztics;\n")
    endif
  endif
  
endfunction
