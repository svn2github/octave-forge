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
## @deftypefn {Function File} {} mplot (@var{x}, @var{y})
## @deftypefnx {Function File} {} mplot (@var{x}, @var{y}, @var{fmt})
## @deftypefnx {Function File} {} mplot (@var{x1}, @var{y1}, @var{x2}, @var{y2})
## This is a modified version of the @code{plot} function that makes 
## multiple plots per page.
## This plot version automatically advances to the next subplot position
## after each set of arguments are processed.
##
## See the description of the @var{plot} function for the various options.
## @end deftypefn

## Author: Vinayak Dutt <Dutt.Vinayak@mayo.EDU>
## Adapted-By: jwe
## Modified to work with Grace by Teemu Ikonen <tpikonen@pcu.helsinki.fi> 
## Created: 8.8.2003

function mplot (varargin)

  ## global variables to keep track of multiplot options

   global __grmultiplot_mode__ = 0;
   global __grmultiplot_xn__;
   global __grmultiplot_yn__;

  __plt__ ("plot", varargin{:});

  ## update the plot position

  if (__grmultiplot_mode__)
    [cur_fig, cur_graph, cur_set] = __grgetstat__();
    if(cur_graph < (__grmultiplot_xn__ * __grmultiplot_yn__ - 1))
      __grsetgraph__(cur_graph+1);
    else
      __grsetgraph__(0);
    endif
  endif


endfunction
