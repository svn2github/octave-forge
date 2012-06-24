function s = reduce(self,funred,funelem,dim)

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

if size(self,dim) == 0
  s = [];
else
  idx.subs{dim} = 1;  
  s = funelem(subsref(self,idx));
  
  for i=2:size(self,dim)
    idx.subs{dim} = i;  
    s = funred(s,funelem(subsref(self,idx)));
  end
end
