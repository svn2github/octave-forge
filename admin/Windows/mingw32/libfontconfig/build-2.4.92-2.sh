#! /usr/bin/sh

# Name of package
PKG=fontconfig
# Version of Package
VER=2.4.92
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
URL="http://fontconfig.org/release/fontconfig-2.4.92.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=""

# Additional DIFF Flags for generating diff file
#DIFF_FLAGS="-x *.def"

# header files to be installed
INSTALL_HEADERS="fontconfig.h"
INCLUDE_DIR="include/fontconfig"

source ../gcc42_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
   export LIBXML2_CFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" 
   export LIBXML2_LIBS="-lxml2" 
#   ( cd ${SRCDIR} && autoconf )
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC=${CC} \
     CXX=${CXX} \
     F77=${F77} \
     CFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CPPFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     LDFLAGS="${LDFLAGS}" \
     --prefix="${PREFIX}" \
     --enable-libxml2 \
     --with-default-fonts
   )
}

install()
{
   install_pre
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/fontconfig.dll      ${BINARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libfontconfig.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libfontconfig.a     ${STATICLIBRARY_PATH}
   for a in ${INSTALL_HEADERS}; do ${CP} ${CP_FLAGS} ${SRCDIR}/fontconfig/$a ${INCLUDE_PATH}; done
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   install_post
}

uninstall()
{
   uninstall_pre;
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/fontconfig.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfontconfig.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libfontconfig.a
   for a in ${INSTALL_HEADERS}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
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
