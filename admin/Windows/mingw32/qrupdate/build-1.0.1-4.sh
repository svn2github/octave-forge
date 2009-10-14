#! /usr/bin/sh

# Name of package
PKG=qrupdate
# Version of Package
VER=1.0.1
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
URL="http://downloads.sourceforge.net/project/qrupdate/qrupdate/1.0/qrupdate-1.0.1.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=
# Any extra flags to pass make to
MAKE_XTRA=

# subdirectory to install heraders to (empty for default)
INCLUDE_DIR=

# Herader files to install
HEADERS_INSTALL=

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

mkdirs_post()
{
   mkdir -vp ${BUILDDIR}/src
   mkdir -vp ${BUILDDIR}/test
}

conf()
{
   conf_pre;
   
   substvars ${SRCDIR}/makefile ${BUILDDIR}/makefile
   substvars ${SRCDIR}/src/makefile ${BUILDDIR}/src/makefile
   substvars ${SRCDIR}/test/makefile ${BUILDDIR}/test/makefile
   
   conf_post;
}

build()
{
   build_pre;
   
   ( cd ${BUILDDIR}/src && make_common lib )
   ( cd ${BUILDDIR}/src && make_common solib )
   
   build_post;
}

# 23-aug-2009 Benjamin Lindner <lindnerb@users.soruceforge.net>
#  using: mingw32-gfortran-4.4.0-dw2.exe (mingw32 gcc)
#  all tests pass
# TOTAL:     PASSED 112     FAILED   0

check()
{
   check_pre;
   ( cd ${BUILDDIR}/test && make_common )
   check_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/qrupdate.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libqrupdate.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libqrupdate.a ${STATICLIB_PATH}
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/qrupdate.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libqrupdate.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libqrupdate.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   
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
