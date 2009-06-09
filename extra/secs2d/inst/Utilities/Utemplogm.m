## Copyright (C) 2004-2008  Carlo de Falco
##
## SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
##
## SECS2D is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## SECS2D is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with SECS2D; If not, see <http://www.gnu.org/licenses/>.
##
## AUTHOR: Carlo de Falco <cdf _AT_ users.sourceforge.net>

## -*- texinfo -*-
##
## @deftypefn {Function File}@
## {@var{T}} = Utemplogm(@var{t1},@var{t2})
##
## Compute:
##
## ( @var{t2} - @var{t1} ) / log( @var{t2}/@var{t1} )
##
## @end deftypefn

function T = Utemplogm(t1,t2)

  T        = zeros(size(t2));
  sing     = abs(t2-t1)< 100*eps ;
  T(sing)  = (t2(sing)+t1(sing))/2;
  T(~sing) = (t2(~sing)-t1(~sing))./log(t2(~sing)./t1(~sing));

endfunction