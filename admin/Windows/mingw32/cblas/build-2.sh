#! /usr/bin/sh

# Name of package
PKG=cblas
# Version of Package
VER=
# Release of (this patched) package
REL=2
# Name&Version of Package
PKGVER=${PKG}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}.tgz
TAR_TYPE=z
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="http://www.netlib.org/blas/blast-forum/cblas.tgz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig
# Directory the lib is built in
BUILDDIR=${SRCDIR}

# Make file to use
MAKEFILE=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x *.def"

source ../gcc42_common.sh

build() 
{
   ( cd ${BUILDDIR} && make alllib )
}

install()
{
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/MINGW32/cblas.dll ${BINARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/MINGW32/libcblas.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/MINGW32/libcblas.a ${STATICLIBRARY_PATH}
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/cblas.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libcblas.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libcblas.a
}

all() {
  download
  unpack
  applypatch
  build
  install
}

main $*
