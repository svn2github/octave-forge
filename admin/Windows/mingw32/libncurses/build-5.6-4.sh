#! /usr/bin/sh

# Name of package
PKG=ncurses
# Version of Package
VER=5.6
# Release of (this patched) package
REL=4
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.gz
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.6.tar.gz"

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

# subdirectory to install heraders to (empty for default)
INCLUDE_DIR=

# Header files to install
HEADERS_INSTALL="term.h curses.h unctrl.h termcap.h"
HEADERS2_INSTALL="ncurses_dll.h"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

MAKE_PARALLEL=""

conf()
{
   conf_pre;
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC=$CC \
     CXX=$CXX \
     F77=$F77 \
     CPP=$CPP \
     AR=$AR \
     RANLIB=$RANLIB \
     RC=$RC \
     STRIP=$STRIP \
     LD=$LD \
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CPPFLAGS="$CPPFLAGS" \
     LDFLAGS="${LDFLAGS}" \
     CXXLIBS="${CXXLIBS}" \
     --prefix=${PREFIX} \
     --without-ada \
     --with-shared
   )
   touch ${BUILDDIR}/have_configure
   
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/ncurses-5.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/libncurses.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/libncurses.a ${STATICLIB_PATH}
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/include/$a ${INCLUDE_PATH}
   done
   ${CP} ${CP_FLAGS} ${BUILDDIR}/include/curses.h ${INCLUDE_PATH}/ncurses.h
   
   for a in $HEADERS2_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/include/$a ${INCLUDE_PATH}
   done
   
   ( cd ${BUILDDIR}/misc && make install )
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/ncurses5-config

   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/AUTHORS ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/ncurses-5.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libncurses.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libncurses.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL $HEADERS2_INSTALL ncurses.h; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   ${RM} -rvf ${PREFIX}/share/terminfo
   ${RM} -rvf ${PREFIX}/share/tabset
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/AUTHORS
   
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
