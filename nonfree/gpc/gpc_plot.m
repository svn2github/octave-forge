## Copyright (C) 2000 Rafael Laboissiere
##
## This program is free software.
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

## usage: gpc_plot (polygon [, format [, type]])
##
## The first argument must be a gpc_polygon object.  Its contours will
## be plotted with intervening hold on.  The plot will be left in a
## holded on state after call to gpc_plot.
##
## If a second argument is provided, it is interpreted as the plotting
## style.  See the documentation for the plot command for q description
## of possible styles.
##
## The third optional parameter, if set to 1, indicates that POLYGON is
## of type tristrip, instead of a regular gpc_polygon.  See the
## documentation for gpc_tristrip for more details.
##
## See also: gpc_create, plot, gpc_tristrip

## Author: Rafael Laboissiere <rafael@laboissiere.net>

function gpc_plot (p, f, t)

  if nargin < 1 | nargin > 3
    usage ("gpc_plot (polygon [, format [, type]])");

  else
    if ! gpc_is_polygon (p)
      error ("gpc_plot: first argument must be a gpc_polygon object");

    else
      if nargin < 3
	t = 0;
        if nargin < 2
	  f = "";
        endif
      endif	

      ## Test for existence of fill.m function (in matcompat package)
      ## for plotting tristrips
      if exist ("fill") == 2
	plot_fcn = "fill";
      else
	plot_fcn = "plot";
      end

      s = gpc_get (p);
      vtx = s.vertices;
      idx = s.indices;

      for i = 1 : size (idx, 1)

	if t == 0

          ## Normal polygon plot
	  j = [ idx (i, 1) : idx (i, 2), idx (i, 1) ];
	  if strcmp (f, "")
	    plot (vtx (j, 1), vtx (j, 2))
	  else
	    plot (vtx (j, 1), vtx (j, 2), f)
	  endif
	  hold on

	else

	  ## Tristrip plotting
          for j = idx (i,1) : idx (i,2) - 2
	    k = j + [0, 1, 2, 0];
	    if strcmp (f, "")
	      feval (plot_fcn, vtx (k, 1), vtx (k, 2));
	    else
	      feval (plot_fcn, vtx (k, 1), vtx (k, 2), f);
	    endif
	    hold on
	  endfor	
	  
	endif

      endfor

    endif

  endif

endfunction
