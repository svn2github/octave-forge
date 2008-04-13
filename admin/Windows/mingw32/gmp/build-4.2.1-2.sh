#! /usr/bin/sh

# Name of package
PKG=gmp
# Version of Package
VER=4.2.1
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
URL="http://ftp.sunet.se/pub/gnu/gmp/gmp-4.2.1.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd -W | sed -e 's+\([a-z]\):/+/\1/+'`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=""

# Additional DIFF Flags for generating diff file
#DIFF_FLAGS="-x *.def"

# header files to be installed
INSTALL_HEADERS=""

source ../gcc42_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=../${SRCDIR} \
     CC=${CC} \
     CXX=${CXX} \
     F77=${F77} \
     CFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     LDFLAGS="${LDFLAGS}" \
     --prefix="${PREFIX}" \
     --disable-static \
     --enable-shared
   )
   # GMP cannot build static and dynamic library simultaneously!
}

install()
{
   install_pre;
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/gmp.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libgmp.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gmp.h ${INCLUDE_PATH}
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING     ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING.lib ${LICENSE_PATH}/${PKG}
   
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/gmp.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libgmp.dll.a
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/gmp.h
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
