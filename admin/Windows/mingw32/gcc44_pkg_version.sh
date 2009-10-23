#! /usr/bin/sh

# Version of Octave we are building & packaging
if [ -e gcc44_version.sh ];       then source gcc44_version.sh; fi
if [ -e ../gcc44_version.sh ];    then source ../gcc44_version.sh; fi
if [ -e ../../gcc44_version.sh ]; then source ../../gcc44_version.sh; fi

PKG_VER=`echo ${VER_OCTAVE} | sed -e "s%\([^-]*\)-\([^-]*\)%\1%"`
PKG_REL=`echo ${VER_OCTAVE} | sed -e "s%\([^-]*\)-\([^-]*\)%\2%"`

# directory the package is installed to
PACKAGE_ROOT=/opt/octmgw32_gcc${GCC_VERSION}${GCC_SYSTEM}/${PKG_VER}-${PKG_REL}
