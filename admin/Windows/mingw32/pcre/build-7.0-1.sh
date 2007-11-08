#! /bin/sh

# this script downloads, patches and builds pcre.dll 

# Name of the package we're building
PKG=pcre
# Version of the package
VER=7.0
# Release No
REL=1
# URL to source code
URL=http://downloads.sourceforge.net/pcre/pcre-7.0.tar.bz2

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
BUILDDIR=${TOPDIR}/.build_mingw32_${VER}-${REL}
MKPATCHFLAGS=""
INSTHEADERS="pcre.h"
INSTALLDIR_INCLUDE=

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

conf() {
(
   mkdirs;
   cd ${BUILDDIR} && ${SRCDIR}/configure CC=mingw32-gcc CFLAGS=-O3 CXX=mingw32-g++ CXXFLAGS=-O3 CPPFLAGS="" --prefix=${PREFIX} --srcdir=${SRCDIR} --enable-utf8 --enable-unicode-properties --enable-newline-is-any
)
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/.libs/pcre.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/.libs/pcrecpp.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/.libs/pcreposix.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/.libs/libpcre.dll.a ${INSTALL_LIB}
  cp ${CP_FLAGS} ${BUILDDIR}/.libs/libpcrecpp.dll.a ${INSTALL_LIB}
  cp ${CP_FLAGS} ${BUILDDIR}/.libs/libpcreposix.dll.a ${INSTALL_LIB}
  for a in ${INSTHEADERS}; do cp ${CP_FLAGS} ${SRCDIR}/$a ${INSTALL_INCLUDE}; done
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/pcre.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libpcre.dll.a
  rm ${RM_FLAGS} ${INSTALL_BIN}/pcrecpp.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libpcrecpp.dll.a
  rm ${RM_FLAGS} ${INSTALL_BIN}/pcreposix.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libpcreposix.dll.a
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
   
