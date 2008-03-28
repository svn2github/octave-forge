#! /usr/bin/sh

# Name of package
PKG=libxml2
# Version of Package
VER=2.6.30
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
URL=""

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
INSTALL_HEADERS=""
INCLUDE_DIR=include/libxml

source ../gcc42_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

check_pre() { MAKEFILE=""; }

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     CC=${CC} \
     CXX=${CXX} \
     F77=${F77} \
     CFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CPPFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     LDFLAGS="${LDFLAGS}" \
     --prefix="${PREFIX}" \
     --enable-static \
     --enable-shared
   )
}

install()
{
   install_pre
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/xml2.dll      ${BINARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libxml2.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libxml2.a     ${STATICLIBRARY_PATH}

   ${CP} ${CP_FLAGS} ${SRCDIR}/include/libxml/*.h            ${INCLUDE_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/include/libxml/xmlversion.h ${INCLUDE_PATH}

   install_post
}

uninstall()
{
   uninstall_pre;
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/xml2.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libxml2.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libxml2.a
   for a in ${INSTALL_HEADERS}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/xmlversion.h
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
