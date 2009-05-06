%% Copyright (C) 2009 Carlo de Falco
%% 
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
%% along with this program; if not, see <http://www.gnu.org/licenses/>.

function [B, N] = __nrb_srf_basisfun__ (points, nrb);

  %%  __NRB_SRF_BASISFUN__: Undocumented internal function

    m    = size (nrb.coefs, 2) -1;
    n    = size (nrb.coefs, 3) -1;
    
    p    = nrb.order(1) -1;
    q    = nrb.order(2) -1;

    u = points(1,:);
    v = points(2,:);
    npt = length(u);

    U    = nrb.knots{1};
    V    = nrb.knots{2};
    
    w    = squeeze(nrb.coefs(4,:,:));

    spu  =  findspan (m, p, u, U); 
    Ik   =  numbasisfun (spu, u, p, U);

    spv  =  findspan (n, q, v, V);
    Jk   =  numbasisfun (spv, v, q, V);
    
    NuIkuk = basisfun (spu, u, p, U);
    NvJkvk = basisfun (spv, v, q, V);

    for k=1:npt
      [Jkb, Ika] = meshgrid(Jk(k, :), Ik(k, :)); 
      indIkJk(k, :)    = sub2ind([m+1, n+1], Ika(:)+1, Jkb(:)+1);
      wIkaJkb(1:p+1, 1:q+1) = reshape (w(indIkJk(k, :)), p+1, q+1); 

      NuIkukaNvJkvk(1:p+1, 1:q+1) = (NuIkuk(k, :).' * NvJkvk(k, :));
      RIkJk(k, :) = (NuIkukaNvJkvk .* wIkaJkb ./ sum(sum(NuIkukaNvJkvk .* wIkaJkb)))(:).';
    end
    
    B = RIkJk;
    N = indIkJk;
    
  end