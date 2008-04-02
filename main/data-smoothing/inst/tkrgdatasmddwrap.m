%%cve|stdevdif = tkrgdatasmddwrap (log10lambda, x, y, d, 'cve'|'stdev'[, stdev])
%%
%%  Wrapper function for tkrgdatasmdd in order to minimize over lambda
%%  w.r.t. cross-validation error OR the squared difference between the
%%  standard deviation of data from the smooth data and the given
%%  standard deviation.
%%

%% Copyright (C) 2008 Jonathan Stickel
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; If not, see <http://www.gnu.org/licenses/>. 


function out = tkrgdatasmddwrap (log10lambda, x, y, d, mintype, stdev)

  lambda = 10^(log10lambda);
  
  if ( strcmp(mintype,"stdev") )
    ys = tkrgdatasmdd(x, y, lambda, d);
    stdevd = std(y-ys);
    out = (stdevd - stdev)^2;
  else
    [ys, cve] = tkrgdatasmdd(x, y, lambda, d);
    out = cve;
  endif

endfunction
