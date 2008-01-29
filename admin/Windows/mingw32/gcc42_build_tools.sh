#!/usr/bin/sh

if [ -z "$1" ]; then ACTION=all; else ACTION="$*"; fi
echo ACTION = "${ACTION}";

VER_TOOLS=2

# This script builds the tools
( cd tools && ./build-${VER_TOOLS}.sh ${ACTION} );

