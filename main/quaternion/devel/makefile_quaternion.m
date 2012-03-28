## ==============================================================================
## Developer Makefile for OCT-files
## ==============================================================================
## USAGE: * fetch quaternion_oo from Octave-Forge by svn
##        * add quaternion_oo/inst, quaternion_oo/src and quaternion_oo/devel
##          to your Octave path
##        * run makefile_quaternion
## ==============================================================================

homedir = pwd ();
develdir = fileparts (which ("makefile_quaternion"));
srcdir = [develdir, "/../src"];
cd (srcdir);

mkoctfile is_real_array.cc

system ("rm *.o");
cd (homedir);