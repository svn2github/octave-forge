function p=ThDDGOXhole_driftdiffusion(mesh,Dsides,nin,pin,V,Vth,up,tn,tp,n0,p0)

%%
%    p=DDGhole_driftdiffusion(mesh,Dsides,nin,pin,V,Vth,up,tn,tp,n0,p0)
%   IN:
%	  v    = electric potential
%	  Vth  = thermal potential
%         mesh = integration domain
%         nin  = initial guess and BCs for electron density
%         pin  = hole density (to compute SRH recombination)
%   OUT:
%     p    = updated hole density
%%

% This file is part of 
%
%            SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
%         -------------------------------------------------------------------
%            Copyright (C) 2004-2006  Carlo de Falco
%
%
%
%  SECS2D is free software; you can redistribute it and/or modify
%  it under the terms of the GNU General Public License as published by
%  the Free Software Foundation; either version 2 of the License, or
%  (at your option) any later version.
%
%  SECS2D is distributed in the hope that it will be useful,
%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%  GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with SECS2D; if not, write to the Free Software
%  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%  USA

Nnodes    = max(size(mesh.p));
Nelements = max(size(mesh.t));

denom = (tp*(nin+sqrt(n0.*p0))+tn*(pin+sqrt(n0.*p0)));
u     = up;
U     = n0.*p0./denom;
M     = nin./denom;
guess = pin;
V     = -V;

p = Udriftdiffusion2(mesh,Dsides,guess,M,U,V,Vth,u);



