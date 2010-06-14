#! /usr/bin/sh

# Name of package
PKG=fontconfig
# Version of Package
VER=2.8.0
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
URL="http://fontconfig.org/release/fontconfig-$VER.tar.gz"

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
fontconfig/fontconfig.h 
fontconfig/fcfreetype.h"
HEADERS_BUILD_INSTALL=

# install subdirectory below $PREFIX/$INC_DIR (if any)
INC_SUBDIR=fontconfig/

# License file(s) to install
LICENSE_INSTALL="COPYING"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL="fontconfig.pc"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc45_common.sh

# Directory the lib is built in (set this *after* loading gcc45_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

conf_pre()
{
    CONFIGURE_XTRA_ARGS="\
      --with-default-fonts"
}

conf_post()
{
   modify_libtool_all ${BUILDDIR}/libtool
}

build_post()
{
   ( cd ${BUILDDIR} && make_common fonts.conf )
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/fontconfig.dll    $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libfontconfig.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libfontconfig.dll.a $PREFIX/$STATICLIB_DIR
   
   # Install fonts.conf to /etc/fonts
   mkdir -vp $PREFIX/$ETC_DIR/fonts
   ${CP} ${CP_FLAGS} ${BUILDDIR}/fonts.conf $PREFIX/$ETC_DIR/fonts
   
   install_common;
   install_post;
}

install_strip()
{
   install
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/fontconfig.dll
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/fontconfig.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libfontconfig.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libfontconfig.dll.a
   
   # Uninstall /etc/fonts/fonts.conf
   ${RM} ${RM_FLAGS} $PREFIX/$ETC_DIR/fonts/fonts.conf
   rmdir --ignore-fail-on-non-empty $PREFIX/$ETC_DIR/fonts

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
