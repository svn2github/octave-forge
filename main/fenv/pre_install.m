function pre_install(desc)
# Sets FENV_OPTS variable for the Makefile
# If the system is detected as an x86/x86_64 machine, we define a flag which
# is later used when compiling system_dependent.cc

systemtype = computer();

# Presently, we support either x86_64...
supported = ~isempty(findstr('x86_64', systemtype));

# or x86...
# 	(Actually we only support i486DX and above, 
# 	but in many cases the default compiler settings are for i386.
# 	We also do believe older machines are already either dead 
#	or at the museum.)
supported |= strcmp("i86", systemtype([1,3,4]));

file = fopen('src/configure.in','wt');
fprintf(file,'FENV_OPTS = ');
if (supported)
	fprintf(file,'-DX86_PROCESSOR');
end
fprintf(file,'\n');
fclose(file);

endfunction
