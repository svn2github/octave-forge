#! /usr/bin/sh

VER_OCTAVE=2.9.17-2

# install OCTAVE into package root
( cd octave && ./build-${VER_OCTAVE}.sh install_pkg )

