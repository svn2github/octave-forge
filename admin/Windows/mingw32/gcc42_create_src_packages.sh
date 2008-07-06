#! /usr/bin/sh


# get the SRCPKG_PATH definition
source gcc42_pkg_version.sh
source gcc42_common.sh

SRCPKG_PATH=`pwd`/srcpkg/${PKG_VER}-${PKG_REL}
if ! [ -e ${SRCPKG_PATH} ]; then mkdir -v ${SRCPKG_PATH}; fi
export SRCPKG_PATH

# and simply call the individual build scripts for dependencies
./gcc42_build_deps.sh srcpkg

# and simply call the individual build scripts for octave itself
./gcc42_build_tools.sh srcpkg

# and simply call the individual build scripts for the tools
./gcc42_build_octave.sh srcpkg

# And add our common build scripts also...
BS="copy-if-changed.sh \
gcc42_build_deps.sh \
gcc42_build_tools.sh \
gcc42_build_octave.sh \
gcc42_common.sh \
gcc42_create_package.sh \
gcc42_create_src_packages.sh \
gcc42_install_deps.sh \
gcc42_install_tools.sh \
gcc42_install_octave.sh \
gcc42_pkg_version.sh \
gcc42_version.sh \
octave.nsi"

"${SEVENZIP}" ${SEVENZIP_FLAGS} ${SRCPKG_PATH}/building-scripts.7z $BS