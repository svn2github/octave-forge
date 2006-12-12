% Example for creating and reading a netcdf file


% create some variables to store them in a netcdf file

latitude = -90:1:90;
longitude = -179:1:180;
[y,x] = meshgrid(pi/180 * latitude,pi/180 * longitude);
temp = cos(2*x) .* cos(y);

%---------------------------------------%
%                                       %
% write data to a netcdf file           %
%                                       %
%---------------------------------------%

% create netcdf file called example.nc

nc = netcdf('example.nc','c');

% define the dimension longitude and latitude of size
% 360 and 181 respectively.

nc('longitude') = 360;
nc('latitude') = 181;

% coordinate variable longitude

nc{'longitude'} = ncdouble('longitude');              % create a variable longitude of type double with 
                                                      % 360 elements (dimension longitude).
nc{'longitude'}(:) = longitude;                       % store the octave variable longitude in the netcdf file
nc{'longitude'}.units = 'degree West';                % define a string attribute of the variable longitude

% coordinate variable latitude

nc{'latitude'} = ncdouble('latitude');;               % create a variable latitude of type double with 
                                                      % 181 elements (dimension latitude).                
nc{'latitude'}(:) = latitude;                         % store the octave variable latitude in the netcdf file
nc{'latitude'}.units = 'degree North';                % define a string attribute of the variable latitude

% variable temp

nc{'temp'} = ncdouble('longitude','latitude');        % create a variable temp of type double of the size 360x181 
                                                      % (dimension longitude and latitude).    
nc{'temp'}(:) = temp;                                 % store the octave variable temp in the netcdf file
nc{'temp'}.units = 'degree Celsius';                  % define a string attribute of the variable
nc{'temp'}.valid_range = [-10 40];                    % define a vector of doubles attribute of the variable

nc.history = 'netcdf file created by example_netcdf.m in octave';
                                                      % define a global string attribute

ncclose(nc)                                           % close netcdf file and all changes are written to disk


disp(['example.nc file created. You might now inspect this file with the shell command "ncdump -h example.nc"']);


%---------------------------------------%
%                                       %
% read data from a netcdf file          %
%                                       %
%---------------------------------------%

nc = netcdf('example.nc','r');                       % open netcdf file example.nc in read-only

n = nc('longitude');                                 % get the length of the dimension longitude

temp = nc{'temp'}(:);                                % retrieve the netcdf variable temp
temp_units = nc{'temp'}.units;                       % retrieve the attribute units of variable temp
temp_valid_range = nc{'temp'}.valid_range;           % retrieve the attribute valid_range of variable temp

global_history = nc.history;                         % retrieve the global attribute history
