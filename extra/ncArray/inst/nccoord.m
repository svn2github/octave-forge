% coord = nccoord(filename,varname)
% get coordinates of a variables using CF convention

function [dims,coord] = nccoord(filename,varname)

finfo = ncinfo(filename);
vinfo = ncinfo(filename,varname);

% determine coordinates
% using CF convention

dims = vinfo.Dimensions;

% create empty coord array with the fields name and dims
coord = struct('name',{},'dims',{});

% check the coordinate attribute
index = strmatch('coordinates',{vinfo.Attributes(:).Name});
if ~isempty(index)
    tmp = strsplit(vinfo.Attributes(index).Value,' ');
    
    for i=1:length(tmp)
        coord = addcoord(coord,tmp{i},finfo);
    end
end

% check for coordinate dimensions
for i=1:length(dims)
    % check if variable with the same name than the dimension exist
    index = strmatch(dims{i},{finfo.Variables(:).Name});
    if ~isempty(index)
        coord = addcoord(coord,dims{i},finfo);
    end
end


end

function coord = addcoord(coord,name,finfo)

% check if coordinate is aleady in the list
if isempty(strmatch(name,{coord(:).name}))
    
    % check if name is variable
    index = strmatch(name,{finfo.Variables(:).Name});
    if ~isempty(index)
        c.name = name;
        c.dims = finfo.Variables(index).Dimensions;
        
        coord(end+1) = c;
    end
end

end