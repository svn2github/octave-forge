#! /usr/bin/sh

# Name of package
PKG=netcdf
# Version of Package
VER=4.0
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
URL="ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-4.0.tar.gz"

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
INSTALL_HEADERS="netcdf.h"
#INCLUDE_DIR=

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=../${SRCDIR} \
     CC="${CC} $LIBGCCLDFLAGS" \
     CXX="${CXX} $LIBGCCLDFLAGS" \
     F77="${F77} $LIBGCCLDFLAGS" \
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     LDFLAGS="${LDFLAGS}" \
     --prefix="${PREFIX}" \
     --enable-shared \
     --enable-dll \
     --enable-static
   )
}

build_pre()
{
   modify_libtool_all ${BUILDDIR}/libtool
}

install()
{
   install_pre;
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libsrc/.libs/netcdf.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libsrc/.libs/libnetcdf.a ${STATICLIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libsrc/.libs/libnetcdf.dll.a ${LIBRARY_PATH}
   
   for a in ${INSTALL_HEADERS}; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/libsrc/$a ${INCLUDE_PATH}
   done
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYRIGHT ${LICENSE_PATH}/${PKG}
   
   install_post
}

uninstall()
{
   uninstall_pre;

   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/netcdf.dll
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libnetcdf.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libnetcdf.dll.a
   
   for a in ${INSTALL_HEADERS}; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYRIGHT
   
   uninstall_post;
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
