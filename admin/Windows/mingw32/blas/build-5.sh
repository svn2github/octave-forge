#! /usr/bin/sh

# Name of package
PKG=blas
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

# Header files to install
HEADERS_INSTALL=

# License file(s) to install
LICENSE_INSTALL=

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x *.def"

# load common functions
source ../gcc45_common.sh

# Directory the lib is built in (set this *after* loading gcc45_common.sh)
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
   ${CP} ${CP_FLAGS} ${BUILDDIR}/blas.dll      $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libblas.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libblas.a     $PREFIX/$STATICLIB_DIR
   
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
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/blas.dll
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/blas.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libblas.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libblas.a
   
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
