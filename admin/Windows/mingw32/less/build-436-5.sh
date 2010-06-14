#! /usr/bin/sh

# Name of package
PKG=less
# Version of Package
VER=436
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
URL="http://www.greenwoodsoftware.com/less/less-436.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=makefile.mingw32
# Any extra flags to pass make to
MAKE_XTRA=

# Header files to install
HEADERS_INSTALL=
HEADERS_BUILD_INSTALL=

# install subdirectory below $PREFIX/$INC_DIR (if any)
INCLUDE_SUBDIR=

# License file(s) to install
LICENSE_INSTALL="COPYING LICENSE"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

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
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/less.exe $PREFIX/$BIN_DIR
   
   install_common;
   install_post;
}

install_strip()
{
   install;
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/less.exe
}

uninstall()
{
   uninstall_pre;
   
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/less.exe
   
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
