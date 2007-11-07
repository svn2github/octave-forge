#! /bin/sh

# this script downloads, patches and builds zlib.dll 
# for zlib version 1.2.3

# Name of the package we're building
PKG=glob
# Version of the package
VER=1.0
# Release No
REL=1
# URL to source code
URL=http://www.dbateman.org/octave/glob-1.0.tar.bz2

# installation prefix
PREFIX=/usr/local

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
MKPATCHFLAGS="-x Makefile -x config.log -x configure -x config.status -x config.h"

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

conf() {
( cd ${SRCDIR} && ./configure CC=mingw32-gcc CPPFLAGS=-O3 CFLAGS="" )
}

build() {
(cd ${SRCDIR} && make )
}

clean() {
(cd ${SRCDIR} && make distclean)
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/glob.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/libglob.dll.a ${INSTALL_LIB}
  cp ${CP_FLAGS} ${BUILDDIR}/libglob.def ${INSTALL_LIB}
  cp ${CP_FLAGS} ${BUILDDIR}/glob.h ${BUILDDIR}/fnmatch.h ${INSTALL_INCLUDE}
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/glob.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libglob.dll.a
  rm ${RM_FLAGS} ${INSTALL_LIB}/libglob.def
  rm ${RM_FLAGS} ${INSTALL_INCLUDE}/glob.h ${INSTALL_INCLUDE}/fnmatch.h
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
   
