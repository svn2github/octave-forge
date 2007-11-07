#! /bin/sh

# this script downloads, patches and builds libcurl

# Name of the package we're building
PKG=curl
# Version of the package
VER=7.16.4
# Release No
REL=1
# URL to source code
URL=http://curl.haxx.se/download/curl-7.16.4.tar.bz2

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
BUILDDIR=${SRCDIR}
MKPATCHFLAGS=""
INSTHEADERS="curl.h curlver.h easy.h mprintf.h multi.h stdcheaders.h types.h"
INSTALLDIR_INCLUDE=include/curl

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

build() {
(
  cd ${BUILDDIR} && make mingw32 DYN=1
)
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/lib/libcurl.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/lib/libcurl.dll.a ${INSTALL_LIB}
  for a in ${INSTHEADERS}; do cp ${CP_FLAGS} ${SRCDIR}/include/curl/$a ${INSTALL_INCLUDE}; done
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/libcurl.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libcurl.dll.a
  for a in ${INSTHEADERS}; do rm ${RM_FLAGS} ${INSTALL_INCLUDE}/$a; done
)
}

all() {
  unpack
  applypatch
  build
  install
}
main $*
