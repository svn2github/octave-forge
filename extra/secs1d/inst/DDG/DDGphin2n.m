function n = DDGphin2n (V,phin);

% n = DDGphin2n (V,phin);
%         computes the electron density using Maxwell-Boltzmann
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
##  along with SECS1D; If not, see <http://www.gnu.org/licenses/>.
  
  
  nmin = 0;
  n =  exp ((V-phin));
  n = n .* (n>nmin) + nmin * (n<=nmin);

  % Last Revision:
  % $Author$
  % $Date$
