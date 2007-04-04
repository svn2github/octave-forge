function phin = DDGn2phin (V,n);

% phin = DDGn2phin (V,n);
%         computes the qfl for electrons using Maxwell-Boltzmann
%         statistics.

## This file is part of 
##
## SECS1D - A 1-D Drift--Diffusion Semiconductor Device Simulator
## -------------------------------------------------------------------
## Copyright (C) 2004-2007  Carlo de Falco
##
##
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
##  along with SECS1D; if not, write to the Free Software
##  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
##  USA
  
  
% load constants
nmin = 0;

n    = n .* (n>nmin) + nmin * (n<=nmin); 
phin = V - log(n) ;


% Last Revision:
% $Author$
% $Date$
