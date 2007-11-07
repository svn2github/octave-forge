#! /bin/sh

# this script downloads, patches and builds libjpeg.dll 

# Name of the package we're building
PKG=jpeg
# Version of the package
VER=6b
# Release No
REL=1
# URL to source code
URL=http://www.ijg.org/files/jpegsrc.v6b.tar.gz

# ---------------------------
# The directory this script is located
TOPDIR=`pwd`
# Name of the source package
PKGNAME=${PKG}-${VER}
# Full package name including revision
FULLPKG=${PKGNAME}-${REL}
# Name of the source code package
SRCPKG=jpegsrc.v6b
# Name of the patch file
PATCHFILE=${FULLPKG}.diff
# Name of the source code file
SRCFILE=jpegsrc.v6b.tar.gz
# Directory where the source code is located
SRCDIR=${TOPDIR}/${PKGNAME}

# The directory we build the source code in
BUILDDIR=${TOPDIR}/.build_mingw32
MKPATCHFLAGS=""
INSTHEADERS="jpeglib.h jmorecfg.h jerror.h"

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
  cp ${CP_FLAGS} ${BUILDDIR}/libjpeg.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/libjpeg.dll.a ${INSTALL_LIB}
  for a in ${INSTHEADERS}; do cp ${CP_FLAGS} ${SRCDIR}/$a ${INSTALL_INCLUDE}; done
  cp ${CP_FLAGS} ${BUILDDIR}/jconfig.h ${INSTALL_INCLUDE}
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/libjpeg.dll 
  rm ${RM_FLAGS} ${INSTALL_LIB}/libjpeg.dll.a
  for a in ${INSTHEADERS}; do rm ${RM_FLAGS} ${INSTALL_INLUDE}/$a; done
  rm ${RM_FLAGS} ${INSTALL_INCLUDE}/jconfig.h
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
   
