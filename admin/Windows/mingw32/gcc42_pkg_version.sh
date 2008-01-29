#! /usr/bin/sh

# Version of Octave we are building & packaging
source gcc42_version.sh

PKG_VER=`echo ${VER_OCTAVE} | sed -e "s%\([^-]*\)-\([^-]*\)%\1%"`
PKG_REL=`echo ${VER_OCTAVE} | sed -e "s%\([^-]*\)-\([^-]*\)%\2%"`

# directory the package is installed to
PACKAGE_ROOT=/opt/octave_mingw32_gcc42/${PKG_VER}-${PKG_REL}
