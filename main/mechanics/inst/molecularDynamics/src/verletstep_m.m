%% Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
%%
%%    This program is free software: you can redistribute it and/or modify
%%    it under the terms of the GNU General Public License as published by
%%    the Free Software Foundation, either version 3 of the License, or
%%    any later version.
%%
%%    This program is distributed in the hope that it will be useful,
%%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%%    GNU General Public License for more details.
%%
%%    You should have received a copy of the GNU General Public License
%%    along with this program. If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {[@var{P} @var{V} @var{F}] = } verletstep_m (@var{P}, @var{V}, @var{M}, @var{dt}, @var{force})
%% This function is used to benchmark its C++ version.
%% @end deftypefn
function [P V F] = verletstep_m (P, V, M, dt, force)

  [Npart Ndims] = size(P);
  PP = repmat(P,1,Npart);
  VV = repmat(V,1,Npart);
  MM = repmat(M,1,Ndims);

  [F1 F2] = arrayfun (force, PP, PP', VV, VV');
  F = sum (triu (F1, 1) + triu (F2, 1).', 2) ./ MM;


  V = V + F * dt/2;
  P = P + V * dt;

  PP = repmat(P,1,Npart);
  VV = repmat(V,1,Npart);

  [F1 F2] = arrayfun (force, PP, PP', VV, VV');
  F = sum (triu (F1, 1) + triu (F2, 1).', 2) ./ MM;

  V = V + F * dt/2;

end
