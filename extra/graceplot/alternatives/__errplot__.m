## Copyright (C) 2000-2003 Teemu Ikonen
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

## -*- texinfo -*-
## @deftypefn {Function File} {} __errplot__ (@var{args})
## Really plot errorbar plots. User interface in function errorbar.
##
## @example
## __errplot__ (@var{arg1}, @var{arg2}, ..., @var{fmt})
## @end example
##
## @end deftypefn
## @seealso{semilogx, semilogy, loglog, polar, mesh, contour, __pltopt__
## bar, stairs, errorbar, gplot, gsplot, replot, xlabel, ylabel, and title}

## Created: 18.7.2000
## Author: Teemu Ikonen <tpikonen@pcu.helsinki.fi>
## Keywords: errorbar, plotting
## Adapted to work with Grace 4.8.2003

function __errplot__ (caller, varargin)

  if (nargin < 4) # at least two data arguments needed
    usage ("__errplot__ (caller, arg1, ..., fmt)");
  endif

  fstr = " ";
  ndata = 0;

  for k=1:length(varargin)
    a = varargin{k++};
    if (! isstr (a))
      ndata++;
      eval (sprintf ("arg%d = a;", ndata));
    else
      fstr = a;
    endif
  endfor

  fmt = __pltopt__ (caller, fstr);

  nplots = size (arg1, 2);
  len = size (arg1, 1);

  if (ndata == 2)
    for i = 1:nplots,
      tmp = [(1:len)', arg1(:,i), arg2(:,i)];
#      cmd = sprintf ("gplot tmp %s", fmt(min(i, rows(fmt)), :));
#      eval (cmd);
      fmt1 = fmt(min(i, rows(fmt)),:);
      if (index (fmt1, "xydx"))
        settype = "xydx";
      else
        settype = "xydy";
      endif
      __grpltfmt__(tmp, fmt1, settype);
    endfor
  elseif (ndata == 3)
    for i = 1:nplots,
      tstr = "tmp =[arg1(:,i)";
      for j = 2:ndata,
       tstr = [tstr, sprintf(", arg%d(:,i)", j)];
      endfor
      tstr = [tstr, "];"];
      eval (tstr);
#      cmd = sprintf ("gplot tmp %s", fmt(min(i, rows(fmt)), :));
#      eval (cmd);
      fmt1 = fmt(min(i, rows(fmt)),:);
      if (index (fmt1, "xydx"))
        settype = "xydx";
      else
        settype = "xydy";
      endif
      __grpltfmt__(tmp, fmt1, settype);
    endfor
  elseif (ndata == 4)
    for i = 1:nplots, # this is getting ugly
      #      if (index (fmt, "boxxy") || index (fmt, "xyerr"))
      fmt1 = fmt(min(i, rows(fmt)),:);
      if (index (fmt1, "xydxdy"))
        tstr = "tmp = [arg1(:,i), arg2(:,i), arg3(:,i), arg4(:,i)];";
        settype = "xydxdy";
      elseif (index (fmt1, "xydx"))
#        tstr = "tmp = [arg1(:,i), arg2(:,i), arg1(:,i)-arg3(:,i), arg1(:,i)+arg4(:,i)];";
        tstr = "tmp = [arg1(:,i), arg2(:,i), arg4(:,i), arg3(:,i)];";
        settype = "xydxdx";
      else
#        tstr = "tmp = [arg1(:,i), arg2(:,i), arg2(:,i)-arg3(:,i), arg2(:,i)+arg4(:,i)];";
        tstr = "tmp = [arg1(:,i), arg2(:,i), arg4(:,i), arg3(:,i)];";
        settype = "xydydy";
      endif
      eval (tstr);
#      cmd = sprintf ("gplot tmp %s", fmt(min(i, rows(fmt)), :));
#      eval (cmd);
      __grpltfmt__(tmp, fmt1, settype);
    endfor
  elseif (ndata == 6)
    for i = 1:nplots,
      #      tstr = "tmp = [arg1(:,i), arg2(:,i), arg1(:,i)-arg3(:,i), arg1(:,i)+arg4(:,i), arg2(:,i)-arg5(:,i), arg2(:,i)+arg6(:,i)];";
      tstr = "tmp = [arg1(:,i), arg2(:,i), arg4(:,i), arg3(:,i), arg6(:,i), arg5(:,i)];";
      eval (tstr);
disp("polk");
#      cmd = sprintf ("gplot tmp %s", fmt(min(i, rows(fmt)), :));
#      eval (cmd);
      fmt1 = fmt(min(i, rows(fmt)),:);
      settype = "xydxdxdydy";
      __grpltfmt__(tmp, fmt1, settype);
    endfor
  else
    usage ("__errplot__ (arg1, ..., fmt)");
  endif

endfunction
