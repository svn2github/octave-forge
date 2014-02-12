% Create a sparse interpolation matrix.
%
% [H,out] = sparse_interp(mask,I)
%
% Create interpolation matrix from mask and fractional indexes I
%
% Input:
%   mask: 0 invalid and 1 valid points (n-dimensional array)
%   I: fractional indexes (2-dim array n by mi, where mi is the number of points to interpolate)
% Ouput:
%   H: sparse matrix with interpolation coefficients 
%   out: true if value outside of grid

function [H,out] = sparse_interp(mask,I,iscyclic)

if ndims(mask) ~= size(I,1) && ~(isvector(mask) && size(I,1) == 1)
  error('sparse_interp: inconsistent arguments')
end

if isvector(mask)
  sz = numel(mask);
  mask = reshape(mask,[sz 1]);
else
  sz = size(mask);
end  

% n dimension of the problem
n = size(I,1);
m = prod(sz);

if nargin == 2
  iscyclic = zeros(1,n);
end


% mi is the number of arbitrarly distributed observations
mi = size(I,2);

% handle cyclic dimensions
for i = 1:n
  if iscyclic(i)
    % bring I(i,:) inside the interval [1 sz(i)+1[
    % since the i-th dimension is cyclic
    
    I(i,:) = mod(I(i,:)-1,sz(i))+1;        
  end
end


scale = [1 cumprod(sz(1:end-1))];

% integer index
ind = floor(I);
inside = true(1,mi);

for i = 1:n
  if ~iscyclic(i)
    % make a range check only for non-cyclic dimension
  
    % handle border cases
    p = find(I(i,:) == sz(i));
    ind(i,p) = sz(i)-1;

    inside = inside & 1 <= ind(i,:) & ind(i,:) < sz(i);
  end  
end

%whos ind

% interpolation coefficient
coeff(:,:,2) = I - ind;
coeff(:,:,1) = 1 - coeff(:,:,2);

% consider now only points inside
iind = find(inside);
coeff2 = coeff(:,iind,:);
ind2 = ind(:,iind);
mip = length(iind); % number of obs. inside

si = repmat(1:mip,[2^n 1]);
sj = ones(2^n, mip);
ss = ones(2^n, mip);

% loop over all corner of hypercube
for i=1:2^n
  
  % loop over all dimensions
  for j=1:n
    bit = bitget(i,j);
    
    % the j-index of the i-th corner has the index ip
    % this index ip is zero-based    
    ip = (ind2(j,:) + bit - 1);
    
    % ip must be [0 and sz(j)-1] (zero-based)
    % we know aleady that the point is inside the domain
    % so, if it is outside this range then it is because of periodicity
    ip = mod(ip,sz(j));
    
    sj(i,:) = sj(i,:) + scale(j) * ip;
    ss(i,:) = ss(i,:) .* coeff2(j,:,bit + 1);
  end
end 

% sj must refer to a valid point or its interpolation coefficient
% must be zero

inside(iind) = all(mask(sj) | ss == 0,1);
H = sparse(iind(si(:)),sj(:),ss(:),mi,m);

out = ~inside;
% LocalWords:  interp

% Copyright (C) 2004 Alexander Barth <a.barth@ulg.ac.be>
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
