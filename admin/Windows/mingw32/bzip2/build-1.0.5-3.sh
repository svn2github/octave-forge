#! /usr/bin/sh

# Name of package
PKG=bzip2
# Version of Package
VER=1.0.5
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
URL="http://www.bzip.org/1.0.5/bzip2-1.0.5.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=Makefile

# Header files to install from source directory
HEADERS_SRC="bzlib.h"

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

conf()
{
   substvars ${SRCDIR}/${MAKEFILE} ${BUILDDIR}/${MAKEFILE}
}

build()
{
   ( cd ${BUILDDIR} && make ${MAKE_FLAGS} -f ${MAKEFILE} all \
     CFLAGS="${CFLAGS} ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS}" \
     CPPFLAGS="${CPPFLAGS}" \
     CXXFLAGS="${CXXFLAGS}" \
     LDFLAGS="${LDFLAGS}" )
}

#check()
#{
#   ( cd ${BUILDDIR} && make -f ${MAKEFILE} test )
#}

install()
{
   install_pre;
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/bzip2.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libbz2.a ${STATICLIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libbz2.dll.a ${LIBRARY_PATH}
   
   for a in ${HEADERS_SRC}; do ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}; done

   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/LICENSE ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/zlib1.dll
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libz.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libz.dll.a
   
   for a in ${HEADERS_SRC}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
   
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/README

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
