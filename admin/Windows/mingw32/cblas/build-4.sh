#! /usr/bin/sh

# Name of package
PKG=cblas
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
URL="http://www.netlib.org/blas/blast-forum/cblas.tgz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=
# Any extra flags to pass make to
MAKE_XTRA=

# subdirectory to install heraders to (empty for default)
INCLUDE_DIR=

# Herader files to install
HEADERS_INSTALL=

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

unpack()
{
   unpack_add_ver;
}

unpack_orig()
{
   unpack_orig_add_ver;
}

mkdirs_post()
{
   mkdir -vp ${BUILDDIR}/src
   mkdir -vp ${BUILDDIR}/lib
}

conf()
{
   conf_pre;
   substvars ${SRCDIR}/makefile ${BUILDDIR}/makefile
   substvars ${SRCDIR}/src/makefile ${BUILDDIR}/src/makefile
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/cblas.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/libcblas.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/libcblas.a ${STATICLIB_PATH}
   
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
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/cblas.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libcblas.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libcblas.a
   
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
