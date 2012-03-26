## Copyright (C) 2004-2008  Carlo de Falco
##
## SECS2D - A 2-D Drift--Diffusion Semiconductor Device Simulator
##
## SECS2D is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
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
## {@var{odata},@var{omesh}} = Udescaling(@var{imesh},@var{idata})
##
## Scale @var{idata} and return the output in @var{odata}
##
## @end deftypefn

function [odata,omesh] = Uscaling(imesh,idata);

  load (file_in_path(path,"constants.mat"));

  omesh      = imesh;
  odata      = idata;

  ## Scaling factors
  odata.xs   = max(abs([max(imesh.p(1,:))-min(imesh.p(1,:)),max(imesh.p(2,:))-min(imesh.p(2,:))]));
  odata.Vs   = Vth;
  odata.ns   = norm(idata.D,inf);
  odata.us   = un;
  odata.ts   = (odata.xs^2)/(odata.Vs*odata.us);
  odata.Ts   = T0;
  odata.kappas     = odata.Vs^2*q*odata.us*odata.ns/odata.Ts;
  
  ## Adimensional constants
  odata.etan2 = hbar^2 / (2*mndos*odata.xs^2*q*odata.Vs);

  ## 3-valley masses
  odata.etanxx2 = hbar^2 / (2*mnl*odata.xs^2*q*odata.Vs);
  odata.etanxy2 = hbar^2 / (2*mnt*odata.xs^2*q*odata.Vs);

  odata.etanyx2 = hbar^2 / (2*mnt*odata.xs^2*q*odata.Vs);
  odata.etanyy2 = hbar^2 / (2*mnl*odata.xs^2*q*odata.Vs);

  odata.etanzx2 = hbar^2 / (2*mnt*odata.xs^2*q*odata.Vs);
  odata.etanzy2 = hbar^2 / (2*mnt*odata.xs^2*q*odata.Vs);


  odata.etap2 = hbar^2 / (2*mhdos*odata.xs^2*q*odata.Vs);
  odata.beta  = Vth/odata.Vs;
  odata.dn2   = hbar^2 / (4*rn*mndos*odata.xs^2*q*odata.Vs);
  odata.dp2   = hbar^2 / (4*rp*mhdos*odata.xs^2*q*odata.Vs);
  odata.l2    = (odata.Vs*esi) / (odata.ns*odata.xs^2*q);
  odata.l2ox  = (odata.Vs*esio2) / (odata.ns*odata.xs^2*q);

  if (isfield(idata,"un"))    
    odata.un    = idata.un/odata.us;  
  else
    odata.un    = un/odata.us;
  endif

  if (isfield(idata,"up"))
    odata.up    = idata.up/odata.us;
  else
    odata.up    = up/odata.us;
  endif

  if (isfield(idata,"FDn"))    
    odata.FDn    = idata.FDn/odata.Vs;  
  endif
  if (isfield(idata,"FDp"))    
    odata.FDp    = idata.FDp/odata.Vs;  
  endif

  if (isfield(idata,"tn")) 
    odata.tn    = idata.tn/odata.ts;
  else
    odata.tn    = tn/odata.ts;
  endif
  if (isfield(idata,"tp")) 
    odata.tp    = idata.tp/odata.ts;
  else
    odata.tp   = tp/odata.ts;
  endif
  if (isfield(idata,"twn")) 
    odata.twn    = idata.twn/odata.ts;
  else
    odata.twn    = twn/odata.ts;
  endif
  if (isfield(idata,"twp")) 
    odata.twp    = idata.twp/odata.ts;
  else
    odata.twp    = twp/odata.ts;
  endif

  if (isfield(idata,"kappa")) 
    odata.kappa = idata.kappa /odata.kappas;
  else
    odata.kappa = kappaSi/odata.kappas;
  endif

  odata.ni    = ni/odata.ns;
  if (isfield(idata,"n0")) 
    odata.n0 = idata.n0 /odata.ns;
    odata.p0 = idata.p0 /odata.ns;
  else
    odata.n0 = ni /odata.ns;
    odata.p0 = ni /odata.ns;
  endif
  odata.Nc    = Nc/odata.ns;
  odata.Nv    = Nv/odata.ns;

  odata.ei    = Egap/(2*q*odata.Vs) - log(Nv/Nc)/2; 
  odata.eip   = Egap/(2*q*odata.Vs) + log(Nv/Nc)/2; 
  odata.Egap  = Eg0/(q*odata.Vs);

  odata.wn2   = 6*sqrt(mndos*2*Kb*T0/(pi*hbar^2))/(ni*odata.xs^2);

  odata.vsatn     = vsatn * odata.xs / (odata.us * odata.Vs);
  odata.vsatp     = vsatp * odata.xs / (odata.us * odata.Vs);
  odata.mubn      = mubn;
  odata.mubp      = mubp;
  odata.mudopparn = [ mudopparn(1:3)/odata.us;
		     mudopparn(4:6)/odata.ns;
		     mudopparn(7:8) ];
  odata.mudopparp = [ mudopparp(1:3)/odata.us;
		     mudopparp(4:6)/odata.ns;
		     mudopparp(7:8) ];

  ## 3-valley weights
  odata.wnx2   = 2*sqrt(mnt*2*Kb*odata.Ts/(pi*hbar^2))/(ni*odata.xs^2);
  odata.wny2   = odata.wnx2;
  odata.wnz2   = 2*sqrt(mnl*2*Kb*odata.Ts/(pi*hbar^2))/(ni*odata.xs^2);

  ## 3-valley weights
  odata.wnx2FD   = 2*sqrt(mnt*2*Kb*odata.Ts/(pi*hbar^2))/(odata.ns*odata.xs^2);
  odata.wny2FD   = odata.wnx2FD;
  odata.wnz2FD   = 2*sqrt(mnl*2*Kb*odata.Ts/(pi*hbar^2))/(odata.ns*odata.xs^2);

  odata.mg    = Egap/(2*Kb*odata.Ts) - log(Nv/Nc)/2;


  ## Scaled quantities
  odata.D     = idata.D/odata.ns;
  odata.n     = idata.n/odata.ns;
  odata.p     = idata.p/odata.ns;
  odata.Fn    = idata.Fn/odata.Vs-log(ni/odata.ns);
  odata.Fp    = idata.Fp/odata.Vs+log(ni/odata.ns);
  odata.V     = idata.V/odata.Vs;
  if (isfield(idata,"G"))
    odata.G= idata.G/odata.Vs;
  endif
  if (isfield(idata,"dt"))
    odata.dt= idata.dt/odata.ts;
  endif
  if (isfield(idata,"Tl"))
    odata.Tl= idata.Tl/odata.Ts;
  endif
  if (isfield(idata,"Tn"))
    odata.Tn= idata.Tn/odata.Ts;
  endif
  if (isfield(idata,"Tp"))
    odata.Tp= idata.Tp/odata.Ts;
  endif


  omesh.p     = imesh.p/odata.xs;


endfunction