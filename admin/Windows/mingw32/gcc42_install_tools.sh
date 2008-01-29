#!/usr/bin/sh

if [ -z "$1" ]; then ACTION=install_pkg; else ACTION="$*"; fi
echo ACTION = "${ACTION}";

VER_TOOLS=2

# This script installs the tools
( cd tools && ./build-${VER_TOOLS}.sh ${ACTION} );

