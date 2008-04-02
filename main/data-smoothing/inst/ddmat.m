function D = ddmat(x, d)
%%function D = ddmat(x, d)
%% Compute divided differencing matrix of order d
%%
%% Input
%%   x:  vector of sampling positions
%%   d:  order of diffferences
%% Output
%%   D:  the matrix; D * Y gives divided differences of order d
%%
%%References:  Anal. Chem. (2003) 75, 3631.
%%  

%% corrected the recursion multiplier; JJS 2/25/08

%% Copyright (C) 2003 Paul Eilers
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


m = length(x);
if d == 0
    D = speye(m);
else
    dx = x((d + 1):m) - x(1:(m - d));
    V = spdiags(1 ./ dx, 0, m - d, m - d);
    D = d * V * diff(ddmat(x, d - 1));
end
