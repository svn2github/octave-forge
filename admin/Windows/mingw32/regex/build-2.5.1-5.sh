#! /usr/bin/sh

# Name of package
PKG=mingw-libgnurx
# Version of Package
VER=2.5.1
# Release of (this patched) package
REL=5
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}-src.tar.gz
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://downloads.sourceforge.net/mingw/mingw-libgnurx-2.5.1-src.tar.gz"

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
HEADERS_INSTALL="regex.h"
HEADERS_BUILD_INSTALL=

# install subdirectory below $PREFIX/$INC_DIR (if any)
INC_SUBDIR=

# License file(s) to install
LICENSE_INSTALL="README COPYING.LIB"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc45_common.sh

# Directory the lib is built in (set this *after* loading gcc45_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==


install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gnurx.dll      $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libregex.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libregex.a     $PREFIX/$STATICLIB_DIR
   
   install_common;
   install_post;
}

install_strip()
{
   install;
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/gnurx.dll
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/gnurx.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libregex.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libregex.a
   
   uninstall_common;
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
