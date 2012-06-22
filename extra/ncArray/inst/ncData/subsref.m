function varargout = subsref(self,idx)

if strcmp(idx(1).type,'()')
    
    % no subscripts mean that we load all () -> (:,:,...)
    if isempty(idx(1).subs)
        for i=1:self.nd
            idx(1).subs{i} = ':';
        end
    end
end

% catch expressions like:
% data(:,:,:).coord

if length(idx) == 2 && strcmp(idx(2).type,'.') && strcmp(idx(2).subs,'coord')    
    for i=1:length(self.coord)
        % get indeces of the dimensions of the i-th coordinate which are also
        % coordinate of the variable
        
        % replace dummy by ~ once older version have died
        [dummy,j] = intersect(self.dims,self.coord(i).dims);
        j = sort(j);
        idx_c.type = '()';
        idx_c.subs = idx(1).subs(j);
        
        varargout{i} = subsref(self.coord(i).val,idx_c);
    end       
else
    % pass subsref to underlying ncBaseArray
    varargout{1} = subsref(self.var,idx);
end