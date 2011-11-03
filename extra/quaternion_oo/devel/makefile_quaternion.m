homedir = pwd ();
develdir = fileparts (which ("makefile_quaternion"));
srcdir = [develdir, "/../src"];
cd (srcdir);

mkoctfile is_real_matrice.cc

system ("rm *.o");
cd (homedir);