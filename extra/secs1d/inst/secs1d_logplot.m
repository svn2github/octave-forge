%% Copyright (C) 2013  Carlo de Falco
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

function secs1d_logplot (x, y)

  plot (x, __logplot__ (y)); 
  set (gca, "yticklabel",
       arrayfun (@(x) sprintf ("%s10^{%g}", ifelse (x >=0, "+", "-"), abs(x)),
                 get (gca, "ytick"), "uniformoutput", false));
endfunction

function logplot = __logplot__ (x)
  logplot = asinh (x/2) / log(10);
endfunction