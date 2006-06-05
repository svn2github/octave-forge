
nc = netcdf('http://asterix.rsmas.miami.edu/thredds/dodsC/atl-ops-forecast/ssh','r');

lat = nc{'Latitude'}(:);
lon = nc{'Longitude'}(:);
time = nc{'time'}(end);

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

ncclose(nc);


colormap(hsv);
contourf(ssh,10,2); 

% Octaviz would give you a much nicer plot
%vtk_pcolor(ssh);

