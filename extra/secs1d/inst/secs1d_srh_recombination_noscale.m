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

%% FIXME: add more descriptive docstring.
%%  [Rn, Rp, Gn, Gp] = secs1d_srh_recombination_noscale ...
%%      (device, material, constants, algorithm, n, p);

function  [Rn, Rp, Gn, Gp] = secs1d_srh_recombination_noscale ...
      (device, material, constants, algorithm, n, p);

  fact   = 1 ./ (device.tn .* (p + device.ni) + device.tp .* (n + device.ni));
  
  Rn = p .* fact;
  Rp = n .* fact;

  Gp = Gn = device.ni .^ 2 .* fact;

endfunction

