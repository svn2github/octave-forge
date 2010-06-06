#! /usr/bin/sh

# Name of package
PKG=libiconv
# Version of Package
VER=1.13
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
URL="http://gd.tuwien.ac.at/gnu/gnusrc/libiconv/libiconv-$VER.tar.gz"

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
HEADERS_BUILD_INSTALL="
include/iconv.h \
libcharset/include/libcharset.h \
libcharset/include/localcharset.h"

# install subdirectory below $PREFIX/$INC_DIR (if any)
INC_SUBDIR=

# License file(s) to install
LICENSE_INSTALL="COPYING COPYING.lib"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc45_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

conf_pre()
{
    CONFIGURE_XTRA_ARGS="\
      --enable-shared \
      --enable-static \
      --enable-relocatable"
}

conf_post()
{
   modify_libtool_all ${BUILDDIR}/libtool
   modify_libtool_all ${BUILDDIR}/libcharset/libtool
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/.libs/iconv.dll    $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/.libs/libiconv.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/.libs/libiconv.dll.a $PREFIX/$STATICLIB_DIR
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libcharset/lib/.libs/charset.dll    $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libcharset/lib/.libs/libcharset.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libcharset/lib/.libs/libcharset.dll.a $PREFIX/$STATICLIB_DIR
   
   install_common;
   install_post;
}

install_strip()
{
   install
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/intl.dll
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/charset.dll
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/iconv.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libiconv.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libiconv.dll.a
   
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/charset.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libcharset.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libcharset.dll.a
   
   uninstall_common;
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
