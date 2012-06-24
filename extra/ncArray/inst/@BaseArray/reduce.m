% [s,n] = reduce(self,funred,funelem,dim)
% reduce array using the function funred applied to all elements 
% after the function funelem was applied along dimension dim

function [s,n] = reduce(self,funred,funelem,dim)

sz = size(self);
if nargin == 3
  dim = find(sz ~= 1,1);
  if isempty(dim)
    dim = 1;
  end
end

idx.type = '()';
nd = length(sz);
idx.subs = cell(1,nd);
for i=1:nd
  idx.subs{i} = ':';
end

n = size(self,dim);

if n == 0
  s = [];
else
  idx.subs{dim} = 1;  
  s = funelem(subsref(self,idx));
  
  for i=2:n
    idx.subs{dim} = i;  
    s = funred(s,funelem(subsref(self,idx)));
  end
end
