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
## 02111-1307, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} oneplot ()
## If in multiplot mode, switches to single plot mode.
## @end deftypefn

## Author: Vinayak Dutt <Dutt.Vinayak@mayo.EDU>
## Created: 3 July 95
## Adapted-By: jwe
## Modified to work with Grace by Teemu Ikonen <tpikonen@pcu.helsinki.fi> 
## Created: 8.8.2003

function oneplot ()

   global __grmultiplot_mode__ = 0;
   global __grmultiplot_xn__;
   global __grmultiplot_yn__;

  __grsetgraph__(0);
  __grcmd__("arrange(1,1, 0.1, 0.15, 0.2); redraw;");
  __grmultiplot_mode__ = 0;
  __grmultiplot_xn__ = 1;
  __grmultiplot_yn__ = 1;

endfunction
