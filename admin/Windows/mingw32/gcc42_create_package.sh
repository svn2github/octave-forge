#!/usr/bin/sh

# This packages OCTAVE MINGW32

source gcc42_pkg_version.sh
source gcc42_common.sh

# Name of the package we're building
PKG=octave-${PKG_VER}-${PKG_REL}_i686-pc-mingw32_gcc${GCC_VER}${GCC_SYS}
# Version of the package
#VER=${PKG_VER}
# Release No
#REL=${PKG_REL}
# URL to source code
URL=

# ---------------------------
# The directory this script is located
# Make sure that we have a MSYS patch starting with a drive letter!
TOPDIR=`pwd -W | sed -e 's+^\([a-zA-z]\):/+/\1/+'`
# Name of the source package
PKGNAME=${PKG}
# Full package name including revision
FULLPKG=${PKGNAME}
# Name of the source code package
#SRCPKG=${PKGNAME}
# Name of the patch file
#PATCHFILE=${FULLPKG}.diff
# Name of the source code file
#SRCFILE=${PKGNAME}.tar.bz2
# Directory where the source code is located
#SRCDIR=${TOPDIR}/${PKGNAME}
PKGFILE=${FULLPKG}

SRCES="${PACKAGE_ROOT}/bin \
${PACKAGE_ROOT}/doc \
${PACKAGE_ROOT}/include \
${PACKAGE_ROOT}/info \
${PACKAGE_ROOT}/lib \
${PACKAGE_ROOT}/libexec \
${PACKAGE_ROOT}/man \
${PACKAGE_ROOT}/share \
${PACKAGE_ROOT}/mingw32 \
${PACKAGE_ROOT}/msys \
${PACKAGE_ROOT}/tools \
${PACKAGE_ROOT}/license"

"${SEVENZIP}" $SEVENZIP_FLAGS ${TOPDIR}/${PKGFILE}.7z $SRCES 


DIRS=`ls -1 ${PACKAGE_ROOT}/ATLAS | sed -ne "/ARCH_\([A-Za-z0-9]\)/p"`

for a in $DIRS; do
   SRCES="${PACKAGE_ROOT}/ATLAS/$a/bin \
   ${PACKAGE_ROOT}/ATLAS/$a/lib \
   ${PACKAGE_ROOT}/ATLAS/$a/staticlib"

   "${SEVENZIP}" $SEVENZIP_FLAGS ATLAS_$a.7z $SRCES
done
