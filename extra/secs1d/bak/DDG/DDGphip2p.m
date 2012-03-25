## Copyright (C) 2004-2008  Carlo de Falco
##
## SECS1D - A 1-D Drift--Diffusion Semiconductor Device Simulator
##
##  SECS1D is free software; you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation; either version 2 of the License, or
##  (at your option) any later version.
##
##  SECS1D is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with SECS1D; If not, see <http://www.gnu.org/licenses/>.
##
## author: Carlo de Falco <cdf _AT_ users.sourceforge.net>
  
## -*- texinfo -*-
##
## @deftypefn {Function File}@
## {@var{p}} = DDGphip2p(@var{V},@var{phip})
##
## Compute the hole density using Maxwell-Boltzmann statistic
##
## @end deftypefn
  
function p = DDGphip2p (V,phip);

## Load constants
pmin = 0;
p = exp ((phip-V));
p = p .* (p>pmin) + pmin * (p<=pmin);

endfunction
