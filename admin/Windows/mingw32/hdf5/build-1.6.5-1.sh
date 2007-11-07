#! /bin/sh

# this script downloads, patches and builds hdf5.dll 

# Name of the package we're building
PKG=hdf5
# Version of the package
VER=1.6.5
# Release No
REL=1
# URL to source code
URL=

# ---------------------------
# The directory this script is located
TOPDIR=`pwd`
# Name of the source package
PKGNAME=${PKG}-${VER}
# Full package name including revision
FULLPKG=${PKGNAME}-${REL}
# Name of the source code package
SRCPKG=${PKGNAME}
# Name of the patch file
PATCHFILE=${FULLPKG}.diff
# Name of the source code file
SRCFILE=${PKGNAME}.tar.gz
# Directory where the source code is located
SRCDIR=${TOPDIR}/${PKGNAME}

# The directory we build the source code in
BUILDDIR=${TOPDIR}/.build_mingw32_${VER}-${REL}
MKPATCHFLAGS=""
INSTHEADERS="H5ACpublic.h    H5Dpublic.h     H5FDstream.h     H5MMpublic.h \
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
INSTHEADERS_CPP="H5AbstractDs.h  H5DxferProp.h   H5FaccProp.h     H5Object.h \
H5EnumType.h    H5FcreatProp.h   H5ArrayType.h   H5File.h         \
H5AtomType.h    H5Exception.h   H5FloatType.h    H5PredType.h \
H5Attribute.h   H5PropList.h    H5Classes.h     H5Group.h        \
H5CommonFG.h    H5StrType.h     H5CompType.h    \
H5Cpp.h         H5IdComponent.h  H5VarLenType.h H5Include.h      \
H5DataSet.h     H5IntType.h      H5DataSpace.h   \
H5CppDoc.h      H5DataType.h    \
H5DcreatProp.h  H5Library.h"
INSTHEADERS_HL="H5TA.h  H5IM.h           H5LT.h           "
INSTHEADERS_BUILD="H5pubconf.h      "
INSTALLDIR_INCLUDE=

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

conf() {
(
   mkdirs;
   cd ${BUILDDIR} && ${SRCDIR}/configure CC=mingw32-gcc CFLAGS=-O3 CXX=mingw32-g++ CXXFLAGS=-O3 CPPFLAGS="" --prefix=${PREFIX} --srcdir=${SRCDIR} --disable-stream-vfd --enable-cxx LDFLAGS=-lws2_32
)
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/src/.libs/hdf5.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/src/.libs/libhdf5.dll.a ${INSTALL_LIB}
  cp ${CP_FLAGS} ${BUILDDIR}/c++/src/.libs/hdf5_cpp.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/c++/src/.libs/libhdf5_cpp.dll.a ${INSTALL_LIB}
  for a in ${INSTHEADERS}; do cp ${CP_FLAGS} ${SRCDIR}/src/$a ${INSTALL_INCLUDE}; done
  for a in ${INSTHEADERS_CPP}; do cp ${CP_FLAGS} ${SRCDIR}/c++/src/$a ${INSTALL_INCLUDE}; done
  for a in ${INSTHEADERS_HL}; do cp ${CP_FLAGS} ${SRCDIR}/hl/src/$a ${INSTALL_INCLUDE}; done
  for a in ${INSTHEADERS_BUILD}; do cp ${CP_FLAGS} ${BUILDDIR}/src/$a ${INSTALL_INCLUDE}; done
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/hdf5.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libhdf5.dll.a
  rm ${RM_FLAGS} ${INSTALL_BIN}/hdf5_cpp.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libhdf5_cpp.dll.a
  for a in ${INSTHEADERS}; do rm ${RM_FLAGS} ${INSTALL_INLUDE}/$a; done
  for a in ${INSTHEADERS_CPP}; do rm ${RM_FLAGS} ${INSTALL_INLUDE}/$a; done
  for a in ${INSTHEADERS_HL}; do rm ${RM_FLAGS} ${INSTALL_INLUDE}/$a; done
  for a in ${INSTHEADERS_BUILD}; do rm ${RM_FLAGS} ${INSTALL_INLUDE}/$a; done
)
}

all() {
  unpack
  applypatch
  conf
  build
  install
}
main $*
   
