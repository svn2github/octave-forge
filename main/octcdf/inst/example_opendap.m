
% Example for loading a dataset from an OPeNDAP server

nc = netcdf('http://hycom.coaps.fsu.edu/thredds/dodsC/atl_ops','r');

lat = nc{'Latitude'}(:);
lon = nc{'Longitude'}(:);
time = nc{'MT'}(end);

disp(['SSH forecast for part of the North Atlantic for ' datestr(datenum(1900,12,31) + time)]);

%
% Select the SSH for part of the North Atlantic
% 

i = find(-92 < lon & lon < -51);
j = find(23 < lat & lat < 45);   

x = lon(i);
y = lat(j);

% download data

ssh = nc{'ssh'}(end,j,i);

fillval = nc{'ssh'}._FillValue;
ssh(ssh == fillval) = NaN;

% With autonan, i.e. every _FillValue is replaced by a NaN
% nv = ncautonan(nc{'ssh'},1);
% ssh = nv(end,j,i);

ssh = squeeze(ssh);

close(nc);

colormap(hsv);
axis xy
iamgesc(ssh); 

% or with yapso
% pcolor(ssh);

