#! /usr/bin/sh

# Name of package
PKG=fftw
# Version of Package
VER=3.2.2
# Release of (this patched) package
REL=5
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.gz
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://www.fftw.org/fftw-3.2.2.tar.gz"

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
HEADERS_INSTALL="fftw3.h"

# License file(s) to install
LICENSE_INSTALL="COPYING COPYRIGHT"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL="fftw3.pc fftw3f.pc"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc45_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR_DOUBLE=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}_double"
BUILDDIR_SINGLE=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}_single"

# == override resp. specify build actions ==

mkdirs()
{
   for a in $BUILDDIR_DOUBLE $BUILDDIR_SINGLE; do
      if test -d $a; then
         echo removing $a ...
         rm -rf $a
      fi
      mkdir -vp $a
   done
}

conf()
{
   conf_general;
   conf_single;
}

conf_post()
{
   modify_libtool_all $BUILDDIR/libtool
}

conf_general()
{
   CONFIGURE_XTRA_ARGS="\
   --enable-portable-binary \
   --enable-static \
   --enable-shared"
   BUILDDIR=$BUILDDIR_DOUBLE
   
   conf_pre;
   conf_common;
   conf_post;
}

conf_single()
{
   CONFIGURE_XTRA_ARGS="\
   --enable-portable-binary \
   --enable-single \
   --enable-shared \
   --enable-static"
   BUILDDIR=$BUILDDIR_SINGLE
   
   conf_pre;
   conf_common;
   conf_post;
}

build()
{
   build_pre;
   
   for a in $BUILDDIR_DOUBLE $BUILDDIR_SINGLE; do
      ( cd $a && make_common )
   done
   
   build_post;
}

# Make check: all tests pass 17-may-2010 using mingw32-gcc-4.5.0 (mingw)

check()
{
   check_pre;
   
   for a in $BUILDDIR_DOUBLE $BUILDDIR_SINGLE; do
      ( cd $a && make_common check )
   done
   
   check_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} $BUILDDIR_DOUBLE/.libs/fftw3.dll      $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} $BUILDDIR_DOUBLE/.libs/libfftw3.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} $BUILDDIR_DOUBLE/.libs/libfftw3.a     $PREFIX/$STATICLIB_DIR
   
   ${CP} ${CP_FLAGS} $BUILDDIR_SINGLE/.libs/fftw3f.dll      $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} $BUILDDIR_SINGLE/.libs/libfftw3f.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} $BUILDDIR_SINGLE/.libs/libfftw3f.a     $PREFIX/$STATICLIB_DIR
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} $BUILDDIR_DOUBLE/$a $PREFIX/$PKGCONFIG_DIR
      ${CP} ${CP_FLAGS} $BUILDDIR_SINGLE/$a $PREFIX/$PKGCONFIG_DIR
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/api/$a $PREFIX/$INC_DIR
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
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/fftw3.dll
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/fftw3f.dll
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/fftw3.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libfftw3.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libfftw3.a
   
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/fftw3f.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libfftw3f.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libfftw3f.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} $PREFIX/$INC_DIR/$a
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} $PREFIX/$PKGCONFIG_DIR/$a
   done
   
   # Uninstall license file
   for a in $LICENSE_INSTALL; do
      ${RM} ${RM_FLAGS} $PREFIX/$LIC_DIR/$PKG/$a
   done
   
   uninstall_post;
}

pkg_pre()
{
   # No extra patch required
   PATCHFILE=""
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
