#! /usr/bin/sh

# Name of package
PKG=curl
# Version of Package
VER=7.17.1
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
URL="http://curl.haxx.se/download/curl-7.17.1.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
#TOPDIR=`pwd -W | sed -e 's+\([a-z]\):/+/\1/+'`
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE="Makefile.m32"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x ca-bundle.h -x libcurl.res"

# header files to be installed
INSTALL_HEADERS="curl.h curlver.h easy.h mprintf.h multi.h stdcheaders.h types.h"
INCLUDE_DIR=include/curl

source ../gcc42_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }
mkdirs_post()
{
   mkdir -vp ${BUILDDIR}/lib
}

conf()
{
   substvars ${SRCDIR}/lib/${MAKEFILE} ${BUILDDIR}/lib/${MAKEFILE}
}

build() 
{
   export ZLIB_PATH=${INCLUDE_BASE}/${INCLUDE_DEFAULT}
   ( cd ${BUILDDIR}/lib && make -f Makefile.m32 ZLIB=1 )
}

install()
{
   install_pre
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/curl.dll ${BINARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/libcurl.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/libcurl.a ${STATICLIBRARY_PATH}
   for a in ${INSTALL_HEADERS}; do ${CP} ${CP_FLAGS} ${SRCDIR}/include/curl/$a ${INCLUDE_PATH}; done
   install_post
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/curl.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libcurl.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libcurl.a
   for a in ${INSTALL_HEADERS}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
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
