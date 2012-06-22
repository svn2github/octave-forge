function self = subsasgn(self,idxs,x)
%idx

idx = idxs(1);
assert(strcmp(idx.type,'()'))
[start, count, stride] = ncsub(self,idx);

if all(count ~= 0)
    ncwrite(self.filename,self.varname,x,start,stride);
end
