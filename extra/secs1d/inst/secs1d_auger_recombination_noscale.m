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

%% [Rn, Rp, G] = secs1d_auger_recombination_noscale ...
%%      (device, material, constants, algorithm, n, p);

function [Rn, Rp, G] = secs1d_auger_recombination_noscale ...
      (device, material, constants, algorithm, n, p);

  %% FIXME: move model parameters to material properties file
  Cn0 = 2.9000e-43;      %[m^6 *s^-1]
  Cp0 = 1.0280e-43;      %[m^6 *s^-1]
  Hn  = 3.46667;
  Hp  = 8.25688;
  NN  = 1.0e+24;         %[m^-3]

  Cn = Cn0 * (1.0 + Hn * exp (-n ./ NN));
  Cp = Cp0 * (1.0 + Hp * exp (-p ./ NN));
  
  fact = (Cn .* n + Cp .* p);
  Rn   = p .* fact;
  Rp   = n .* fact;
  G    = device.ni .^ 2 .* fact;
  
endfunction
