% V = ncBaseArray(filename,varname)
% V = ncBaseArray(filename,varname,'property',value,...)
% create a ncBaseArray that can be accessed as a normal matlab array.
% Ths object is a helper object. Users should normally call ncArray.
%
% For read access filename can be compressed if it has the extensions
% ".gz" or ".bz2". It use the function cache_decompress to cache to
% decompressed files.
%
% Data is loaded by ncread and saved by ncwrite. Values equal to _FillValue
% are thus replaced by NaN and the scaling (add_offset and
% scale_factor) is applied during loading and saving.
%
% Properties:
%   'tooBigToLoad': if tooBigToLoad is set to true, then only the minimum
%   data will be loaded. However this can be quite slow.
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

function retval = ncBaseArray(filename,varname,varargin)

self.tooBigToLoad = false;
prop = varargin;

for i=1:2:length(prop)
    if strcmp(prop{i},'tooBigToLoad ')
        self.tooBigToLoad = prop{i+1};
    end
end

self.filename = filename;
self.varname = varname;

self.vinfo = ncinfo(cached_decompress(filename),varname);
self.sz = self.vinfo.Size;

self.dims = self.vinfo.Dimensions;
self.nd = length(self.dims);

retval = class(self,'ncBaseArray',BaseArray(self.sz));
end
