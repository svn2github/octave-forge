% This script tests the functioning of the octcdf toolbox

%the delete function does not exist in cygwin.
%delete('test.nc');
system('rm -f test.nc');

nc = netcdf('test.nc','c');

nc('time') = 5;
nc('space') = 3;

int_var =  reshape(1:15,5,3);
short_var =  reshape(1:15,5,3);
float_var =  reshape(1:15,5,3) * 2.2;
char_var = reshape('ajhkjhgkjhfdgkh',5,3);

nc{'int_var'} =  ncint('time','space');
nc{'int_var'}.byte_att = ncbyte(12);
nc{'int_var'}.int_att = ncint(12);
nc{'int_var'}.double_att = ncdouble(12);
nc{'int_var'}.char_att = 'attribute';
nc{'int_var'}(:) = int_var;

nc{'short_var'} =  ncshort('time','space');
nc{'short_var'}(:) = short_var;

nc{'byte_var'} =  ncbyte('time','space');
nc{'byte_var'}(:) = short_var;

nc{'float_var'} =  ncfloat('time','space');
nc{'float_var'}(:) = float_var;

nc{'double_var'} =  ncdouble('time','space');
nc{'double_var'}(:) = float_var;

nc{'char_var'} =  ncchar('time','space');
nc{'char_var'}(:) = char_var;

% global attributes

nc.int8_att = int8(123);
nc.int16_att = int16(123);
nc.int32_att = int32(123);
nc.int64_att = int64(123);
nc.double_att = 123.;
nc.string_att = "test string";

% retrieve

int_var2 = nc{'int_var'}(:);
ok(1) = all(all(int_var2 == int_var));

short_var2 = nc{'short_var'}(:);
ok(2)  = all(all(short_var2 == short_var));

short_var2 = nc{'byte_var'}(:);
ok(3) = all(all(short_var2 == short_var));

float_var2 = nc{'float_var'}(:);
ok(4) = all(all(float_var2 == float_var));

char_var2 = nc{'char_var'}(:);
ok(5) = all(all(char_var2 == char_var));

float_var2 = nc{'double_var'}(:);
ok(6) = all(all(float_var2 == float_var));

ok(7) = nc.int8_att == 123;
ok(8) = nc.int16_att == 123;
ok(9) = nc.int32_att == 123;
ok(10) = nc.int64_att == 123;
ok(11) = nc.double_att == 123;

varlist = ncvar(nc);
ok(12) = length(varlist ) == 6;


attlist = ncatt(nc{'int_var'});
ok(13) = length(attlist) == 4;
ok(14) = attlist{1}(:) == 12;
ok(15) = attlist{2}(:) == 12;
ok(16) = attlist{3}(:) == 12;
% cygwin appears not to have strcmp
ok(17) = all(attlist{4}(:) == 'attribute');

attlist = ncatt(nc);
ok(18) = length(attlist) == 6;
ok(19) = attlist{1}(:) == 123;
ok(20) = attlist{2}(:) == 123;
ok(21) = attlist{3}(:) == 123;

dimlist = ncdim(nc);
ok(22) = length(dimlist) == 2;
ok(23) = dimlist{1}(:) == 5;
ok(24) = dimlist{2}(:) == 3;

ncclose(nc);

ok
