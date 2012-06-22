% V = ncBaseArray(filename,varname)
% V = ncBaseArray(filename,varname,'property',value,...)
% create a ncBaseArray that can be accessed as a normal matlab array.
%
% For read access filename can be compressed if it has the extensions
% ".gz" or ".bz2". It use the function cache_decompress to cache to
% decompressed files.
%
% Data is loaded by ncread and saved by ncwrite. Values equal to _FillValue
% are thus replaced by NaN and the scaling (add_offset and
% scale_factor) is applied during loading and saving.
%
%
% Example:
%
% Loading the variable (assuming V is 3 dimensional):
%
% x = V(1,1,1);   % load element 1,1,1
% x = V(:,:,:);   % load the complete array
% x = V();  x = full(V)  % loads also the complete array
%
% Saving data in the netcdf file:
% V(1,1,1) = x;   % save x in element 1,1,1
% V(:,:,:) = x;
%
% Attributes
% units = V.units; % get attribute called "units"
% V.units = 'degree C'; % set attributes;
%
% Note: use the '.()' notation if the attribute has a leading underscore 
% (due to a limitation in the matlab parser):
%
% V.('_someStrangeAttribute') = 123;
%
% see also cache_decompress 

% hidded constructor signature:
% data = ncArray(filename,varname)
% is used to create data with coordinate values by ncCatArray

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



