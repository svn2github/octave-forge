#! /usr/bin/sh

# Name of package
PKG=jpeg
# Version of Package
VER=6b
# Release of (this patched) package
REL=2
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=jpegsrc.v6b.tar.gz
TAR_TYPE=z
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="http://www.ijg.org/files/jpegsrc.v6b.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
# MAKEFILE=win32/Makefile.gcc

# header files to be installed
INSTALL_HEADERS="jpeglib.h jmorecfg.h jerror.h"
INSTALL_HEADERS_BUILD="jconfig.h"
INCLUDE_DIR=

source ../gcc42_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

echo ${PREFIX}

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC=${CC} \
     CXX=${CXX} \
     F77=${F77} \
     LDFLAGS="${LDFLAGS}" \
     CPPFLAGS="${GCC_ARCH_FLAGS}" \
     CFLAGS="${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="${GCC_OPT_FLAGS} -Wall" \
     --prefix="${PREFIX}"
     )
}

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libjpeg.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libjpeg.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libjpeg.a ${STATICLIBRARY_PATH}

   for a in ${INSTALL_HEADERS};       do ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}; done
   for a in ${INSTALL_HEADERS_BUILD}; do ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${INCLUDE_PATH}; done
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/README ${LICENSE_PATH}/${PKG}
   install_post
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/libjpeg.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libjpeg.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libjpeg.a
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
