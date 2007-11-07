#!/usr/bin/sh

VER_OCTAVE=2.9.12-2

# This script builds OCTAVE
( cd octave && ./build-${VER_OCTAVE}.sh all );

