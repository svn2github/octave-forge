% data = ncData(filename,varname)
% data = ncData(var,dims,coord)
% data with coordinate values

function retval = ncData(varargin)

if ischar(varargin{1})
    filename = varargin{1};
    varname = varargin{2};
    var = ncArray(filename,varname);    
    [dims,coord] = nccoord(cached_decompress(filename),varname);
    
    for i=1:length(coord)
        coord(i).val = ncArray(filename,coord(i).name);
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

retval = class(self,'ncData',BaseArray(size(self.var)));



