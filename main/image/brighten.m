## Copyright (C) 1999,2000  Kai Habel
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

## -*- texinfo -*-
## @deftypefn {Function File} @var{map}= brighten (@var{beta},@var{map})
## darkens or brightens the current colormap. 
## The argument @var{beta} should be a scalar between -1...1,
## where a negative value darkens and a positive value brightens
## the colormap.
## If the @var{map} argument is omitted,
## the function is applied to the current colormap
## @end deftypefn

## Author:	Kai Habel <kai.habel@gmx.de>
## Date:	05. March 2000

function [...] = brighten (m, beta)

  global __current_color_map__

  if (nargin == 1)
    beta = m;
    m = __current_color_map__;

  elseif (nargin == 2)
    if (nargout == 0)
      usage ("map_out=brighten(map,beta)")
    endif

    if !(is_scalar (beta) || beta < -1 || beta > 1)
      error ("brighten(...,beta) beta must be a scalar in the range -1..1");
    endif

    if !( is_matrix (m) && size (m, 2) == 3 )
      error ("brighten(map,beta) map must be a matrix of size nx3");
    endif

  else
    usage ("brighten(...) number of arguments must be 1 or 2");
  endif

  if (beta > 0)
    gamma = 1 - beta;
  else
    gamma = 1 / (1 + beta);
  endif

  if (nargout == 0)
    __current_color_map__ = __current_color_map__ .^ gamma;
  else
    vr_val (map .^ gamma);
  endif

endfunction
