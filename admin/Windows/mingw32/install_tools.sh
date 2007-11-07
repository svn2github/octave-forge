#!/usr/bin/sh

VER_TOOLS=1

source pkg_version.sh

# This script installs the tools
( cd tools && ./build-${VER_TOOLS}.sh install_pkg );

