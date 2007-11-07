#! /bin/sh

# this script downloads, patches and builds less.exe 

# Name of the package we're building
PKG=less
# Version of the package
VER=406
# Release No
REL=1
# URL to source code
URL=http://www.greenwoodsoftware.com/less/less-406.tar.gz

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
BUILDDIR=${SRCDIR}
MKPATCHFLAGS="-x defines.h"
#INSTHEADERS="png.h pngconf.h"
#INSTALLDIR_INCLUDE=include

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

conf() {
( echo nothting to be configured! )
}

build() {
(
  cd ${BUILDDIR} && make -f Makefile.mingw32
)
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/less.exe ${INSTALL_BIN}
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/less.exe
)
}

all() {
  unpack
  applypatch
  build
  install
}
main $*
   
