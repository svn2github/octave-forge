#! /usr/bin/sh

# Name of package
PKG=qhull
# Version of Package
VER=2003.1
# Release of (this patched) package
REL=2
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}-src.tgz
TAR_TYPE=z
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="http://www.qhull.org/download/qhull-2003.1-src.tgz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
#TOPDIR=`pwd -W | sed -e 's+\([a-z]\):/+/\1/+'`
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE="makefile"

# Additional DIFF Flags for generating diff file
#DIFF_FLAGS="-x *.def"

# header files to be installed
INSTALL_HEADERS="user.h qhull.h qhull_a.h geom.h io.h mem.h merge.h poly.h qset.h stat.h"
INCLUDE_DIR=include/qhull

source ../gcc42_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }
mkdirs_post()
{
   mkdir -vp ${BUILDDIR}/src
}

conf()
{
   substvars ${SRCDIR}/src/${MAKEFILE} ${BUILDDIR}/src/${MAKEFILE}
}

build() 
{
   ( cd ${BUILDDIR}/src && make all lib )
}

clean() 
{
   ( cd ${BUILDDIR}/src && make clean )
}

install()
{
   install_pre
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/qhull.dll      ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/libqhull.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/libqhull.a     ${STATICLIBRARY_PATH}
   for a in ${INSTALL_HEADERS}; do ${CP} ${CP_FLAGS} ${SRCDIR}/src/$a ${INCLUDE_PATH}; done
   install_post
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/qhull.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libqhull.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libqhull.a
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
