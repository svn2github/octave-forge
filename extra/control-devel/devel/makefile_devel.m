## ==============================================================================
## Developer Makefile for OCT-files
## ==============================================================================
## USAGE: * fetch control-devel from Octave-Forge by svn
##        * add control-devel/inst, control-devel/src and control-devel/devel
##          to your Octave path (by an .octaverc file)
##        * run makefile_devel
## ==============================================================================

homedir = pwd ();
develdir = fileparts (which ("makefile_devel"));
srcdir = [develdir, "/../src"];
cd (srcdir);

## system ("make realclean");  # recompile slicotlibrary.a
system ("make clean");
system ("make -j1 all");
system ("rm *.o");
system ("rm *.d");

cd (homedir);