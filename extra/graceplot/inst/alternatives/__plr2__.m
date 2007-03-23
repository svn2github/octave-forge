## Copyright (C) 1996, 1997 John W. Eaton
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
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} __plr2__ (@var{theta}, @var{rho}, @var{fmt})
## @end deftypefn

## Author: jwe
## Modified to work with Grace by Teemu Ikonen
## <tpikonen@pcu.helsinki.fi> 
## Created: 7.8.2003

function __plr2__ (theta, rho, fmt)

  if (nargin != 3)
    usage ("__plr2__ (theta, rho, fmt)");
  endif

  hold_state = __grishold__ ();
  if(!hold_state)
    __grcla__();
    [cur_figure, cur_graph, cur_set] = __grgetstat__();
    __grcmd__(sprintf("focus g%i; g%i type polar; autoscale onread xyaxes", cur_graph, cur_graph));
  endif

  if (any (imag (theta)))
    theta = real (theta);
  endif

  if (any (imag (rho)))
    rho = real (rho);
  endif

  unwind_protect
    
   if (isvector (theta))
    if (isvector (rho))
      if (length (theta) != length (rho))
        error ("polar: vector lengths must match");
      endif
      if (rows (rho) == 1)
        rho = rho';
      endif
      if (rows (theta) == 1)
        theta = theta';
      endif
	__grpltfmt__([theta, rho], fmt, "xy");
      elseif (ismatrix (rho))
	[t_nr, t_nc] = size (theta);
	if (t_nr == 1)
          theta = theta';
          tmp = t_nr;
          t_nr = t_nc;
          t_nc = tmp;
	endif
	[r_nr, r_nc] = size (rho);
	if (t_nr != r_nr)
          rho = rho';
          tmp = r_nr;
          r_nr = r_nc;
          r_nc = tmp;
	endif
	if (t_nr != r_nr)
          error ("polar: vector and matrix sizes must match");
	endif
	for i = 1:r_nc,
	  fmt1 = fmt(min(i, rows(fmt)),:);
	  __grpltfmt__([theta, rho(:,i)], fmt1, "xy");
	endfor
      endif
    elseif (ismatrix (theta))
      if (isvector (rho))
	[r_nr, r_nc] = size (rho);
	if (r_nr == 1)
          rho = rho';
          tmp = r_nr;
          r_nr = r_nc;
          r_nc = tmp;
	endif
	[t_nr, t_nc] = size (theta);
	if (r_nr != t_nr)
          theta = theta';
          tmp = t_nr;
          t_nr = t_nc;
          t_nc = tmp;
	endif
	if (r_nr != t_nr)
          error ("polar: vector and matrix sizes must match");
	endif
	for i = 1:t_nc,
	  fmt1 = fmt(min(i, rows(fmt)),:);
	  __grpltfmt__([theta(:,i), rho], fmt1, "xy");
	endfor
      elseif (ismatrix (rho))
	if (size (rho) != size (theta))
          error ("polar: matrix dimensions must match");
	endif
	for i = 1:t_nc,
	  fmt1 = fmt(min(i, rows(fmt)),:);
	  __grpltfmt__([theta(:,i), rho(:,i)], fmt1, "xy");
	endfor
      endif
    endif
    
  unwind_protect_cleanup

    if (! hold_state)
      __grhold__("off");
    endif

  end_unwind_protect

endfunction
