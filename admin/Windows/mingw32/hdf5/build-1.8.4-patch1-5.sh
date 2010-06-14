#! /usr/bin/sh

# Name of package
PKG=hdf5
# Version of Package
VER=1.8.4-patch1
# Release of (this patched) package
REL=5
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.bz2
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="ftp://ftp.hdfgroup.org/HDF5/hdf5-1.8.4-patch1/src/hdf5-1.8.4-patch1.tar.bz2"

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

# Header files to install
HEADERS_INSTALL="\
src/hdf5.h \
src/H5api_adpt.h \
src/H5overflow.h \
src/H5public.h \
src/H5version.h \
src/H5Apublic.h \
src/H5ACpublic.h \
src/H5Cpublic.h \
src/H5Dpublic.h \
src/H5Epubgen.h \
src/H5Epublic.h \
src/H5Fpublic.h \
src/H5FDpublic.h \
src/H5FDcore.h \
src/H5FDdirect.h \
src/H5FDfamily.h \
src/H5FDlog.h \
src/H5FDmpi.h \
src/H5FDmpio.h \
src/H5FDmpiposix.h \
src/H5FDmulti.h \
src/H5FDsec2.h \
src/H5FDstdio.h \
src/H5Gpublic.h \
src/H5Ipublic.h \
src/H5Lpublic.h \
src/H5MMpublic.h \
src/H5Opublic.h \
src/H5Ppublic.h \
src/H5Rpublic.h \
src/H5Spublic.h \
src/H5Tpublic.h \
src/H5Zpublic.h
"
HEADERS_BUILD_INSTALL="src/H5pubconf.h"

# install subdirectory below $PREFIX/$INC_DIR (if any)
INCLUDE_SUBDIR=

# License file(s) to install
LICENSE_INSTALL="COPYING"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc45_common.sh

# Directory the lib is built in (set this *after* loading gcc45_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

# IMPORTANT !!
#  DISABLE OPTIMIZATION FLAGS with GCC
#  Othewise the checks for HW number conversions FAIL

conf_pre()
{
    CONFIGURE_XTRA_ARGS="\
     --disable-fortran \
     --disable-cxx \
     --enable-static \
     --enable-shared"
}


install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/hdf5.dll      $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libhdf5.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libhdf5.a     $PREFIX/$STATICLIB_DIR
   
   install_common;
   install_post;
}

install_strip()
{
   install;
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/hdf5.dll
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/hdf5.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libhdf5.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libhdf5.a
   
   uninstall_common;
   uninstall_post;
}

check()
{
   ( PATH=$BUILDDIR/src/.libs:$PREFIX/$BIN_DIR:$PATH
     MAKE_PARALLEL=
     cd $BUILDDIR && make_common HDF5_NOCLEANUP=1 check
   )
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
