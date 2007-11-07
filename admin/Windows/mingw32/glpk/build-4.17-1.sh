#! /bin/sh

# this script downloads, patches and builds glpk.dll 

# Name of the package we're building
PKG=glpk
# Version of the package
VER=4.17
# Release No
REL=1
# URL to source code
URL=http://gd.tuwien.ac.at/gnu/gnusrc/glpk/glpk-4.17.tar.gz

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
BUILDDIR=.build_mingw32_${VER}-${REL}
MKPATCHFLAGS=""
INSTHEADERS="glpk.h"
INSTALLDIR_INCLUDE=

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

conf() {
(
   mkdirs;
   cd ${BUILDDIR} && ${SRCDIR}/configure CC=mingw32-gcc CFLAGS=-O3 CPPFLAGS="-I${SRCDIR}/include" --prefix=${PREFIX} --srcdir=${SRCDIR}
)
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/src/glpk.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/src/libglpk.dll.a ${INSTALL_LIB}
  for a in ${INSTHEADERS}; do cp ${CP_FLAGS} ${SRCDIR}/include/$a ${INSTALL_INCLUDE}; done
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/glpk.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libglpk.dll.a
  for a in ${INSTHEADERS}; do rm ${RM_FLAGS} ${INSTALL_INLUDE}/$a; done
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
   
