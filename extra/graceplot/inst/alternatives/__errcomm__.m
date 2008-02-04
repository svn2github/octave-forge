## Copyright (C) 2001, 2002 Teemu Ikonen
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
    usage ("%s (x,y,dy,'fmt',...)", caller);
  endif

  nargs = length (varargin);
  save_hold = __grishold__();
  unwind_protect
    if (!save_hold)
      __grcla__();
    endif
    __grhold__("on");
    k = 1;
    data = cell(6,1);
    while (k <= nargs)
      a = varargin{k++};
      if (isvector (a))
        a = a(:);
      elseif (ismatrix (a))
        ;
      else
        usage ("%s (...)", caller);
      endif
      sz = size (a);
      ndata = 1;
      data{ndata} = a;
      while (k <= nargs)
	a = varargin{k++};
	if (ischar (a))
	  __errplot__ (a, data{1:ndata});
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
	data{++ndata} = a;
	if (ndata > 6)
	  error ("too many arguments to a plot");
	endif
      endwhile
    endwhile

    if (! ischar (a))
      __errplot__ ("~", data{1:ndata});
    endif
  unwind_protect_cleanup
    if (! save_hold)
      __grhold__("off");
    endif
  end_unwind_protect

endfunction
