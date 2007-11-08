#! /bin/sh

# this script downloads, patches and builds regex.dll 

# Name of the package we're building
PKG=mingw-libgnurx
# Version of the package
VER=2.5.1
# Release No
REL=1
# URL to source code
URL=http://downloads.sourceforge.net/mingw/mingw-libgnurx-2.5.1-src.tar.gz

# ---------------------------
# The directory this script is located
TOPDIR=`pwd`
# Name of the source package
PKGNAME=${PKG}-${VER}
# Full package name including revision
FULLPKG=${PKGNAME}-${REL}
# Name of the source code package
SRCPKG=${PKGNAME}-src
# Name of the patch file
PATCHFILE=${FULLPKG}.diff
# Name of the source code file
SRCFILE=${PKGNAME}-src.tar.gz
# Directory where the source code is located
SRCDIR=${TOPDIR}/${PKGNAME}

# The directory we build the source code in
BUILDDIR=${TOPDIR}/.build_mingw32_${VER}-${REL}
MKPATCHFLAGS=""
INSTHEADERS="regex.h"
INSTALLDIR_INCLUDE=

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

conf() {
(
   mkdirs;
   cd ${BUILDDIR} && ${SRCDIR}/configure CC=mingw32-gcc CFLAGS=-O3 CPPFLAGS="" --prefix=${PREFIX} --srcdir=${SRCDIR}
)
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/libgnurx-0.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/libregex.dll.a ${INSTALL_LIB}
  for a in ${INSTHEADERS}; do cp ${CP_FLAGS} ${SRCDIR}/$a ${INSTALL_INCLUDE}; done
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/libreadline.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libreadline.dll.a
  rm ${RM_FLAGS} ${INSTALL_BIN}/libhistory.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libhistory.dll.a
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
   
