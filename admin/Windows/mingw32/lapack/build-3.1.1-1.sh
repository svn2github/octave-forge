#! /bin/sh

# this script downloads, patches and builds lapack.dll 

# Name of the package we're building
PKG=lapack
# Version of the package
VER=3.1.1
# Release No
REL=1
# URL to source code
URL=http://www.netlib.org/lapack/lapack-lite-3.1.1.tgz

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
SRCFILE=${PKGNAME}.tgz
# Directory where the source code is located
SRCDIR=${TOPDIR}/${PKGNAME}

# The directory we build the source code in
BUILDDIR=${SRCDIR}
MKPATCHFLAGS="-x *.out"

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

build() {
( cd ${BUILDDIR} && make lib ) 
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/lapack.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/liblapack.dll.a ${INSTALL_LIB}
  strip ${STRIP_FLAGS} ${INSTALL_BIN}/lapack.dll
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/lapack.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/liblapack.dll.a
)
}

all() {
  unpack
  applypatch
  build
  install
}
main $*
   
