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
## {@var{phin}} = DDGn2phin(@var{V},@var{n})
##
## Compute the qfl for electrons using Maxwell-Boltzmann statistics.
##
## @end deftypefn
  
function phin = DDGn2phin (V,n);

  ## Load constants
  nmin = 0;
n    = n .* (n>nmin) + nmin * (n<=nmin); 
phin = V - log(n) ;

endfunction
