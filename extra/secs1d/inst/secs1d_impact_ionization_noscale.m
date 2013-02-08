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

function    II = secs1d_impact_ionization_noscale ...
      (device, material, constants, algorithm, E, Jn, Jp, V, n, p, Fn, Fp)
  
  Fava_n = abs (diff (Fn) ./ diff (device.x));
  Fava_p = abs (diff (Fp) ./ diff (device.x));

  %% FIXME: move model parameters to material properties file
  [a_low_n, a_low_p]          = deal (7.0300e+07 ,  1.5820e+08);      # [1/m]
  [a_high_n, a_high_p]        = deal (7.0300e+07 ,  6.7100e+07);      # [1/m]
  [b_low_n, b_low_p]          = deal (1.2310e+08 ,  2.0360e+08);      # [V/m]
  [b_high_n, b_high_p]        = deal (1.2310e+08 ,  1.6930e+08);      # [V/m]
  [E0n, E0p]                  = deal (4.0000e+07 ,  4.0000e+07);      # [V/m]
  [hbarOmega_n, hbarOmega_p]  = deal (0.063      ,  0.063     );      # [V]
  
  a_n = ifelse (Fava_n < E0n, a_low_n, a_high_n);
  a_p = ifelse (Fava_n < E0p, a_low_p, a_high_p);
  b_n = ifelse (Fava_p < E0n, b_low_n, b_high_n);
  b_p = ifelse (Fava_p < E0p, b_low_p, b_high_p);

  %% FIXME: gamma depends on the temperature
  gamman = gammap = 1;
  
  fact = zeros (size (Jn));
  fact(Fava_n > 0) =  exp (- gamman .* b_n ./ Fava_n);
  alpha_n = gamman * a_n .* fact;

  fact = zeros (size (Jp));
  fact(Fava_p > 0) =  exp (- gammap .* b_p ./ Fava_p);
  alpha_p = gammap * a_p .* fact;

  II = alpha_n .* abs (Jn ./ constants.q) + alpha_p .* abs (Jp ./ constants.q);

endfunction
