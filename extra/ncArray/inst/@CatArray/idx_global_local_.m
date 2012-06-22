% private method

function [idx_global,idx_local,sz] = idx_global_local_(self,idx)

assert(strcmp(idx.type,'()'))

n = length(size(self));

% number of indices must be equal to dimension
assert(length(idx.subs) == n)

lb = ones(1,n); % lower bound
ub = ones(1,n); % upper bound
sz = ones(1,n); % size

% transform all colons to index range
for i=1:n
    if strcmp(idx.subs{i},':')
        idx.subs{i} = 1:self.sz(i);
    end
    
    lb(i) = min(idx.subs{i});
    ub(i) = max(idx.subs{i});
    sz(i) = length(idx.subs{i});
end

%sz = ub-lb+1;

idx_local = cell(1,self.na);
idx_global = cell(1,self.na);

% loop over all arrays
for j=1:self.na
    idx_local{j} = idx;
    idx_global{j} = idx;
    
    % loop over all dimensions
    for i=1:n
        % rebase subscribt at self.start(j,i)
        tmp = idx.subs{i} - self.start(j,i) + 1;
        
        % only indeces within bounds of the j-th array
        sel = 1 <= tmp & tmp <= self.size(j,i);
        
        % index for getting the data from the local j-th array
        idx_local{j}.subs{i} = tmp(sel);
        
        % index for setting the data in the global B array
        %idx_global{j}.subs{i} = idx.subs{i}(sel) - lb(i)+1;
        
        if sum(sel) == 0
            idx_global{j}.subs{i} = [];
        else
            idx_global{j}.subs{i} = (1:sum(sel)) + find(sel,1,'first') - 1;
        end
    end
    
end
