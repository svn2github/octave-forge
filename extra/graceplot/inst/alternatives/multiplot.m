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
## @deftypefn {Function File} {} multiplot (@var{xn}, @var{yn})
## Sets and resets multiplot mode.
##
## If the arguments are non-zero, @code{multiplot} will set up multiplot
## mode with @var{xn}, @var{yn} subplots along the @var{x} and @var{y}
## axes.  If both arguments are zero, @code{multiplot} closes multiplot
## mode.
## @end deftypefn

## Author: Vinayak Dutt <Dutt.Vinayak@mayo.EDU>
## Created: 3 July 95
## Adapted-By: jwe
## Modified to work with Grace by Teemu Ikonen <tpikonen@pcu.helsinki.fi> 
## Created: 8.8.2003


function multiplot (xn, yn)

  ## global variables to keep track of multiplot options

   global __grmultiplot_mode__ = 0;
   global __grmultiplot_xn__;
   global __grmultiplot_yn__;

  if (nargin != 2)
    usage ("multiplot (xn, yn)");
  endif

  if (! (isscalar (xn) && isscalar (yn)))
    error ("multiplot: xn and yn have to be scalars");
  endif

  xn = round (xn);
  yn = round (yn);

  if (xn == 0 && yn == 0)

    oneplot ();

  else

    if (xn < 1 || yn < 1)
      error ("multiplot: xn and yn have to be positive integers");
    endif

    __grcmd__(sprintf("arrange(%i, %i, 0.1, 0.15, 0.2); redraw;", yn, xn));
    __grmultiplot_mode__ = 1;
    __grmultiplot_xn__ = xn;
    __grmultiplot_yn__ = yn;

  endif

endfunction
