#! /usr/bin/sh

# Name of package
PKG=gettext
# Version of Package
VER=0.17
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
URL="http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/gettext-0.17.tar.gz"

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
HEADERS_INSTALL="libintl.h"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x *configure -x config.h.in"

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

# configure does not honor/save the specified preprocessor in CPP
# so we need to specify it manually when calling make
MAKE_XTRA="CPP=$CPP"

conf()
{
   conf_pre;
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC="${CC} $LIBGCCLDFLAGS" \
     CXX="${CXX} $LIBGCCLDFLAGS" \
     F77="${F77} $LIBGCCLDFLAGS" \
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
     --disable-java \
     --disable-native-java \
     --disable-csharp \
     --enable-relocatable \
     --disable-openmp \
     --disable-largefile \
     --enable-static \
     --enable-shared \
     --disable-threads
   )
   touch ${BUILDDIR}/gettext-runtime/have_configure
   modify_libtool_all ${BUILDDIR}/gettext-runtime/libtool
   conf_post;
}

build()
{
   build_pre;
   ( cd ${BUILDDIR}/gettext-runtime && make_common )
   build_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gettext-runtime/intl/.libs/intl.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gettext-runtime/intl/.libs/libintl.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gettext-runtime/intl/.libs/libintl.a ${STATICLIB_PATH}
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/gettext-runtime/intl/$a ${INCLUDE_PATH}/`basename $a`
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/gettext-runtime/COPYING ${LICENSE_PATH}/${PKG}/COPYING.gettext-runtime
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/intl.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libintl.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libintl.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/`basename $a`
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING.gettext-runtime
   
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
