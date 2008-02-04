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
## @deftypefn {Function File} {} __pltopt__ (@var{caller}, @var{opt})
## Set plot options accoording to caller and plot option string.
##
## If @var{opt} is a valid option string, return a string of the form
## @code{"w l 2"} ("with lines 2").  Uses abbreviations for the options
## to avoid overrunning gnuplot's command line buffer unnecessarily.
##
## @var{opt} can currently be some combination of the following:
##
## @table @code
## @item "-"
## For lines plot style (default).
##
## @item "."
## For dots plot style.
##
## @item "@@"
## For points plot style.
##
## @item "-@@"
## For linespoints plot style.
##
## @item "^"
## For impulses plot style.
##
## @item "L"
## For steps plot style.
##
## @item "#"
## For boxes plot style.
##
## @item "~"
## For yerrorbars plot style.
##
## @item ">"
## For xerrorbars plot style.
##
## @item "~>"
## For xyerrorbars plot style.
##
## @item "#~"
## For boxerrorbars plot style.
##
## @item "#~>"
## For boxxyerrorbars plot style.
##
## @item "n"
## With @code{n} in 1-6 (wraps at 8), plot color
##
## @item "nm"
## With @code{m} in 1-6 (wraps at 6), point style (only valid for @code{"@@"} or
## @code{"-@@"})
##
## @item @var{c}
## Where @var{c} is one of @code{"r"}, @code{"g"}, @code{"b"}, @code{"m"},
## @code{"c"}, or @code{"w"} colors.
##
## @item ";title;"
## Here @code{"title"} is the label for the key.
##
## @item +
## @itemx *
## @itemx o
## @itemx x
## Used in combination with the points or linespoints styles, set the point
## style.
## @end table
##
## The legend may be fixed to include the name of the variable
## plotted in some future version of Octave.
##
## The colors, line styles, and point styles have the following
## meanings for X11 and Postscript terminals under Gnuplot 3.6.
##
## @example
## Number ------ Color -------  Line Style      ---- Points Style ----
##        x11       postscript  postscript      x11         postscript
## =====================================================================
##   1    red       green       solid           "o"         "+"
##   2    green     blue        long dash       "+"         "x"
##   3    blue      red         short dash     square       "*"
##   4    magenta   magenta     dotted          "x"        open square
##   5    cyan      cyan        dot long dash  triangle    filled square
##   6    brown     yellow      dot short dash  "*"         "o"
## @end example
## @end deftypefn
## @seealso{__pltopt1__}

## Author: jwe
## Modified to work with Grace by Teemu Ikonen <tpikonen@pcu.helsinki.fi> 
## Created: 28.7.2003

function fmt = __pltopt__ (caller, opt)

  if (! ischar (opt))
    usage ("__pltopt__ (caller, opt)");
  endif

  nr = rows (opt);
  fmt = " ";
  for i = 1:nr
    t = __pltopt1__ (caller, deblank (opt(i,:)));
    fmt(i,1:length(t)) = t;
  endfor

  if(strcmp(caller, "semilogx") || strcmp(caller, "semilogxerr"))
    graphfmt = "xaxes scale logarithmic; yaxes scale normal; "; 
  elseif(strcmp(caller, "semilogy") || strcmp(caller, "semilogyerr"))
    graphfmt = "xaxes scale normal; yaxes scale logarithmic; ";
  elseif(strcmp(caller, "loglog") || strcmp(caller, "loglogerr"))
    graphfmt = "xaxes scale logarithmic; yaxes scale logarithmic; ";
  else
    graphfmt = "xaxes scale normal; yaxes scale normal; ";
  endif

  s = strcat(graphfmt, fmt(1,:));
  fmt(1, 1:length(s)) = s;

endfunction
