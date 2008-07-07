#! /usr/bin/sh

# Name of package
PKG=cpufeature
# Version of Package
VER=1.0.0
# Release of (this patched) package
REL=2
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}.tar.bz2
TAR_TYPE=j
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL=""

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
#MAKEFILE=win32/Makefile.gcc

source ../../gcc42_common.sh
source ../../gcc42_pkg_version.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

conf()
{
   substvars ${SRCDIR}/makefile.in ${BUILDDIR}/makefile
}

install()
{
   echo not required
}

install_pkg()
{
   cp -uvp ${BUILDDIR}/cpufeature.exe ${PACKAGE_ROOT}/bin
}

srcpkg()
{
   "${SEVENZIP}" ${SEVENZIP_FLAGS} ${SRCPKG_PATH}/${PKG}-${VER}-${REL}-src.7z ${SRCDIR}/cpufeature.c ${SRCDIR}/cpuid.s ${SRCDIR}/makefile.in build-${VER}-${REL}.sh 
}

all() {
  #download
  #unpack
  #applypatch
  mkdirs
  conf
  build
  install
}

main $*
