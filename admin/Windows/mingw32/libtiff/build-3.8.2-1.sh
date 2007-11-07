#! /bin/sh

# this script downloads, patches and builds libtiff.dll 

# Name of the package we're building
PKG=tiff
# Version of the package
VER=3.8.2
# Release No
REL=1
# URL to source code
URL=ftp://ftp.remotesensing.org/pub/libtiff/tiff-3.8.2.tar.gz

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
BUILDDIR=${TOPDIR}/.build_mingw32
MKPATCHFLAGS=""
INSTHEADERS="tiff.h tiffvers.h tiffio.h"
INSTHEADERS_BUILD="tiffconf.h"

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

conf() {
(
   mkdirs;
   cd ${BUILDDIR} && ${SRCDIR}/configure CC=mingw32-gcc CFLAGS=-O3 CPPFLAGS="" CXX=mingw32-g++ CXXFLAGS=-O3 --prefix=${PREFIX} --srcdir=${SRCDIR} --enable-cxx
)
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/libtiff/libtiff.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/libtiff/libtiff.dll.a ${INSTALL_LIB}
  for a in ${INSTHEADERS}; do cp ${CP_FLAGS} ${SRCDIR}/libtiff/$a ${INSTALL_INCLUDE}; done
  for a in ${INSTHEADERS_BUILD}; do cp ${CP_FLAGS} ${BUILDDIR}/libtiff/$a ${INSTALL_INCLUDE}; done
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/libtiff.dll 
  rm ${RM_FLAGS} ${INSTALL_LIB}/libtiff.dll.a
  for a in ${INSTHEADERS}; do rm ${RM_FLAGS} ${INSTALL_INLUDE}/$a; done
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
   
