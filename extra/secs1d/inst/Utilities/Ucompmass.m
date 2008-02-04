function Bmat	= Ucompmass (nodes,Nnodes,elements,Nelements,Bvect,Cvect);
  
% Bmat	= Ucompmass (nodes,Nnodes,elements,Nelements,Bvect,Cvect);
  
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
  
  h 	= (nodes(2:end)-nodes(1:end-1)).*Cvect;
  d0	= Bvect.*[h(1)/2; (h(1:end-1)+h(2:end))/2; h(end)/2];
  Bmat  = spdiags(d0, 0, Nnodes,Nnodes);
  
  
  % Last Revision:
  % $Author$
  % $Date$
  
