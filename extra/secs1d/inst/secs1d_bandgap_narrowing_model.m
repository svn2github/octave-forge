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

function degby2q = secs1d_bandgap_narrowing_model (n_a, n_d)

  degbn = 6.92e-3   ; %[eV] 
  N0    = 1.3e23    ; %[m^-3]
  
  deg0  = -4.795e-3 ; %[eV]
  C     = 0.5       ; %[-]
  logNbyN0 = log ((n_a + n_d) / N0);
  degby2q = (deg0 + degbn * (logNbyN0 + sqrt (logNbyN0.^2 + C))) / (2.0);

endfunction
