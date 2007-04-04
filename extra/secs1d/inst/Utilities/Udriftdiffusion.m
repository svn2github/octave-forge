function A=Udriftdiffusion(x,psi,coeff)  
  
%A=Udriftdiffusion(x,psi,coeff)
%
% Builds the Scharfetter-Gummel approximation
% of the differential operator - (coeff (n' - n psi'))' 
%

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
  
  nodes        = x;
  Nnodes     =length(nodes);
  
  elements   = [[1:Nnodes-1]' [2:Nnodes]'];
  Nelements=size(elements,1);
  
  Bcnodes = [1;Nnodes];
  
  h=nodes(elements(:,2))-nodes(elements(:,1));
  
  c=coeff./h;
  Bneg=Ubernoulli(-(psi(2:Nnodes)-psi(1:Nnodes-1)),1);
  Bpos=Ubernoulli( (psi(2:Nnodes)-psi(1:Nnodes-1)),1);
  
  
  d0    = [c(1).*Bneg(1); c(1:end-1).*Bpos(1:end-1)+c(2:end).*Bneg(2:end); c(end)*Bpos(end)];
  d1    = [1000;-c.* Bpos];
  dm1   = [-c.* Bneg;1000];
  
  A = spdiags([dm1 d0 d1],-1:1,Nnodes,Nnodes);
  
  % Last Revision:
  % $Author$
  % $Date$
  
