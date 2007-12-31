#!/usr/bin/sh

VER_OCTAVE=2.9.17-1

# This script builds OCTAVE
( cd octave && ./build-${VER_OCTAVE}.sh all );

