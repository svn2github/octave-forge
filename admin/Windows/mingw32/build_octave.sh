#!/usr/bin/sh

if [ -z "$1" ]; then ACTION=all; else ACTION="$*"; fi
echo ACTION = "${ACTION}";

VER_OCTAVE=2.9.17-1

# This script builds OCTAVE
( cd octave && ./build-${VER_OCTAVE}.sh ${ACTION} );

