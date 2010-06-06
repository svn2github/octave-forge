#! /usr/bin/sh

# Name of package
PKG=libwmf
# Version of Package
VER=0.2.8.4
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
URL="http://downloads.sourceforge.net/wvware/libwmf-$VER.tar.gz"

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
HEADERS_INSTALL="
include/libwmf/api.h \
include/libwmf/color.h \
include/libwmf/defs.h \
include/libwmf/fund.h \
include/libwmf/ipa.h \
include/libwmf/types.h \
include/libwmf/macro.h \
include/libwmf/font.h \
include/libwmf/canvas.h \
include/libwmf/foreign.h \
include/libwmf/eps.h \
include/libwmf/fig.h \
include/libwmf/svg.h \
include/libwmf/gd.h \
include/libwmf/x.h"
HEADERS_BUILD_INSTALL=

# install subdirectory below $PREFIX/$INC_DIR (if any)
INC_SUBDIR=libwmf

# License file(s) to install
LICENSE_INSTALL="COPYING"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=

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
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libwmflite-0-2-7.dll $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libwmflite.dll.a     $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libwmflite.a         $PREFIX/$STATICLIB_DIR
   
   install_common;
   install_post;
}

install_strip()
{
   install;
   $STRIP $SRRIP_FLAGS $PREFIX/$BIN_DIR/libwmflite-0-2-7.dll
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/libwmflite-0-2-7.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libwmflite.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libwmflite.a
   
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
