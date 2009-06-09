%% Copyright (C) 2004,2005,2006,2009  Carlo de Falco
%%
%% This file is part of 
%%
%%            SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
%%         -------------------------------------------------------------------
%%            Copyright (C) 2004-2006,2009  Carlo de Falco
%%
%%
%%
%%  SECS2D is free software; you can redistribute it and/or modify
%%  it under the terms of the GNU General Public License as published by
%%  the Free Software Foundation; either version 2 of the License, or
%%  (at your option) any later version.
%%
%%  SECS2D is distributed in the hope that it will be useful,
%%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%  GNU General Public License for more details.
%%
%%  You should have received a copy of the GNU General Public License
%%  along with SECS2D; if not, see http://www.gnu.org/licenses


%%  This sample script shows how to compute the IV characteristics of a
%%  rectangular pn-diode. 
%%
%%   HOW TO SET UP THE GEOMETRY:
%%
%%                 Ln        Lp
%%             |---------|---------|
%%    
%%         -   ,---------,---------,
%%         |   |.........|\\\\\\\\\|
%%     Td  |   |.........|\\\\\\\\\|
%%         |   |.........|\\\\\\\\\|
%%         -   '---------'---------'
%%
%%  Lengths are in meters

%% Author: Carlo de Falco

function secs2d_demo_pndiode ()

  V = [-.5:.1:2];
  clear -global
  for ii=1:length(V)
    printf("V = %g\n", V(ii))

    GMinput = __PNDIODE_data__(... %% GEOMETRY %%
				.5e-6,...  % Ln
				.5e-6,...  % Lp
				.5e-6,...  % Td
				... %% CONTACT VOLTAGES %%
				0,...      % N Voltage
				V(ii),...  % P Voltage
				... %% DOPING PROFILE
				1e20,...   % Acceptors in p side 
				1e22);     % Donors in n side
    
    
    [odata,it,res] = DDGOXgummelmap (GMinput.mesh,GMinput.Dsides,...
				     GMinput.Simesh,GMinput.Sinodes,GMinput.Sielements,...
				     GMinput.SiDsides,...
				     GMinput.data,GMinput.toll,GMinput.maxit,...
				     GMinput.ptoll,GMinput.pmaxit,0);
    
     current = DDGOXddcurrent(GMinput.Simesh,GMinput.Sinodes,odata,[GMinput.PSides, GMinput.NSides]);
    
    I(ii) = current(2);
    
  endfor
  
  plot(V,I,'kx-');
  xlabel('Voltage [V]');
  ylabel('Current density [A m^{-2}]');
  
endfunction

function mesh = __PNDIODE__ (Lp,Ln,Td);

  %%  mesh = __PNDIODE__ (Lp,Ln,Td);
  %% generate mesh with given geometry

  fx  = .5;
  fy  = .5;
  pow = 1.7;
  
  x1 = linspace(0,1,20*fx);
  x1 = Ln*(1-x1.^pow);
  
  x2 = linspace(0,1,20*fx);
  x2 =  Ln+Lp*x2.^pow;
  
  y  = linspace(0,Td,10*fy);
  
  [mesh1.p,mesh1.e,mesh1.t]=Ustructmesh(x1,y,1,[1:4]);
  [mesh2.p,mesh2.e,mesh2.t]=Ustructmesh(x2,y,1,[1:4]);
  
  side1=2;
  side2=4;
  
  mesh=Ujoinmeshes(mesh1,mesh2,side1,side2);
  
  ##Udrawedge(mesh);

endfunction


function GMinput= __PNDIODE_data__ (Ln,Lp,Td,vn,vp,Na,Nd);

  %% GMinput=PNDIODE_data(Ln,Lp,Td,Na,Nd,vn,vp);
  %% set-up data for a DD simulation

  mesh = __PNDIODE__ (Ln,Lp,Td);
  
  constants
  
  NSides  = [4];
  PSides  = [6];
  
  Dsides   = [ NSides PSides];
  SiDsides = Dsides;
  Sisides =  [ 1:7 ];
  
  x         = mesh.p(1,:)';
  Nnodes    = size(mesh.p,2);
  Nelements = size(mesh.t,2);
  Simesh    = mesh;
  Sinodes   = 1:Nnodes;
  Sielements= 1:Nelements;

  [tmpmesh,nside] =Usubmesh(Simesh,2,1,1);
  clear tmpmesh;

  [tmpmesh,pside] =Usubmesh(Simesh,2,2,1);
  clear tmpmesh;

  data.D            = 0*x+Nd;
  data.D(pside)     = -Na;

  data.n = data.D .* (data.D > 0);
  data.p = -data.D .* (data.D < 0);

  data.n = data.n - (ni^2 ./ data.D) .* (data.D < 0);
  data.p = data.p + (ni^2 ./ data.D) .* (data.D > 0);

  data.Fn             = 0*x+vn;
  data.Fn(pside)      = vp;

  data.Fp= data.Fn;

  data.V = data.Fn + Vth * log(data.n/ni);

  data.un=Udopdepmob (Simesh,un,mudopparn,abs(data.D));
  data.up=Udopdepmob (Simesh,up,mudopparp,abs(data.D));

  data.n0 = data.n*0+ni;
  data.p0 = data.n*0+ni;

  [idata,imesh]= Uscaling(mesh,data);
  imesh        = Umeshproperties(imesh);
  Simesh       = imesh;

  GMinput.toll          = 1e-3;
  GMinput.ptoll         = 1e-10;
  GMinput.maxit         = 10;
  GMinput.pmaxit        = 100;
  GMinput.verbose       = 2;
  GMinput.options.holes = 1;
  GMinput.options.SRH   = 1;
  
  GMinput.mesh       = imesh;
  GMinput.Dsides     = Dsides;
  GMinput.Simesh     = Simesh;
  GMinput.Sinodes    = Sinodes;
  GMinput.Sielements = Sielements;
  GMinput.SiDsides   = SiDsides;
  GMinput.data       = idata;
  
  GMinput.NSides  = NSides;
  GMinput.PSides  = PSides;
  
endfunction