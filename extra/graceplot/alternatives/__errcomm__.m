## Copyright (C) 2001, 2002 Teemu Ikonen
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
## @deftypefn {Function File} {} __errcomm__ (@var{args})
## Common argument handling code for all error plots (errorbar, loglogerr,
## semilogyerr, semilogxerr).
##
## @end deftypefn
## @seealso{errorbar, semilogxerr, semilogyerr, loglogerr, __pltopt__}

## Created: 20.02.2001
## Author: Teemu Ikonen <tpikonen@pcu.helsinki.fi>
## Keywords: errorbar, plotting
## Adapted to work with Grace 4.8.2003

function __errcomm__ (caller, varargin)

  if (nargin < 3)
    usage ("%s (...)", caller);
  endif

  args = nargin - 1; # nargin is now a function
  hold_state = __grishold__();
  unwind_protect
    if (!hold_state)
      __grcla__();
    endif
    __grhold__("on");
    k = 1;
    while (args)
      a = varargin{k++};
      args--;
      if (isvector (a))
        a = a(:);
      elseif (ismatrix (a))
        ;
      else
        usage ("%s (...)", caller);
      endif
      sz = size (a);
      ndata = 1;
      arg1 = a;
      while (args)
	args--;
	a = varargin{k++};
	if (isstr (a))
	  fmt = a;
	  cmd = "__errplot__ (caller, arg1";
	  for i = 2:ndata,
	    cmd = sprintf ("%s, arg%d", cmd, i);
	  endfor
	  eval (sprintf ("%s, fmt);", cmd));
	  break;
	elseif (isvector (a))
	  a = a(:);
	elseif (ismatrix (a))
	  ;
	else
	  error ("wrong argument types");
	endif
	if (size (a) != sz)
	  error ("argument sizes do not match");
	endif
	ndata++;
	eval (sprintf ("arg%d = a;", ndata));
	if (ndata > 6)
	  error ("too many arguments to a plot");
	endif
      endwhile
    endwhile

    if (! isstr (a))
      fmt = "~";
      cmd = "__errplot__ (caller, arg1";
      for i = 2:ndata,
	cmd = sprintf ("%s, arg%d", cmd, i);
      endfor
      eval (sprintf ("%s, fmt);", cmd));
    endif
  unwind_protect_cleanup
    if (! hold_state)
      __grhold__("off");
    endif
  end_unwind_protect

endfunction
