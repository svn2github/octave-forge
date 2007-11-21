#! /usr/bin/sh

# Name of package
PKG=less
# Version of Package
VER=406
# Release of (this patched) package
REL=1
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}.tar.gz
TAR_TYPE=z
# Name of Patch file
PATCHFILE=${FULLPKG}.diff

# URL of source code file
URL="http://www.greenwoodsoftware.com/less/less-406.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig
# Directory the lib is built in
BUILDDIR=${SRCDIR}

# Make file to use
MAKEFILE="Makefile.mingw32"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x defines.h"

# header files to be installed
INSTALL_HEADERS=""

source ../common.sh


install()
{
   ${CP} ${CP_FLAGS} ${BUILDDIR}/less.exe ${BINARY_PATH}
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/less.exe
}

all()
{
   download
   unpack
   applypatch
   build
   install
}

main $*
