#! /usr/bin/sh

# Name of package
PKG=pcre
# Version of Package
VER=7.8
# Release of (this patched) package
REL=3
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}.tar.bz2
TAR_TYPE=j
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="http://downloads.sourceforge.net/pcre/pcre-7.8.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=""

# Additional DIFF Flags for generating diff file
#DIFF_FLAGS="-x *.def"

# header files to be installed
INSTALL_HEADERS="pcre.h"
INSTALL_HEADERS2=""
# INCLUDE_DIR=include/pcre

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC="${CC} $LIBGCCLDFLAGS" \
     CXX="${CXX} $LIBGCCLDFLAGS" \
     F77="${F77} $LIBGCCLDFLAGS" \
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     LDFLAGS="${LDFLAGS}" \
     --prefix=${PREFIX} \
     --enable-shared --enable-static \
     --enable-utf8 \
     --enable-unicode-properties \
     --enable-newline-is-any \
     --enable-pcregrep-libz \
     --disable-cpp
   )
}

build_post()
{
   ${STRIP} ${STRIP_FLAGS} ${BUILDDIR}/.libs/pcre-7.dll
}

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/pcre-7.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libpcre.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libpcre.a ${STATICLIBRARY_PATH}
   for a in ${INSTALL_HEADERS}; do ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${INCLUDE_PATH}; done
   for a in ${INSTALL_HEADERS2}; do ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}; done
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pcre-config ${BINARY_PATH}
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/LICENCE ${LICENSE_PATH}/${PKG}
   install_post;
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/libpcre-7.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libpcre.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libpcre.a
   for a in ${INSTALL_HEADERS}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
   for a in ${INSTALL_HEADERS2}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/pcre-config
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
