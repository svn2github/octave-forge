fid=fopen('fntests.log','wt');
if fid<0,error('could not open fntests.log for writing');end
test('','explain',fid);
passes=0; tests=0;
printf('passes %d out of %d tests',passes,tests);disp('');
printf('see fntests.log for details');disp('');
fclose(fid);
