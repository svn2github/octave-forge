#! /usr/bin/sh

# Name of package
PKG=blas
# Version of Package
VER=
# Release of (this patched) package
REL=4
# Name&Version of Package
PKGVER=${PKG}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tgz
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://www.netlib.org/blas/blas.tgz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=Makefile.mingw32
# Any extra flags to pass make to
MAKE_XTRA=

# subdirectory to install heraders to (empty for default)
INCLUDE_DIR=

# Herader files to install
HEADERS_INSTALL=

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x *.def"

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==


conf()
{
   conf_pre;
   substvars ${SRCDIR}/${MAKEFILE} ${BUILDDIR}/${MAKEFILE}
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/blas.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libblas.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libblas.a ${STATICLIB_PATH}
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}
   done
   
   # Install license file
   # ${CP} ${CP_FLAGS} ${SRCDIR}/README ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/blas.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libblas.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libblas.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   # Uninstall license file
   # ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/README
   
   uninstall_post;
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
