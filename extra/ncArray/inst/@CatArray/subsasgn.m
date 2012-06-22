function self = subsasgn(self,idx,x)

[idx_global,idx_local,sz] = idx_global_local_(self,idx);




for j=1:self.na
    % get subset from global array x
    subset = subsref(x,idx_global{j});
    
    % set subset in j-th array
    subsasgn(self.arrays{j},idx_local{j},subset);   
end