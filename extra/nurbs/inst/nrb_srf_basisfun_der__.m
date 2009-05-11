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

function [Bu, Bv, N] = nrb_srf_basisfun_der__ (points, nrb);

  %%  __NRB_SRF_BASISFUN_DER__: Undocumented internal function

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
  
  NuIkukprime = basisfunder (spu, p, u, U, 1);
  NuIkukprime = squeeze(NuIkukprime(:,2,:));
  
  NvJkvkprime = basisfunder (spv, q, v, V, 1);
  NvJkvkprime = squeeze(NvJkvkprime(:,2,:));
  
  
  for k=1:npt
    [Ika, Jkb] = meshgrid(Ik(k, :), Jk(k, :)); 
    
    N(k, :)    = sub2ind([m+1, n+1], Ika(:)+1, Jkb(:)+1);
    wIkaJkb(1:p+1, 1:q+1) = reshape (w(N(k, :)), p+1, q+1); 
    
    Num    = (NuIkuk(k, :).' * NvJkvk(k, :)) .* wIkaJkb;
    Num_du = (NuIkukprime(k, :).' * NvJkvk(k, :)) .* wIkaJkb;
    Num_dv = (NuIkuk(k, :).' * NvJkvkprime(k, :)) .* wIkaJkb;
    Denom  = sum(sum(Num));
    Denom_du = sum(sum(Num_du));
    Denom_dv = sum(sum(Num_dv));
    
    Bu(k, :) = reshape((Num_du/Denom - Denom_du.*Num/Denom.^2),1,[]);
    Bv(k, :) = reshape((Num_dv/Denom - Denom_dv.*Num/Denom.^2),1,[]);
  end
  
end