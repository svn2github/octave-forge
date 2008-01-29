#!/usr/bin/sh

if [ -z "$1" ]; then ACTION=all; else ACTION="$*"; fi
echo ACTION = "${ACTION}";

source gcc42_version.sh

# This script builds OCTAVE
( cd octave && ./build-${VER_OCTAVE}.sh ${ACTION} );

