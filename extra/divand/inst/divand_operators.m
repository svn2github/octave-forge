% Generate the gradient and Laplacian operators.
%
% s = divand_operators(mask,pmn,nu,iscyclic)
%
% Form sparse matrixes representing the gradient and Laplacian using
% finite differences
%
% Input:
%   mask: binary mask delimiting the domain. 1 is inside and 0 outside.
%         For oceanographic application, this is the land-sea mask.
%   pmn: scale factor of the grid. 
%   nu: diffusion coefficient of the Laplacian
%
% Output:
%   s: stucture containing
%   s.Dx: cell array of the gradient
%   s.D: Laplaciant
%   s.sv: structure describing the state vector
%   s.mask: land-sea mask
%   s.WE: diagonal matrix where each element is the surface
%     of a grid cell


function s = divand_operators(mask,pmn,nu,iscyclic,mapindex)

pmn = cat_cell_array(pmn);

% number of dimensions
n = size(pmn,ndims(pmn));

sz = size(mask);

sv = statevector_init(mask);

if ~isempty(mapindex)
  % mapindex is unpacked and referers to unpacked indices  
    
  % range of packed indices
  % land point map to 1, but those points are remove by statevector_pack
  i2 = statevector_unpack(sv,(1:sv.n)',1);
  mapindex_packed = statevector_pack(sv,i2(mapindex));
  
  % applybc*x applies the boundary conditions to x
  i = [1:sv.n]';
  applybc = sparse(i,mapindex_packed(i),ones(1,sv.n),sv.n,sv.n);

  % a halo point is points which maps to a (different) interior point
  % a interior point maps to itself
  s.isinterior = (i == mapindex_packed(i));
  s.isinterior_unpacked = statevector_unpack(sv,s.isinterior);
  
  s.mapindex_packed = mapindex_packed;
end

D = divand_laplacian(mask,pmn,nu,iscyclic);

% XXX remove this WE
d = statevector_pack(sv,1./(prod(pmn,n+1)));
WE = sparse_diag(sqrt(d));

for i=1:n
  S = sparse_stagger(sz,i,iscyclic(i));
  
  % mask on staggered grid
  ma = (S * mask(:) == 1);
  s.mask_stag{i} = ma;
  
  d = sparse_pack(ma) * prod(S * reshape(pmn,numel(mask),n),2);
  d = 1./d;
  s.WEs{i} = sparse_diag(sqrt(d));
end

s.Dx = cell(n,1);
[s.Dx{:}] = sparse_gradient(mask,pmn,iscyclic);


if ~isempty(mapindex)
  D = applybc * D * applybc;
  WE = sparse_diag(s.isinterior) * WE;

  for i=1:n
    S = sparse_stagger(sz,i,iscyclic(i));  
    s.isinterior_stag{i} =  sparse_pack(s.mask_stag{i}) * S * s.isinterior_unpacked(:);  
    
    % the results of 's.Dx{i} * field' satisfies the bc is field does
    % there is need to reapply the bc on the result
    s.Dx{i} = s.Dx{i} * applybc;
  end
  
  s.applybc = applybc;
end

s.D = D;
s.sv = sv;
s.mask = mask;
s.WE = WE;
s.n = n;

% Copyright (C) 2014 Alexander Barth <a.barth@ulg.ac.be>
%
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 2 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, see <http://www.gnu.org/licenses/>.
