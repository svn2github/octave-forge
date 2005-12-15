

%!shared fname, nc
%! fname = [tmpnam '-octcdf.nc'];
%! nc = netcdf(fname,'c');

%!# Test reading/writing dimension
%!test
%! nc('time') = 5;
%! nc('space') = 3;
%! assert(nc('time'),5);
%! assert(nc('space'),3);

%!# Test reading/writing global attributes
%!test
%! nc.byte_att = ncbyte(123);
%! nc.short_att = ncshort(123);
%! nc.int_att = ncint(123);
%! nc.long_att = nclong(123);
%! nc.float_att = ncfloat(123);
%! nc.double_att = ncdouble(123.4);
%! nc.string_att = "test string";
%! assert(nc.byte_att,123)
%! assert(nc.short_att,123)
%! assert(nc.int_att,123)
%! assert(nc.long_att,123)
%! assert(nc.float_att,123)
%! assert(nc.double_att,123.4)
%! assert(nc.string_att,"test string")

%!# Test reading/writing varaible of type byte
%!test
%! byte_var =  reshape(1:15,5,3);
%! nc{'byte_var'} =  ncbyte('time','space');
%! nc{'byte_var'}(:) = byte_var;
%! assert(nc{'byte_var'}(:),byte_var);

%!# Test reading/writing varaible of type short
%!test
%! short_var =  reshape(1:15,5,3);
%! nc{'short_var'} =  ncshort('time','space');
%! nc{'short_var'}(:) = short_var;
%! assert(nc{'short_var'}(:),short_var);

%!# Test reading/writing varaible of type int
%!test
%! int_var =  reshape(1:15,5,3);
%! nc{'int_var'} =  ncint('time','space');
%! nc{'int_var'}(:) = int_var;
%! assert(nc{'int_var'}(:),int_var);

%!# Test reading/writing varaible of type long
%!test
%! long_var =  reshape(1:15,5,3);
%! nc{'long_var'} =  nclong('time','space');
%! nc{'long_var'}(:) = long_var;
%! assert(nc{'long_var'}(:),long_var);

%!# Test reading/writing varaible of type float
%!test
%! float_var =  reshape(1:15,5,3)/10;
%! nc{'float_var'} =  ncfloat('time','space');
%! nc{'float_var'}(:) = float_var;
%! assert(nc{'float_var'}(:),float_var,1e-5);

%!# Test reading/writing varaible of type double
%!test
%! double_var =  reshape(1:15,5,3)/10;
%! nc{'double_var'} =  ncdouble('time','space');
%! nc{'double_var'}(:) = double_var;
%! assert(nc{'double_var'}(:),double_var);

%!# Test reading/writing varaible of type char
%!test
%! char_var = reshape('ajhkjhgkjhfdgkh',5,3);
%! nc{'char_var'} =  ncchar('time','space');
%! nc{'char_var'}(:) = char_var;
%! assert(nc{'char_var'}(:),char_var);

%!# Test reading/writing variable attributes
%!test
%! nv = nc{'int_var'};
%! nv.byte_att = ncbyte(123);
%! nv.short_att = ncshort(123);
%! nv.int_att = ncint(123);
%! nv.long_att = nclong(123);
%! nv.float_att = ncfloat(123);
%! nv.double_att = ncdouble(123.4);
%! nv.string_att = "test string";
%! assert(nv.byte_att,123)
%! assert(nv.short_att,123)
%! assert(nv.int_att,123)
%! assert(nv.long_att,123)
%! assert(nv.float_att,123)
%! assert(nv.double_att,123.4)
%! assert(nv.string_att,"test string")

%!# Test ncdim
%!test
%! dimlist = ncdim(nc);
%! assert(length(dimlist),2);
%! assert(dimlist{1}(:),5);
%! assert(dimlist{2}(:),3);

%!# Test ncatt
%!test
%! attlist = ncatt(nc);
%! assert(length(attlist),7);
%! assert(ncname(attlist{1}),'byte_att');
%! assert(ncdatatype(attlist{1}),'byte');
%! assert(attlist{1}(:),123);

%!# Test ncvar
%!test
%! varlist = ncvar(nc);
%! assert(length(varlist),7);
%! assert(ncname(varlist{1}),'byte_var');
%! assert(ncdatatype(varlist{1}),'byte');

%!# Test to write a variable by slices
%!test
%! imax = 10;
%! jmax = 11;
%! kmax = 12;
%! nc('imax') = imax;
%! nc('jmax') = jmax;
%! nc('kmax') = kmax;
%! sliced_var =  reshape(1:imax*jmax*kmax,imax,jmax,kmax);
%! nc{'sliced_var'} =  ncdouble('imax','jmax','kmax');
%! 
%! for i=1:imax
%!   nc{'sliced_var'}(i,:,:) = squeeze(sliced_var(i,:,:));
%! end
%! 
%! sliced_var2 = nc{'sliced_var'}(:);
%! 
%! assert(sliced_var2 == sliced_var)

%!test
%! ncclose(nc);
%! delete(fname);



