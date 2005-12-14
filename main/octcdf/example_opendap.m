
nc = netcdf('http://asterix.rsmas.miami.edu/thredds/dodsC/atl-ops-forecast/ssh','r');

lat = nc{'Latitude'}(:);
lon = nc{'Longitude'}(:);
time = nc{'time'}(end);

disp(['SSH forecast for part of the North Atlantic for ' datestr(datenum(1900,12,31) + time)]);

%
% Select the SSH for part of the North Atlantic
% 

i = find(-92 < lon & lon < -51); i=i(1):i(end);
j = find(23 < lat & lat < 45);   j=j(1):j(end);

x = lon(i);
y = lat(j);

% download data

ssh = nc{'ssh'}(end,j,i);

fillval = nc{'ssh'}._FillValue;


ssh(ssh == fillval) = NaN;
ssh = reshape(ssh,length(j),length(i));

ncclose(nc);


colormap(hsv);
contourf(ssh,10,2); 

% Octaviz would give you a much nicer plot
%vtk_pcolor(ssh);

