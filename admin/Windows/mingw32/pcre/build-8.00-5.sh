#! /usr/bin/sh

# Name of package
PKG=pcre
# Version of Package
VER=8.00
# Release of (this patched) package
REL=5
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.bz2
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://downloads.sourceforge.net/pcre/pcre-$VER.tar.bz2"

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
HEADERS_BUILD_INSTALL="pcre.h"

# install subdirectory below $PREFIX/$INC_DIR (if any)
INCLUDE_SUBDIR=

# License file(s) to install
LICENSE_INSTALL="COPYING"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL="libpcre.pc libpcrecpp.pc"

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
     --enable-utf8 \
     --enable-unicode-properties \
     --enable-newline-is-any \
     --enable-pcregrep-libz \
     --disable-cpp"
}

conf_post()
{
   modify_libtool_all ${BUILDDIR}/libtool
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/pcre.dll      $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libpcre.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libpcre.a     $PREFIX/$STATICLIB_DIR
   
   # Install configure script
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pcre-config $PREFIX/$BIN_DIR
   
   install_common;
   install_post;
}

install_strip()
{
   install;
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/pcre.dll
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/pcre.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libpcre.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libpcre.a
   
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/pcre-config
   
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
