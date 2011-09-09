%% Copyright (C) 2004,2007,2008,2009,2010,2011  Carlo de Falco
%%
%% This file is part of:
%%     secs3d - A 3-D Drift--Diffusion Semiconductor Device Simulator 
%%
%%  secs3d is free software; you can redistribute it and/or modify
%%  it under the terms of the GNU General Public License as published by
%%  the Free Software Foundation; either version 2 of the License, or
%%  (at your option) any later version.
%%
%%  secs3d is distributed in the hope that it will be useful,
%%  but WITHOUT ANY WARRANTY; without even the implied warranty of
%%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%  GNU General Public License for more details.
%%
%%  You should have received a copy of the GNU General Public License
%%  along with secs3d; If not, see <http://www.gnu.org/licenses/>.
%%
%%  author: Carlo de Falco     <cdf _AT_ users.sourceforge.net>

%  s = Urrextrapolation(X)
%  RRE vector extrapolation see 
%  Smith, Ford & Sidi SIREV 29 II 06/1987


function s = Urrextrapolation(X)

if (columns(X)>rows(X))
  X=X';
end

% compute first and second variations
U = X(:,2:end) - X(:,1:end-1);
V = U(:,2:end) - U(:,1:end-1);

% eliminate unused u_k column
U(:,end) = [];

s = X(:,1) - U * pinv(V) * U(:,1);

