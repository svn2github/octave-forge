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

# Make file to use
MAKEFILE=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x *.def"

source ../gcc42_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }
mkdirs_post()
{
   mkdir -vp ${BUILDDIR}/src
   mkdir -vp ${BUILDDIR}/lib
}

conf()
{
   substvars ${SRCDIR}/makefile ${BUILDDIR}/makefile
   substvars ${SRCDIR}/src/makefile ${BUILDDIR}/src/makefile
}

build() 
{
   ( cd ${BUILDDIR} && make alllib )
}

install()
{
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/cblas.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/libcblas.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/libcblas.a ${STATICLIBRARY_PATH}
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/cblas.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libcblas.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libcblas.a
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
