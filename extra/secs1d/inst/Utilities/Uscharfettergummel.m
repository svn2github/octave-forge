function A=Uscharfettergummel(nodes,Nnodes,elements,Nelements,acoeff,bcoeff,v)
  
%A=Uscharfettergummel(nodes,Nnodes,elements,Nelements,acoeff,bcoeff,v)
%
% Builds the Scharfetter-Gummel  matrix for the 
% the discretization of the LHS 
% of the Drift-Diffusion equation:
%
% $ -(a(x) (u' - b v'(x) u))'= f $
%
% where a(x) is piecewise constant
% and v(x) is piecewise linear, so that 
% v'(x) is still piecewise constant
% b is a constant independent of x
% and u is the unknown
%

  ## This file is part of 
  ##
  ## SECS1D - A 1-D Drift--Diffusion Semiconductor Device Simulator
  ## -------------------------------------------------------------------
  ## Copyright (C) 2004-2007  Carlo de Falco
  ##
  ##
  ##
  ##  SECS2D is free software; you can redistribute it and/or modify
  ##  it under the terms of the GNU General Public License as published by
  ##  the Free Software Foundation; either version 2 of the License, or
  ##  (at your option) any later version.
  ##
  ##  SECS2D is distributed in the hope that it will be useful,
  ##  but WITHOUT ANY WARRANTY; without even the implied warranty of
  ##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ##  GNU General Public License for more details.
  ##
  ##  You should have received a copy of the GNU General Public License
  ##  along with SECS2D; if not, write to the Free Software
  ##  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
  ##  USA

  h=nodes(elements(:,2))-nodes(elements(:,1));
  
  c=acoeff./h;
  Bneg=Ubernoulli(-(v(2:Nnodes)-v(1:Nnodes-1))*bcoeff,1);
  Bpos=Ubernoulli( (v(2:Nnodes)-v(1:Nnodes-1))*bcoeff,1);
  
  
  d0    = [c(1).*Bneg(1); c(1:end-1).*Bpos(1:end-1)+c(2:end).*Bneg(2:end); c(end)*Bpos(end)];
  d1    = [1000;-c.* Bpos];
  dm1   = [-c.* Bneg;1000];
  
  A = spdiags([dm1 d0 d1],-1:1,Nnodes,Nnodes);
  
  % Last Revision:
  % $Author$
  % $Date$
