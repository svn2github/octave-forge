#! /bin/sh

# this script downloads, patches and builds gmp.dll 

# Name of the package we're building
PKG=gmp
# Version of the package
VER=4.2.1
# Release No
REL=1
# URL to source code
URL=http://ftp.sunet.se/pub/gnu/gmp/gmp-4.2.1.tar.bz2

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
INSTHEADERS=""
INSTHEADERS_BUILD=""

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

conf() {
(
   mkdirs;
   cd ${BUILDDIR} && ${SRCDIR}/configure CC=mingw32-gcc CFLAGS=-O3 CPPFLAGS="" CXX=mingw32-g++ CXXFLAGS=-O3 --prefix=${PREFIX} --srcdir=${SRCDIR} --enable-shared --disable-static
)
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/.libs/gmp.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/.libs/libgmp.dll.a ${INSTALL_LIB}
  cp ${CP_FLAGS} ${BUILDDIR}/gmp.h ${INSTALL_INCLUDE}
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/gmp.dll 
  rm ${RM_FLAGS} ${INSTALL_LIB}/libgmp.dll.a
  rm ${RM_FLAGS} ${INSTALL_INCLUDE}/gmp.h
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
   
