#! /usr/bin/sh

# Name of package
PKG=zlib
# Version of Package
VER=1.2.5
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
URL="http://zlib.net/zlib-1.2.5.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=win32/Makefile.gcc
# Any extra flags to pass make to
MAKE_XTRA=

# Header files to install
HEADERS_INSTALL="zlib.h zconf.h"
HEADERS_BUILD_INSTALL=

# install subdirectory below $PREFIX/$INC_DIR (if any)
INCLUDE_SUBDIR=

# License file(s) to install
LICENSE_INSTALL="README"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc45_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

mkdirs_post() 
{ 
   # directory makefile is located
   mkdir -p ${BUILDDIR}/win32
}

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
   ${CP} ${CP_FLAGS} ${BUILDDIR}/zlib1.dll  $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libz.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libz.a     $PREFIX/$STATICLIB_DIR
   
   install_common;
   install_post;
}

install_strip()
{
   install;
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/zlib1.dll
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/zlib1.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libz.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libz.a
   
   uninstall_common;
   uninstall_post;
}

check()
{
   check_pre;
   
   ( cd ${BUILDDIR} && make_common test )
   ( cd ${BUILDDIR} && make_common testdll )
   
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
