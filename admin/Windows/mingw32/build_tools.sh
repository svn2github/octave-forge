#!/usr/bin/sh

VER_TOOLS=1

# This script builds the tools
( cd tools && ./build-${VER_TOOLS}.sh all );

