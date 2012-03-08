## Copyright (C) 2012   Lukas F. Reichlin
##
## This file is part of LTI Syncope.
##
## LTI Syncope is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## LTI Syncope is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with LTI Syncope.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} plot (@var{dat})
## Plot.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: February 2012
## Version: 0.1

function plot (dat)

  [n, p, m, e] = size (dat)

  if (m == 0)  # time series
    for k = 1 : e
      plot (dat.y{k})
      hold on
    endfor
  else         # inputs present
    for k = 1 : e
      subplot (2, 1, 1)
      plot (dat.y{k})
      hold on
      subplot (2, 1, 2)
      stairs (dat.u{k})
      hold on
    endfor
  endif
  
  hold off

endfunction