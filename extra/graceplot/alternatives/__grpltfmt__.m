## Copyright (C) 2003 Teemu Ikonen
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

## function __grpltfmt__(a, fmt, settype)
##
## Plot the matrix a with Grace with a given format and settype.

## Created: 4.8.2003
## Author: Teemu Ikonen <tpikonen@pcu.helsinki.fi>

function __grpltfmt__(a, fmt, settype);

n = size(a,1);
m = size(a,2);

if( (m > 6) || (m < 1) )
  error("Number of columns must be between 1 to 6.");
endif
if(!isreal(a))
  error("Matrix must be real");
endif

settype = tolower(settype);
switch settype
    case "xy"
      checktype(2, m);
    case "xydx"
      checktype(3, m);
    case "xydy"
      checktype(3, m);
    case "xydxdx"
      checktype(4, m);
    case "xydydy"
      checktype(4, m);
    case "xydxdy"
      checktype(4, m);
    case "xydxdxdydy"
      checktype(6, m);
    case "bar"
      checktype(2, m);
    case "bardy"
      checktype(3, m);
    case "bardydy"
      checktype(4, m);
    case "xyhilo"
      checktype(5, m);
    case "xyz"
      checktype(3, m);
    case "xyr"
      checktype(3, m);
    case "xysize"
      checktype(3, m);
    case "xycolor"
      checktype(3, m);
    case "xycolpat"
      checktype(4, m);
    case "xyvmap"
      checktype(4, m);
    case "xyboxplot"
      checktype(6, m);
    otherwise
      error("unknown set type");
endswitch

__grnewset__();
[cur_figure, cur_graph, cur_set] = __grgetstat__();

graphid = sprintf("g%i.s%i", cur_graph, cur_set);
grace_fmt = strrep(fmt, "<grace_graphid>", graphid);
if(index(fmt, "type bar"))
  settype = "bar";
endif
## prepend a standard color specification the plot format,
## this will be overridden if the color is set in the format.
std_color = mod(cur_set, 19) + 1;
grace_fmt  = sprintf("%s line color %i; %s symbol fill %i; %s", 
		     graphid, std_color, graphid, std_color, grace_fmt);
__grcmd__(grace_fmt);

fname = tmpnam;
dlmwrite(fname, a, " ", 0, 0);
__grcmd__(sprintf("read %s \"%s\"", settype, fname));
__grcmd__("redraw");
mark_for_deletion(fname);

endfunction

function checktype(q, p)
  if(q != p)
    error("Wrong number of columns for this set type");
  endif
endfunction
