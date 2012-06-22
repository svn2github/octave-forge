function F = full(self);

n = length(self.sz);
idx.type = '()';

for i=1:n
    idx.subs{i} = ':';
end

F = subsref(self,idx);