This is a short description about what can be found in this directory
and how it can be used. If you expect to build an Octave.app release
then this is done in two steps:

1) For every Octave.app that is created also a 'solvedeps' file is
   created that further contains the Octave version number, eg.

   <OctaveForgeSVN>/admin/MacOSX/solvedeps/solvedeps-3.0.0.sh

   can be used to solve all dependencies that are needed for building
   an Octave.app release 3.0.0. This shell-script downloads, patches
   (if necessary), compiles and installs (in a new created directory
   within /tmp - but that location can also be modified in the script)
   all libraries needed and finally builds Octave.

   A 'solvedeps' script must be called with two input arguments where
   the first input argument specifies the library or package that has
   to be installed (eg. '--f2c or '--readline' or '--all' to build all
   dependencies and Octave) and the second input argument specifies
   the architecture (either '--ppc' or '--i386')

   Note: The 'solvedeps' shell-scripts are not very nice, there have
   been added some comments to not forget the one or the other thing
   about something, but as long as I am the only user of these scripts
   right now I don't see any need to make them better or clearer. If
   you have any questions about them then I'm here to answer ;)

2) Collecting files, building the Octave.app and packing the *.dmg is
   done with the file

   <OctaveForgeSVN>/admin/MacOSX/createapp/makeoctaveapp.sh

   It collects the files from /tmp, builds the *.app and finally packs
   another *.dmg image. It is called without any input argument but
   some adjustments have to be done at the toplevel of this file.
