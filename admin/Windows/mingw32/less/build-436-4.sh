#! /usr/bin/sh

# Name of package
PKG=less
# Version of Package
VER=436
# Release of (this patched) package
REL=4
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.gz
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://www.greenwoodsoftware.com/less/less-436.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=makefile.mingw32
# Any extra flags to pass make to
MAKE_XTRA=

# subdirectory to install heraders to (empty for default)
INCLUDE_DIR=

# Herader files to install
HEADERS_INSTALL=""

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

conf()
{
   conf_pre;
   substvars ${SRCDIR}/${MAKEFILE} ${BUILDDIR}/${MAKEFILE}
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   #${CP} ${CP_FLAGS} ${BUILDDIR}/zlib1.dll ${SHAREDLIB_PATH}
   #${CP} ${CP_FLAGS} ${BUILDDIR}/libz.dll.a ${LIBRARY_PATH}
   #${CP} ${CP_FLAGS} ${BUILDDIR}/libz.a ${STATICLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/less.exe ${BINARY_PATH}
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/LICENSE ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   #${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/zlib1.dll
   #${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libz.dll.a
   #${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libz.a
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/less.exe
   
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
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/LICENSE
   
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
