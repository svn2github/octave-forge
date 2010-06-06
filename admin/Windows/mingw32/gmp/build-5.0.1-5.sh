#! /usr/bin/sh

# Name of package
PKG=gmp
# Version of Package
VER=5.0.1
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
URL="http://gd.tuwien.ac.at/gnu/gnusrc/gmp/gmp-$VER.tar.bz2"

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
HEADERS_BUILD_INSTALL="gmp.h"

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

# MIND that GMP requires a relative path for SRCDIR because configure
# hard-codes paths into test scripts and msys paths do not work
# with mingw32 gcc...
 
conf_pre()
{
   # GMP cannot build shared and static library at the same time
    CONFIGURE_XTRA_ARGS="\
      --enable-shared \
      --disable-static \
      --enable-fat"
}

conf_post()
{
   modify_libtool_all ${BUILDDIR}/libtool
}

# Running "make check" will produce all-failed tests if built with 
# --enable-shared. This is due to strange method of creating executable 
# within libtool.
# However, when building with --enable-static, make check reports ALL tests 
# as passed.
# Tested using mingw mingw32-gcc-4.5.0-dw2, 06-jun-2010 with default gcc flags

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/gmp.dll    $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libgmp.dll.a $PREFIX/$LIB_DIR
   
   install_common;
   install_post;
}

install_strip()
{
   install
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/gmp.dll
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/gmp.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libgmp.dll.a
   
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
