% data = ncArray(filename,varname)
% data = ncArray(var,dims,coord)
% data with coordinate values

function retval = ncArray(varargin)

if ischar(varargin{1})
    filename = varargin{1};
    varname = varargin{2};
    var = ncBaseArray(filename,varname);    
    [dims,coord] = nccoord(cached_decompress(filename),varname);
    
    for i=1:length(coord)
        coord(i).val = ncBaseArray(filename,coord(i).name);
    end
else
    var = varargin{1};    
    dims = varargin{2};
    coord = varargin{3};
end

self.var = var;
self.dims = dims;
self.nd = length(self.dims);
self.coord = coord;

retval = class(self,'ncArray',BaseArray(size(self.var)));



