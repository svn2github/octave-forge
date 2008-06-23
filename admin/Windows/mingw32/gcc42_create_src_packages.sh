#! /usr/bin/sh


# get the SRCPKG_PATH definition
source gcc42_pkg_version.sh

SRCPKG_PATH=`pwd`/srcpkg/${PKG_VER}-${PKG_REL}
if ! [ -e ${SRCPKG_PATH} ]; then mkdir -v ${SRCPKG_PATH}; fi
export SRCPKG_PATH

# and simply call the individual build scripts for dependencies
./gcc42_build_deps.sh srcpkg

# and simply call the individual build scripts for octave itself
./gcc42_build_tools.sh srcpkg

# and simply call the individual build scripts for the tools
./gcc42_build_octave.sh srcpkg
