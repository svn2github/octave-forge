#! /bin/sh

# this script downloads, patches and builds fftw3.dll 

# Name of the package we're building
PKG=fftw
# Version of the package
VER=3.1.2
# Release No
REL=1
# URL to source code
URL=http://www.fftw.org/fftw-3.1.2.tar.gz

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
SRCFILE=${SRCPKG}.tar.gz
# Directory where the source code is located
SRCDIR=${TOPDIR}/${PKGNAME}

# The directory we build the source code in
BUILDDIR=${TOPDIR}/.build_mingw32
MKPATCHFLAGS=""

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

conf() {
(
   cd ${BUILDDIR} && ${SRCDIR}/configure CC=mingw32-gcc CXX=mingw32-g++ F77=mingw32-g77 --prefix=${PREFIX} --srcdir=${SRCDIR} --enable-shared --enable-portable-binary
)
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/.libs/libfftw3-3.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/.libs/libfftw3.dll.a ${INSTALL_LIB}
  cp ${CP_FLAGS} ${SRCDIR}/api/fftw3.h ${INSTALL_INCLUDE}
  strip ${STRIP_FLAGS} ${INSTALL_BIN}/libfftw3-3.dll
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/libfftw3-3.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libfftw3.dll.a
  rm ${RM_FLAGS} ${INSTALL_INCLUDE}/fftw3.h
)
}

all() {
  unpack
  conf
  build
  install
}
main $*
   
