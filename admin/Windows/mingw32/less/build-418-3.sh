#! /usr/bin/sh

# Name of package
PKG=less
# Version of Package
VER=418
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
URL="http://www.greenwoodsoftware.com/less/less-418.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE="Makefile.mingw32"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x defines.h"

# header files to be installed
INSTALL_HEADERS=""

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

conf()
{
   substvars ${SRCDIR}/${MAKEFILE} ${BUILDDIR}/${MAKEFILE}
}

build()
{
   ( cd $BUILDDIR && make $MAKE_FLAGS -f $MAKEFILE CFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS}" LDFLAGS="" all )
}

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/less.exe ${BINARY_PATH}
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/LICENSE ${LICENSE_PATH}/${PKG}
   install_post;
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/less.exe
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
