#! /usr/bin/sh

# Version of Octave we are building & packaging
if [ -e gcc42_version.sh ];       then source gcc42_version.sh; fi
if [ -e ../gcc42_version.sh ];    then source ../gcc42_version.sh; fi
if [ -e ../../gcc42_version.sh ]; then source ../../gcc42_version.sh; fi

PKG_VER=`echo ${VER_OCTAVE} | sed -e "s%\([^-]*\)-\([^-]*\)%\1%"`
PKG_REL=`echo ${VER_OCTAVE} | sed -e "s%\([^-]*\)-\([^-]*\)%\2%"`

# directory the package is installed to
PACKAGE_ROOT=/opt/octave_mingw32_gcc42/${PKG_VER}-${PKG_REL}
