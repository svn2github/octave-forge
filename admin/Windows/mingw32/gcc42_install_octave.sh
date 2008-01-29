#! /usr/bin/sh

source gcc42_version.sh

# install OCTAVE into package root
( cd octave && ./build-${VER_OCTAVE}.sh install_pkg )

