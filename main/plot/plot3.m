## Copyright (C) 1996 John W. Eaton
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, write to the Free
## Software Foundation, 59 Temple Place - Suite 330, Boston, MA
## 02111-1307, USA.

## usage: plot3 (x, y, z)
##        plot3 (x1, y1, z1, x2, y2, z2, ...)
##        plot3 (x, y, z, fmt)
##
## If all arguments are vectors of the same length, a single line is
## drawn in three space.
##
## If all arguments are matrices, each column is drawn as a separate
## line. In this case, all matrices must have the same number of rows
## and columns and no attempt is made to transpose the arguments to make
## the number of rows match.
##
## To see possible options for FMT please see __pltopt__.
##
## Example
##
##    z = [0:0.05:5];
##    plot3(cos(2*pi*z), sin(2*pi*z), z, ";helix;");

## Author: Paul Kienzle
##         (modified from __plt__.m)

function plot3(varargin)

  ## use the following for 2.1.38 and below
  # varargin = list(varargin, all_va_args);

  hold_state = ishold ();
  
  unwind_protect

    x_set = 0;
    y_set = 0;
    z_set = 0;
    
    ## Gather arguments, decode format, and plot lines.
    for arg = 1:length(varargin)
      new = nth (varargin, arg);
      
      if (isstr (new))
	if (! z_set)
	  error ("plot3: needs x, y, z");
	endif
	fmt = __pltopt__ ("plot3", new);
	__plt3__(x, y, z, fmt);
	hold on;
	x_set = 0;
	y_set = 0;
	z_set = 0;
      elseif (!x_set)
	x = new;
	x_set = 1;
      elseif (!y_set)
	y = new;
	y_set = 1;
      elseif (!z_set)
	z = new;
	z_set = 1;
      else
	__plt3__ (x, y, z, "");
	hold on;
	x = new;
	y_set = 0;
	z_set = 0;
      endif
 
### Code copied from __plt__; don't know if it is needed     
###
###   ## Something fishy is going on.  I don't think this should be
###   ## necessary, but without it, sometimes not all the lines from a
###   ## given plot command appear on the screen.  Even with it, the
###   ## delay might not be long enough for some systems...
###     
###   usleep (1e5);
      
    endwhile
    
    ## Handle last plot.
    
    if  (z_set)
      __plt3__ (x, y, z, "");
    elseif (x_set)
      error ("plot3: needs x, y, z");
    endif
    
  unwind_protect_cleanup
    
    if (! hold_state)
      hold off;
    endif
    
  end_unwind_protect

endfunction
