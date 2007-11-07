#! /bin/sh

# this script downloads, patches and builds zlib.dll 
# for zlib version 1.2.3

# Name of the package we're building
PKG=zlib
# Version of the package
VER=1.2.3
# Release No
REL=1
# URL to source code
URL=http://www.gzip.org/zlib/zlib-1.2.3.tar.bz2

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

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)
build() {
(cd ${SRCDIR} && make -f win32/Makefile.gcc)
}

clean() {
(cd ${SRCDIR} && make -f win32/Makefile.gcc clean)
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/zlib1.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/libz.dll.a ${INSTALL_LIB}
  cp ${CP_FLAGS} ${BUILDDIR}/zlib.h ${BUILDDIR}/zconf.h ${INSTALL_INCLUDE}
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/zlib1.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libz.dll.a
  rm ${RM_FLAGS} ${INSTALL_INCLUDE}/zlib.h ${INSTALL_INCLUDE}/zconf.h
)
}

all() {
  unpack
  applypatch
  build
  install
}
main $*
