#! /usr/bin/sh

# Name of package
PKG=hdf5
# Version of Package
VER=1.6.7
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
URL="ftp://ftp.hdfgroup.org/HDF5/prev-releases/hdf5-1.6.7/src/hdf5-1.6.7.tar.gz"

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
HEADERS_INSTALL="H5ACpublic.h    H5Dpublic.h     H5MMpublic.h \
hdf5.h \
H5Apublic.h     H5Opublic.h \
H5Epublic.h     H5Ppublic.h \
H5FDcore.h      H5Fpublic.h      \
H5Bpublic.h     H5FDfamily.h    H5Gpublic.h      H5Rpublic.h \
H5FDgass.h      H5Spublic.h \
H5FDlog.h       H5HGpublic.h     \
H5FDmpi.h       H5HLpublic.h     \
H5FDmpio.h      H5Tpublic.h \
H5FDmpiposix.h  \
H5Cpublic.h     H5FDmulti.h     H5Zpublic.h \
H5FDpublic.h    H5api_adpt.h \
H5FDsec2.h      H5Ipublic.h      \
H5FDsrb.h       H5public.h \
H5FDstdio.h"
HEADERS2_INSTALL="H5TA.h  H5IM.h           H5LT.h           "
HEADERS3_INSTALL="H5pubconf.h      "

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

# IMPORTANT !!
#  DISABLE OPTIMIZATION FLAGS with GCC
#  Othewise the checks for HW number conversions FAIL

conf()
{
   conf_pre;
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC=$CC \
     CXX=$CXX \
     F77=$F77 \
     CPP=$CPP \
     AR=$AR \
     RANLIB=$RANLIB \
     RC=$RC \
     STRIP=$STRIP \
     LD=$LD \
     CFLAGS="$CFLAGS -Wall" \
     CXXFLAGS="$CXXFLAGS -Wall" \
     CPPFLAGS="$CPPFLAGS" \
     LDFLAGS="${LDFLAGS}" \
     CXXLIBS="${CXXLIBS}" \
     LIBS="-lws2_32" \
     --prefix=${PREFIX} \
     --disable-fortran \
     --disable-cxx \
     --enable-static \
     --enable-shared

   )
   touch ${BUILDDIR}/have_configure
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/hdf5.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libhdf5.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libhdf5.a ${STATICLIB_PATH}
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/src/$a ${INCLUDE_PATH}
   done
   
   for a in $HEADERS2_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/hl/src/$a ${INCLUDE_PATH}
   done
   
   for a in $HEADERS3_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/src/$a ${INCLUDE_PATH}
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/hdf5.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libhdf5.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libhdf5.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL $HEADERS2_INSTALL $HEADERS3_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   
   uninstall_post;
}

check_pre()
{ 
  SRCDIR=`pwd -W`/${SRCDIR}/test
  export SRCDIR
  PATH=${PATH}:${TOPDIR}/${BUILDDIR}/src/.libs
  HDF5_NOCLEANUP=1
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
