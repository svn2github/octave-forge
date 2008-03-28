#! /usr/bin/sh

# Name of package
PKG=freetype
# Version of Package
VER=2.3.5
# Release of (this patched) package
REL=2
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
URL="http://downloads.sourceforge.net/freetype/freetype-2.3.5.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=""

# header files to be installed
INSTALL_HEADERS="ft2build.h"
INCLUDE_DIR=""

source ../gcc42_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     CC=${CC} \
     CXX=${CXX} \
     F77=${F77} \
     CFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     LDFLAGS="${LDFLAGS}" \
     --prefix="${PREFIX}"
   )
}

install_pre()
{
   mkdir -v ${INCLUDE_PATH}/freetype
}

install()
{
   install_pre
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/freetype-6.dll    ${BINARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libfreetype.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libfreetype.a     ${STATICLIBRARY_PATH}

   for a in ${INSTALL_HEADERS}; do ${CP} ${CP_FLAGS} ${SRCDIR}/include/$a ${INCLUDE_PATH}; done
   cp ${CP_FLAGS} -r ${SRCDIR}/include/freetype       ${INCLUDE_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/{ftconfig.h,ftmodule.h} ${INCLUDE_PATH}/freetype/config

   ${CP} ${CP_FLAGS} ${BUILDDIR}/freetype-config         ${BINARY_PATH}
   
   install_post
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/freetype-6.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfreetype.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libfreetype.a
   for a in ${INSTALL_HEADERS}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
   ${RM} ${RM_FLAGS} -r ${INCLUDE_PATH}/freetype
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/freetype-config
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
