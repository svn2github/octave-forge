#! /usr/bin/sh

# Name of package
PKG=curl
# Version of Package
VER=7.19.6
# Release of (this patched) package
REL=4
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.lzma
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://curl.haxx.se/download/curl-7.19.6.tar.lzma"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=makefile.m32
# Any extra flags to pass make to
MAKE_XTRA=

# subdirectory to install heraders to (empty for default)
INCLUDE_DIR=include/curl

# Herader files to install
HEADERS_INSTALL="curl.h curlver.h easy.h mprintf.h stdcheaders.h types.h multi.h typecheck-gcc.h curlbuild.h curlrules.h"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x ca-bundle.h -x libcurl.res"

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

MAKE_XTRA="ZLIB=1 ZLIB_PATH=${INCLUDE_BASE}/${INCLUDE_DEFAULT}"

mkdirs_post() 
{ 
   # directory makefile is located
   mkdir -p ${BUILDDIR}/lib
}

conf()
{
   conf_pre;
   substvars ${SRCDIR}/lib/${MAKEFILE} ${BUILDDIR}/lib/${MAKEFILE}
   conf_post;
}

build()
{
   build_pre;
   ( cd ${BUILDDIR}/lib && make_common )
   build_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/curl.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/libcurl.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/libcurl.a ${STATICLIB_PATH}
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/include/curl/$a ${INCLUDE_PATH}
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/curl.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libcurl.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libcurl.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   
   uninstall_post;
}

check()
{
   check_pre;
   
   ( cd ${BUILDDIR} && make -f ${MAKEFILE} test )
   ( cd ${BUILDDIR} && make -f ${MAKEFILE} testdll )
   
   check_post;
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
