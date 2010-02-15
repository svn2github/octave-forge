#! /usr/bin/sh

# Name of package
PKG=pixman
# Version of Package
VER=0.17.2
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
URL="http://www.cairographics.org/releases/pixman-$VER.tar.gz"

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

# Herader files to install
HEADERS_INSTALL="pixman/pixman.h"
HEADERSBUILD_INSTALL="pixman/pixman-version.h"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL="pixman-1.pc"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

conf()
{
   conf_pre;
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC="$CC $LIBGCCLDFLAGS" \
     CXX="$CXX $LIBGCCLDFLAGS" \
     F77="$F77 $LIBGCCLDFLAGS" \
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
     --enable-shared
   )
   touch ${BUILDDIR}/have_configure
   modify_libtool_nolibprefix ${BUILDDIR}/libtool
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pixman/.libs/pixman-1-0.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pixman/.libs/libpixman-1.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pixman/.libs/libpixman-1.a ${STATICLIB_PATH}
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}/`basename $a`
   done
   
   for a in $HEADERSBUILD_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${INCLUDE_PATH}/`basename $a`
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/pixman-1-0.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libpixman-1.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libpixman-1.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL $HEADERSBUILD_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/`basename $a`
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   
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
