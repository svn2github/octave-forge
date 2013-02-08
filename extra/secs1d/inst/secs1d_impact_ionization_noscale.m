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

%% II = secs1d_impact_ionization_noscale (E, Jn, Jp)

function    II = secs1d_impact_ionization_noscale (E, Jn, Jp, constants)
  
  %% FIXME: 
  a_n       = 7.03e7;            %[m^-1]
  b_n       = 1.231e8;           %[V * m^-1]
  a_h_low   = 1.582e8;           %[m^-1]
  b_h_low   = 2.036e8;           %[V * m^-1]
  a_h_high  = 6.71e7;            %[m^-1]
  b_h_high  = 1.639e7;           %[V * m^-1]
  em_0      = 4.0e7;             %[V * m^-1]
  hbarOmega = 0.063;             %[eV]
  gam       = 1.0;
  t_300     = 300.000;           %[K]
  k_boltz   = 1.380658e-23;      %[J * K^-1]

  
  Ebool = (abs(E) >= em_0);
  a_h   = (Ebool * a_h_high) + (1 - Ebool) .* a_h_low;
  b_h   = (Ebool * b_h_high) + (1 - Ebool) .* b_h_low;
  

  % N.B. gam is a parameter that depends on the temperature

  % gam = tanh(hbarOmega / (2*K_bolz*t_300) ) / tanh (hbarOmega / (2*k_bolz*t));
  
  alpha_n = gam .* a_n .* exp (-gam * b_n ./ (abs (E) + 1.0 ));
  alpha_p = gam .* a_h .* exp (-gam * b_h ./ (abs (E) + 1.0 ));
 
  
  II = alpha_n .* abs (Jn) ./ constants.q + alpha_p .* abs (Jp) ./ constants.q ;

endfunction
