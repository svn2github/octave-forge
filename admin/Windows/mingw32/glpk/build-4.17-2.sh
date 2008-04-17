#! /usr/bin/sh

# Name of package
PKG=glpk
# Version of Package
VER=4.17
# Release of (this patched) package
REL=2
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
URL="http://gd.tuwien.ac.at/gnu/gnusrc/glpk/glpk-4.17.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
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
INCLUDE_DIR=include/glpk

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
     --prefix="${PREFIX}"
   )
}

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/glpk.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/libglpk.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${SRCDIR}/include/glpk.h ${INCLUDE_PATH}
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/glpk.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libglpk.dll.a
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/glpk.h
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
