#!/usr/bin/sh

VER_TOOLS=2

# This script builds the tools
( cd tools && ./build-${VER_TOOLS}.sh all );

