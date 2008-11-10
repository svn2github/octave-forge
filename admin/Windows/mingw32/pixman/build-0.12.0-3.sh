#! /usr/bin/sh

# Name of package
PKG=pixman
# Version of Package
VER=0.12.0
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
URL="http://www.cairographics.org/releases/pixman-0.12.0.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
# MAKEFILE=win32/Makefile.gcc

# header files to be installed
#INSTALL_HEADERS="tiff.h tiffvers.h tiffio.h"
#INSTALL_HEADERS_BUILD="tiffconf.h"
#INCLUDE_DIR=

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
     --enable-shared \
     --disable-sse2
     )
}

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pixman/.libs/libpixman-1-0.dll      ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pixman/.libs/libpixman-1.dll.a    ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pixman/.libs/libpixman-1.a        ${STATICLIBRARY_PATH}
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/pixman/pixman.h ${INCLUDE_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pixman/pixman-version.h ${INCLUDE_PATH}
   
#   mkdir -vp ${LICENSE_PATH}/${PKG}
#   ${CP} ${CP_FLAGS} ${SRCDIR}/LICENSE ${LICENSE_PATH}/${PKG}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pixman-1.pc ${PKGCONFIGDATA_PATH}
   install_post
}

uninstall()
{
   uninstall_pre;
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/libpixman-1-0.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libpixman-1.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libpixman-1.a
   
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/pixman.h
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/pixman-version.h
   
   ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/pixman-1.pc
   rmdir --ignore-fail-on-non-empty ${PKGCONFIGDATA_PATH}
   
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
