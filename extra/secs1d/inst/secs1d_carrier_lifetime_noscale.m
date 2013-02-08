%% Copyright (C) 2013 Carlo de Falco, Davide Cagnoni, Fabio Mauri
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

%% tau = secs1d_carrier_lifetime_noscale (Na, Nd, carrier)

function tau = secs1d_carrier_lifetime_noscale (Na, Nd, carrier)

  if (carrier =='n')

    %% FIXME: move model parameters to material properties file
    %% Electrons reference values 
 
       tau0    = 1.0e-05;  %[s]
       n_ref   = 1.0e22;   %[m^-3]
       
  elseif (carrier =='p')
    %% FIXME: move model parameters to material properties file
    %% Hole reference values 
  
       tau0    = 3.0e-06;  %[s]
       n_ref   = 1.0e22;   %[m^-3]
  else
    error ("Carrier lifetime models only defined for electons (carrier='n') or holes (carrier='p')")
  endif

  
  tau = tau0 ./ (1 + (Na + Nd) ./ n_ref);
 
endfunction
