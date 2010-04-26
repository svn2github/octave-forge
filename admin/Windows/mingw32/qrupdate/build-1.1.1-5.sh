#! /usr/bin/sh

# Name of package
PKG=qrupdate
# Version of Package
VER=1.1.1
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
URL="http://downloads.sourceforge.net/qrupdate/qrupdate-1.1.1.tar.gz"

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

# License file(s) to install
LICENSE_INSTALL="COPYING "

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc45_common.sh

# Directory the lib is built in (set this *after* loading gcc45_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

mkdirs_post()
{
   mkdir -vp ${BUILDDIR}/src
   mkdir -vp ${BUILDDIR}/test
}

conf()
{
   conf_pre;
   
   substvars ${SRCDIR}/makefile ${BUILDDIR}/makefile
   substvars ${SRCDIR}/src/makefile ${BUILDDIR}/src/makefile
   substvars ${SRCDIR}/test/makefile ${BUILDDIR}/test/makefile
   
   conf_post;
}

build()
{
   build_pre;
   
   ( cd ${BUILDDIR}/src && make_common lib )
   ( cd ${BUILDDIR}/src && make_common solib )
   
   build_post;
}

# 27-apr-2010 Benjamin Lindner <lindnerb@users.sourceforge.net>
#  using: gfortran (mingw32 gcc 4.5.0)
#  all tests pass
# TOTAL:     PASSED 112     FAILED   0

check()
{
   check_pre;
   ( PATH=$PATH:$PREFIX/$BIN_DIR; cd ${BUILDDIR}/test && make_common )
   check_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/qrupdate.dll      $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libqrupdate.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libqrupdate.a     $PREFIX/$STATICLIB_DIR
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/$a $PREFIX/$INC_DIR
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
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/qrupdate.dll
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/qrupdate.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libqrupdate.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libqrupdate.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} $PREFIX/$INC_DIR/$a
   done
   
   # Uninstall license file
   for a in $LICENSE_INSTALL; do
      ${RM} ${RM_FLAGS} $PREFIX/$LIC_DIR/$PKG/LICENSE
   done
   
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
