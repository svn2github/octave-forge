#! /usr/bin/sh

# Name of package
PKG=cairo
# Version of Package
VER=1.8.2
# Release of (this patched) package
REL=3
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}.tar.gz
TAR_TYPE=z
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="http://cairographics.org/releases/cairo-1.8.2.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
# MAKEFILE=win32/Makefile.gcc

# header files to be installed
HEADERS="cairo.h cairo-deprecated.h cairo-pdf.h cairo-ps.h cairo-svg.h cairo-version.h cairo-win32.h cairo-ft.h"
HEADERS2="cairo-features.h"
INCLUDE_DIR=include/cairo

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

echo ${PREFIX}

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC=${CC} \
     CXX=${CXX} \
     F77=${F77} \
     CPP=${CPP} \
     LDFLAGS="${LDFLAGS}" \
     CPPFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS}" \
     CFLAGS="$CFLAGS" \
     CXXFLAGS="$CXXFLAGS" \
     LIBS="" \
     --prefix="${PREFIX}" \
     --enable-shared  \
     png_REQUIRES=libpng \
     --disable-pthread
     )
}

build_pre()
{
   modify_libtool_nolibprefix ${BUILDDIR}/libtool
}

PCFILES="cairo.pc cairo-ft.pc cairo-pdf.pc cairo-png.pc cairo-ps.pc cairo-svg.pc cairo-win32.pc cairo-win32-font.pc"

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/cairo-2.dll    ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libcairo.dll.a    ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libcairo.a        ${STATICLIBRARY_PATH}
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING-LGPL-2.1 ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING-MPL-1.1 ${LICENSE_PATH}/${PKG}
   
   for a in $HEADERS; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/src/$a ${INCLUDE_PATH}
   done
   
   for a in $HEADERS2; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/src/$a ${INCLUDE_PATH}
   done
   
   for a in $PCFILES; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/src/$a ${PKGCONFIGDATA_PATH}
   done
   
   
   install_post
}

  
uninstall()
{
   uninstall_pre;
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/cairo-2.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libcairo.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libcairo.a
   
   for a in $HEADERS; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   for a in $HEADERS2; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   for a in $PCFILES; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING-LGPL-2.1
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING-MPL-1.1
   
   uninstall_post;
}
   
all()
{
   download
   unpack
   applypatch
   mkdirs
   conf
   build
   install
}

main $*
