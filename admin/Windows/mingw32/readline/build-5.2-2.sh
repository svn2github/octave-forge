#! /usr/bin/sh

# Name of package
PKG=readline
# Version of Package
VER=5.2
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
URL=""

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=""

# header files to be installed
INSTALL_HEADERS="readline.h chardefs.h keymaps.h history.h tilde.h rlstdc.h rlconf.h rltypedefs.h"
INCLUDE_DIR=include/readline

source ../gcc42_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC=${CC} \
     CXX=${CXX} \
     F77=${F77} \
     LDFLAGS="${LDFLAGS}" \
     CPPFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall -D_WIN32" \
     CXXFLAGS="" \
     CFLAGS="" \
     --prefix="${PREFIX}"
     )
}

build()
{
  build_pre
  ( cd ${BUILDDIR} && make shared );
  build_post
}

install()
{
   install_pre
   ${CP} ${CP_FLAGS} ${BUILDDIR}/shlib/{readline,history}.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/shlib/{libreadline,libhistory}.dll.a ${LIBRARY_PATH}
   for a in ${INSTALL_HEADERS}; do ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}; done
   install_post
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/{readline,history}.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/{libreadline,libhistory}.dll.a
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
