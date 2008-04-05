#! /usr/bin/sh

# Name of package
PKG=lapack-lite
# Version of Package
VER=3.1.1
# Release of (this patched) package
REL=2
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}.tgz
TAR_TYPE=z
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="http://www.netlib.org/lapack/lapack-lite-3.1.1.tgz"

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
   mkdir -vp ${BUILDDIR}/SRC
   mkdir -vp ${BUILDDIR}/INSTALL
}

conf()
{
   substvars ${SRCDIR}/make.inc ${BUILDDIR}/make.inc
   ${CP} ${CP_FLAGS} ${SRCDIR}/makefile         ${BUILDDIR}/makefile
   ${CP} ${CP_FLAGS} ${SRCDIR}/INSTALL/makefile ${BUILDDIR}/INSTALL/makefile
   ${CP} ${CP_FLAGS} ${SRCDIR}/SRC/makefile     ${BUILDDIR}/SRC/makefile
}

build() 
{
   ( cd ${BUILDDIR} && make lapacklib shlib )
}

install()
{
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lapack.dll   ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lapack.dll.a ${LIBRARY_PATH}/liblapack.dll.a
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lapack.a     ${STATICLIBRARY_PATH}/liblapack.a
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/lapack.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/liblapack.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/liblapack.a
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
