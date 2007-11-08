#! /bin/sh

# this script downloads, patches and builds sed.exe 

# Name of the package we're building
PKG=sed
# Version of the package
VER=4.1.5
# Release No
REL=1
# URL to source code
URL=

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
MKPATCHFLAGS="-x defines.h"
#INSTHEADERS="png.h pngconf.h"
#INSTALLDIR_INCLUDE=include

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

conf() {
(
   mkdirs;
   cd ${BUILDDIR} && ${SRCDIR}/configure CC=mingw32-gcc CFLAGS=-O3 CPPFLAGS="" CXX=mingw32-g++ CXXFLAGS=-O3 --prefix=${PREFIX} --srcdir=${SRCDIR} --disable-nls --with-gnu-ld --with-included-gettext --without-included-regex
)
}

#build() {
#(
#  cd ${BUILDDIR} && make -f Makefile.mingw32
#)
#}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/sed/sed.exe ${INSTALL_BIN}
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/sed.exe
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
   
