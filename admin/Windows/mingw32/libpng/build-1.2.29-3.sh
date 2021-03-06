#! /usr/bin/sh

# Name of package
PKG=libpng
# Version of Package
VER=1.2.29
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
URL="ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng-1.2.29.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd -W | sed -e 's+\([a-z]\):/+/\1/+'`
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

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
   substvars ${SRCDIR}/scripts/$MAKEFILE ${BUILDDIR}/$MAKEFILE
}

build()
{
   ( cd $BUILDDIR && make -f $MAKEFILE CFLAGS="$GCC_ARCH_FLAGS" static shared )
}

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/png12.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libpng.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libpng.a ${STATICLIBRARY_PATH}
   for a in ${INSTALL_HEADERS}; do ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}; done
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/LICENSE ${LICENSE_PATH}/${PKG}
   install_post;
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/png12.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libpng.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libpng.a
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
