%% Copyright (C) 2004-2013  Carlo de Falco
%%
%% This file is part of 
%% SECS1D - A 1-D Drift--Diffusion Semiconductor Device Simulator
%%
%% SECS1D is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 3 of the License, or
%% (at your option) any later version.
%%
%% SECS1D is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with SECS1D; If not, see <http://www.gnu.org/licenses/>.

%% material = secs1d_silicon_material_properties_fun ();
%%
%% material properties for silicon and silicon dioxide
%%
%% material.esir     = relative electric permittivity of silicon
%% material.esio2r   = relative electric permittivity of silicon dioxide
%% material.esi      = electric permittivity of silicon
%% material.esio2    = electric permittivity of silicon dioxide
%% material.mn       = effective mass of electrons in silicon
%% material.mh       = effective mass of holes in silicon
%% 
%% material.u0n      = low field electron mobility
%% material.u0p      = low field hole mobility
%% material.uminn    = parameter for doping-dependent electron mobility
%% material.betan    = idem
%% material.Nrefn    = idem
%% material.uminp    = parameter for doping-dependent hole mobility
%% material.betap    = idem
%% material.Nrefp    = idem
%% material.vsatn    = electron saturation velocity
%% material.vsatp    = hole saturation velocity
%% material.tp       = electron lifetime
%% material.tn       = hole lifetime
%% material.Cn       = electron Auger coefficient
%% material.Cp       = hole Auger coefficient
%% material.an       = impact ionization rate for electrons
%% material.ap       = impact ionization rate for holes
%% material.Ecritn   = critical field for impact ionization of electrons
%% material.Ecritp   = critical field for impact ionization of holes 
%% material.Nc       = effective density of states in the conduction band
%% material.Nv       = effective density of states in the valence band
%% material.Egap     = bandgap in silicon
%% material.EgapSio2 = bandgap in silicon dioxide
%% 
%% material.ni       = intrinsic carrier density
%% material.Phims    = metal to semiconductor potential barrier

function material = secs1d_silicon_material_properties_fun (constants);

  material.esir        = 11.7;
  material.esio2r      = 3.9;
  material.esi         = constants.e0 * material.esir;
  material.esio2       = constants.e0 * material.esio2r;
  material.mn          = 0.26*constants.mn0;
  material.mh          = 0.18*constants.mn0;

  material.qsue        = constants.q / material.esi;

  material.u0n         = 1417e-4;
  material.u0p         = 480e-4;
  material.uminn       = 65e-4;
  material.uminp       = 47.7e-4;
  material.betan       = 0.72;
  material.betap       = 0.76;
  material.Nrefn       = 8.5e22;
  material.Nrefp       = 6.3e22;
  material.vsatn       = 1.1e5;
  material.vsatp       = 9.5e4;

  material.tp          = 1e-6;
  material.tn          = 1e-6;

  material.Cn          = 2.8e-31*1e-12; 
  material.Cp          = 9.9e-32*1e-12;   
  material.an          = 7.03e7;
  material.ap          = 6.71e7;
  material.Ecritn      = 1.231e8; 
  material.Ecritp      = 1.693e8;

  material.mnl         = 0.98*constants.mn0;
  material.mnt         = 0.19*constants.mn0;
  material.mndos       = (material.mnl*material.mnt*material.mnt)^(1/3); 

  material.mhh         = 0.49*constants.mn0;
  material.mlh         = 0.16*constants.mn0;
  material.mhdos       = (material.mhh^(3/2) + material.mlh^(3/2))^(2/3);

  material.Nc          = (6/4)*(2*material.mndos*constants.Kb*constants.T0/(constants.hbar^2*pi))^(3/2);   
  material.Nv          = (1/4)*(2*material.mhdos*constants.Kb*constants.T0/(constants.hbar^2*pi))^(3/2);
  material.Eg0         = 1.16964*constants.q;
  material.alfaEg      = 4.73e-4*constants.q;
  material.betaEg      = 6.36e2;
  material.Egap        = material.Eg0-material.alfaEg*((constants.T0^2)/(constants.T0+material.betaEg));
  material.Ei          = material.Egap/2+constants.Kb*constants.T0/2*log(material.Nv/material.Nc);
  material.EgapSio2    = 9*constants.q;
  material.deltaEcSio2 = 3.1*constants.q;
  material.deltaEvSio2 = material.EgapSio2-material.Egap-material.deltaEcSio2;

  material.ni          = sqrt(material.Nc*material.Nv)*exp(-material.Egap/(2*(constants.Kb * constants.T0)));
  material.Phims       = - material.Egap /(2*constants.q);

endfunction