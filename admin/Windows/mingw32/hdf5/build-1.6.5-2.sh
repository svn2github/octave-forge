#! /usr/bin/sh

# Name of package
PKG=hdf5
# Version of Package
VER=1.6.5
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
#DIFF_FLAGS="-x *.def"

# header files to be installed
INSTALL_HEADERS="H5ACpublic.h    H5Dpublic.h     H5FDstream.h     H5MMpublic.h \
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
H5FDstdio.h     "
INSTALL_HEADERS_HL="H5TA.h  H5IM.h           H5LT.h           "
INSTALL_HEADERS_BUILD="H5pubconf.h      "

source ../gcc42_common.sh

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

# IMPORTANT !!
#  DISABLE OPTIMIZATION FLAGS with GCC
#  Othewise the checks for HW number conversions FAIL

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC=${CC} \
     CXX=${CXX} \
     F77=${F77} \
     LDFLAGS="${LDFLAGS} -lws2_32" \
     CPPFLAGS="" \
     CXXFLAGS="" \
     CFLAGS="" \
     --prefix="${PREFIX}" \
     --disable-stream-vfd \
     --disable-fortran \
     --disable-cxx \
     --enable-static \
     --enable-shared
   )
}

install()
{
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/hdf5.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libhdf5.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libhdf5.a ${STATICLIBRARY_PATH}

   for a in ${INSTALL_HEADERS};       do ${CP} ${CP_FLAGS} ${SRCDIR}/src/$a ${INCLUDE_PATH}; done
   for a in ${INSTALL_HEADERS_HL};    do ${CP} ${CP_FLAGS} ${SRCDIR}/hl/src/$a ${INCLUDE_PATH}; done
   for a in ${INSTALL_HEADERS_BUILD}; do ${CP} ${CP_FLAGS} ${BUILDDIR}/src/$a ${INCLUDE_PATH}; done
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/hdf5.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libhdf5.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libhdf5.a
   
   for a in ${INSTALL_HEADERS};       do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
   for a in ${INSTALL_HEADERS_HL};    do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
   for a in ${INSTALL_HEADERS_BUILD}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
}

check_pre()
{ 
  SRCDIR=`pwd -W`/${SRCDIR}/test
  export SRCDIR
  PATH=${PATH}:${TOPDIR}/${BUILDDIR}/src/.libs
  HDF5_NOCLEANUP=1
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
