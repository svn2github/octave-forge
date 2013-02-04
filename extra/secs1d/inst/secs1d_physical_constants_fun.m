%% Copyright (C) 2004-2012  Carlo de Falco
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

%% constants = secs1d_physical_constants_fun ();
%%
%% some useful physical constants 
%%
%% Kb       = Boltzman constant
%% q        = quantum of charge
%% e0       = permittivity of free space
%% hplanck  = Plank constant
%% hbar     = Plank constant by 2 pi
%% mn0      = free electron mass
%% T0       = temperature
%% Vth 	    = thermal voltage

function constants = secs1d_physical_constants_fun ();
  
  constants.Kb       = 1.3806503e-23;
  constants.q        = 1.602176462e-19;
  constants.e0       = 8.854187817e-12;
  constants.hplanck  = 6.626e-34;
  constants.hbar     = constants.hplanck/ (2*pi);
  constants.mn0      = 9.11e-31;
  constants.T0       = 300;
  constants.Vth      = constants.Kb * constants.T0 / constants.q;

endfunction