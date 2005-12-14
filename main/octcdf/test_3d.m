

%the delete function does not exist in cygwin.
%delete('test.nc');
system('rm -f test.nc');
nc = netcdf('test.nc','c');

imax = 10;
jmax = 11;
kmax = 12;


nc('imax') = imax;
nc('jmax') = jmax;
nc('kmax') = kmax;


float_var =  reshape(1:imax*jmax*kmax,imax,jmax,kmax);

nc{'float_var'} =  ncfloat('imax','jmax','kmax');

for i=1:imax
nc{'float_var'}(i,:,:) = squeeze(float_var(i,:,:));
end

float_var2 = nc{'float_var'}(:);

ok = all(all(all(float_var2 == float_var)))

ncclose(nc);