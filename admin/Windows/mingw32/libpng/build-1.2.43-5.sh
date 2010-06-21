#! /usr/bin/sh

# Name of package
PKG=libpng
# Version of Package
VER=1.2.43
# Release of (this patched) package
REL=5
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.xz
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-$VER.tar.xz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=makefile.mingw
# Any extra flags to pass make to
MAKE_XTRA=

# Header files to install
HEADERS_INSTALL="png.h pngconf.h"
HEADERS_BUILD_INSTALL=""

# install subdirectory below $PREFIX/$INC_DIR (if any)
INC_SUBDIR=

# License file(s) to install
LICENSE_INSTALL="LICENSE"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL="libpng.pc"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc45_common.sh

# Directory the lib is built in (set this *after* loading gcc45_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

# Set *after* sourceing gcc45_common.sh, since we require $PREFIX to be set
MAKE_XTRA="prefix=$PREFIX"

conf()
{
   conf_pre;
   substvars ${SRCDIR}/scripts/${MAKEFILE} ${BUILDDIR}/${MAKEFILE}
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/png12.dll    $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libpng.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libpng.a     $PREFIX/$STATICLIB_DIR
   
   install_common;
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/png12.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libpng.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libpng.a
   
   uninstall_common;
   uninstall_post;
}

check()
{
   check_pre;
   ( cd ${BUILDDIR} && make_common test )
   check_post;
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
