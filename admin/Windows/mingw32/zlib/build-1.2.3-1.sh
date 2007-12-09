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

# Make file to use
MAKEFILE=win32/Makefile.gcc

source ../common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

check_pre() { MAKEFILE=""; }

echo ${PREFIX}

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

mkdirs_post() 
{ 
   mkdir -p ${BUILDDIR}/win32
}

conf()
{
   substvars ${SRCDIR}/${MAKEFILE} ${BUILDDIR}/${MAKEFILE}
}

all() {
  download
  unpack
  applypatch
  mkdirs
  conf
  build
  install
}

main $*
