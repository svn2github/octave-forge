#! /usr/bin/sh

# Name of package
PKG=mingw-libgnurx
# Version of Package
VER=2.5.1
# Release of (this patched) package
REL=2
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}-src.tar.gz
TAR_TYPE=z
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="http://downloads.sourceforge.net/mingw/mingw-libgnurx-2.5.1-src.tar.gz"

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
INSTALL_HEADERS="regex.h"

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
     LDFLAGS="${LDFLAGS} -lws2_32" \
     CPPFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS}" \
     CXXFLAGS="" \
     CFLAGS="" \
     --prefix="${PREFIX}"
   )
}

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gnurx.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libregex.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libregex.a ${STATICLIBRARY_PATH}
   for a in ${INSTALL_HEADERS};       do ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}; done
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING.LIB ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/README      ${LICENSE_PATH}/${PKG}
   

}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/gnurx.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libregex.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libregex.a
   for a in ${INSTALL_HEADERS};       do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
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
