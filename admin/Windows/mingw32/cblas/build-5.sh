#! /usr/bin/sh

# Name of package
PKG=cblas
# Version of Package
VER=
# Release of (this patched) package
REL=5
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

# Header files to install
HEADERS_INSTALL=

# License file(s) to install
LICENSE_INSTALL="README"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc45_common.sh

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
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/cblas.dll      $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/libcblas.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/libcblas.a     $PREFIX/$STATICLIB_DIR
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/$a $PREFIX/$INC_DIR
   done
   
   # Install license file
   for a in $LICENSE_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/$a $PREFIX/$LIC_DIR/$PKG
   done
   
   install_post;
}

install_strip()
{
   install;
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/cblas.dll
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/cblas.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libcblas.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libcblas.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} $PREFIX/$INC_DIR/$a
   done
   
   # Uninstall license file
   for a in $LICENSE_INSTALL; do
      ${RM} ${RM_FLAGS} $PREFIX/$LIC_DIR/$PKG/$a
   done
   
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
