#! /usr/bin/sh

# Name of package
PKG=tiff
# Version of Package
VER=3.8.2
# Release of (this patched) package
REL=2
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
URL="ftp://ftp.remotesensing.org/pub/libtiff/tiff-3.8.2.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
# MAKEFILE=win32/Makefile.gcc

# header files to be installed
INSTALL_HEADERS="tiff.h tiffvers.h tiffio.h"
INSTALL_HEADERS_BUILD="tiffconf.h"
INCLUDE_DIR=

source ../gcc42_common.sh

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
     LDFLAGS="${LDFLAGS}" \
     CPPFLAGS="${GCC_ARCH_FLAGS}" \
     CFLAGS="${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="${GCC_OPT_FLAGS} -Wall" \
     --prefix="${PREFIX}"
     )
}

install()
{
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libtiff/libtiff.dll      ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libtiff/libtiff.dll.a    ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libtiff/.libs/libtiff.a  ${STATICLIBRARY_PATH}

   for a in ${INSTALL_HEADERS};       do ${CP} ${CP_FLAGS} ${SRCDIR}/libtiff/$a ${INCLUDE_PATH}; done
   for a in ${INSTALL_HEADERS_BUILD}; do ${CP} ${CP_FLAGS} ${BUILDDIR}/libtiff/$a ${INCLUDE_PATH}; done
}
   
uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/libtiff.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libtiff.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libtiff.a
   for a in ${INSTALL_HEADERS};       do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
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
