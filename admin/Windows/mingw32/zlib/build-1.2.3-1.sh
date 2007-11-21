#! /usr/bin/sh

# Name of package
PKG=zlib
# Version of Package
VER=1.2.3
# Release of (this patched) package
REL=1
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}.tar.bz2
TAR_TYPE=j
# Name of Patch file
PATCHFILE=${FULLPKG}.diff

# URL of source code file
URL="http://www.gzip.org/zlib/zlib-1.2.3.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig
# Directory the lib is built in
BUILDDIR=${SRCDIR}

# Make file to use
MAKEFILE=win32/Makefile.gcc

source ../common.sh

check_pre() { MAKEFILE=""; }

echo ${PREFIX}

main $*
