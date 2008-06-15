#! /usr/bin/sh

# Name of package
PKG=expat
# Version of Package
VER=2.0.1
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
URL="http://www.gzip.org/zlib/zlib-1.2.3.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=""
# header files to be installed
INSTALL_HEADERS="expat.h expat_external.h"

source ../gcc42_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

echo ${PREFIX}

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
  ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure --srcdir=../${SRCDIR} \
    CC=${CC} \
    CXX=${CXX} \
    F77=${F77} \
    CPPFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    --enable-static \
    --enable-shared \
    --prefix=${PREFIX}
  )
}

install()
{
   install_pre;
   
   mkdir -v ${LICENSE_PATH}/${PKG}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/expat.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libexpat.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libexpat.a ${STATICLIBRARY_PATH}
   
   for a in ${INSTALL_HEADERS}; do ${CP} ${CP_FLAGS} ${SRCDIR}/lib/$a ${INCLUDE_PATH}; done
   
   # install license information
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/expat.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libexpat.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libexpat.a
   
   for a in ${INSTALL_HEADERS}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
   
   ${RM} ${RM_FLAGS} -r ${LICENSE_PATH}/${PKG}
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
