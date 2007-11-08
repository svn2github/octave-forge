#! /bin/sh

# this script downloads, patches and builds libpng.dll 

# Name of the package we're building
PKG=libpng
# Version of the package
VER=1.2.18
# Release No
REL=1
# URL to source code
URL=http://prdownloads.sourceforge.net/libpng/libpng-1.2.18.tar.bz2

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
SRCFILE=${PKGNAME}.tar.bz2
# Directory where the source code is located
SRCDIR=${TOPDIR}/${PKGNAME}

# The directory we build the source code in
BUILDDIR=${TOPDIR}/.build_mingw32
MKPATCHFLAGS=""
INSTHEADERS="png.h pngconf.h"
INSTALLDIR_INCLUDE=include

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

conf() {
(
   mkdirs;
   cd ${BUILDDIR} && ${SRCDIR}/configure CC=mingw32-gcc CFLAGS=-O3 CPPFLAGS="" CXX=mingw32-g++ CXXFLAGS=-O3 F77=mingw32-g77 --prefix=${PREFIX} --srcdir=${SRCDIR}
)
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/libpng-config ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/libpng12-config ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/libpng.dll ${INSTALL_BIN}
  
  cp ${CP_FLAGS} ${BUILDDIR}/libpng.dll.a ${INSTALL_LIB}
  for a in ${INSTHEADERS}; do cp ${CP_FLAGS} ${SRCDIR}/$a ${INSTALL_INCLUDE}; done
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/libpng-config 
  rm ${RM_FLAGS} ${INSTALL_BIN}/libpng12-config
  rm ${RM_FLAGS} ${INSTALL_BIN}/libpng.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libpng.dll.a
  for a in ${INSTHEADERS}; do rm ${RM_FLAGS} ${INSTALL_INLUDE}/$a; done
)
}

all() {
  download
  unpack
  applypatch
  conf
  build
  install
}
main $*
   
