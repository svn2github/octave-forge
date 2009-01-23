#! /usr/bin/sh

# Name of package
PKG=libpng
# Version of Package
VER=1.2.32
# Release of (this patched) package
REL=3
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
URL="http://download.sourceforge.net/libpng/libpng-1.2.32.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd -W | sed -e 's+\([a-zA-Z]\):/+/\1/+'`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE="makefile.mingw"

# Additional DIFF Flags for generating diff file
#DIFF_FLAGS="-x *.def"

# header files to be installed
INSTALL_HEADERS="png.h pngconf.h"

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

conf()
{
   substvars ${SRCDIR}/scripts/$MAKEFILE ${BUILDDIR}/$MAKEFILE
}

build()
{
   ( cd $BUILDDIR && make ${MAKE_FLAGS} -f $MAKEFILE CFLAGS="$GCC_ARCH_FLAGS $GCC_OPT_FLAGS" prefix="${PREFIX}" all )
}

check()
{
   ( cd $BUILDDIR && make -f $MAKEFILE test )
}

# MAKE CHECK passed using TDM GCC MinGW32 4.3.0-2 DW2, 01-nov-2008

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/png12.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libpng.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libpng.a ${STATICLIBRARY_PATH}
   for a in ${INSTALL_HEADERS}; do ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}; done
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/LICENSE ${LICENSE_PATH}/${PKG}
   
   ${CP} ${CPFLAGS} ${BUILDDIR}/libpng.pc ${PKGCONFIGDATA_PATH}
   
   install_post;
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/png12.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libpng.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libpng.a
   for a in ${INSTALL_HEADERS}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
   
   ${RM} ${RM_FLAGS}  ${LICENSE_PATH}/${PKG}/LICENSE
   rmdir --ignore-fail-on-non-empty  ${LICENSE_PATH}/${PKG}
   rmdir --ignore-fail-on-non-empty  ${LICENSE_PATH}
   
   ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/libpng.pc
   rmdir --ignore-fail-on-non-empty ${PKGCONFIGDATA_PATH}
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
