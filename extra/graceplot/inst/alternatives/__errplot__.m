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
## Software Foundation, 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} __errplot__ (@var{args})
## Really plot errorbar plots. User interface in function errorbar.
##
## @example
## __errplot__ (@var{fstr}, @var{arg1}, ..., @var{arg6})
## @end example
##
## @end deftypefn
## @seealso{semilogx, semilogy, loglog, polar, mesh, contour, __pltopt__
## bar, stairs, errorbar, replot, xlabel, ylabel, and title}

## Created: 18.7.2000
## Author: Teemu Ikonen <tpikonen@pcu.helsinki.fi>
## Keywords: errorbar, plotting
## Adapted to work with Grace 4.8.2003

function __errplot__ (fstr,a1,a2,a3,a4,a5,a6)

  if (nargin < 3 || nargin > 7) # at least three data arguments needed
    usage ("__errplot__ (fmt, arg1, ...)");
  endif

  fmt = __pltopt__ ("__errplot__", fstr);

  nplots = size (a1, 2);
  len = size (a1, 1);
  for i = 1:nplots
    ifmt = fmt(1+mod(i,size(fmt,1)), :);
    switch (nargin - 1)
      case 2
	tmp = [(1:len)', a1(:,i), a2(:,i)];
	if (index (ifmt, "xydx"))
          settype = "xydx";
	else
          settype = "xydy";
	endif	
      case 3
	tmp = [a1(:,i), a2(:,i), a3(:,i)];
	if (index (ifmt, "xydx"))
          settype = "xydx";
	else
          settype = "xydy";
	endif
      case 4
	if (index (ifmt, "xydxdy"))
          tmp = [a1(:,i), a2(:,i), a3(:,i), a4(:,i)];
          settype = "xydxdy";
	elseif (index (ifmt, "xydx"))
          tmp = [a1(:,i), a2(:,i), a4(:,i), a3(:,i)];
          settype = "xydxdx";
	else
          tmp = [a1(:,i), a2(:,i), a4(:,i), a3(:,i)];
          settype = "xydydy";
	endif
      case 5
	error ("error plot requires 2, 3, 4 or 6 columns");
      case 6
	tmp = [a1(:,i), a2(:,i), a4(:,i), a3(:,i), a6(:,i), a5(:,i)];
	settype = "xydxdxdydy";
    endswitch
    __grpltfmt__(tmp, ifmt, settype);
endfor

endfunction
