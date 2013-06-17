% Read a NetCDF variable.
%
% x = ncread(filename,varname)
% x = ncread(filename,varname,start,count,stride)
% read the variable varname from file filename.
% The parameter start contains the starting indices, count
% is the number of elements and stride the increment between
% two successive elements (default 1).

function x = ncread(filename,varname,start,count,stride)

ncid = netcdf_open(filename,'NC_NOWRITE');
varid = netcdf_inqVarID(ncid, varname);
[varname_,xtype,dimids,natts] = netcdf_inqVar(ncid,varid);

% number of dimenions
nd = length(dimids);

sz = zeros(1,nd);
for i=1:length(dimids)
  [dimname, sz(i)] = netcdf_inqDim(ncid,dimids(i));
end

if nargin < 3
  start = ones(1,nd);
end

if nargin < 4
  count = inf*ones(1,nd);
end

if nargin < 5
  stride = ones(1,nd);
end

% replace inf in count
i = count == inf;
count(i) = (sz(i)-start(i))./stride(i) + 1;

x = netcdf_getVar(ncid,varid,start-1,count,stride);

% apply attributes

factor = [];
offset = [];
fv = [];

for i = 0:natts-1
  attname = netcdf_inqAttName(ncid,varid,i);
%  attname
  if strcmp(attname,'scale_factor')
    factor = netcdf_getAtt(ncid,varid,'scale_factor');
  elseif strcmp(attname,'add_offset')
    offset = netcdf_getAtt(ncid,varid,'add_offset');
  elseif strcmp(attname,'_FillValue')
    fv = netcdf_getAtt(ncid,varid,'_FillValue');
  end    
end

if ~isempty(fv)
  x(x == fv) = NaN;
end

if ~isempty(factor)
  x = x * factor;
end

if ~isempty(offset)
  x = x + offset;
end

netcdf_close(ncid);

%% Copyright (C) 2013 Alexander Barth
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; If not, see <http://www.gnu.org/licenses/>.