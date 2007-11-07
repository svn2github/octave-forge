#! /bin/sh

# this script downloads, patches and builds blas.dll 

# Name of the package we're building
PKG=blas
# Version of the package
VER=
# Release No
REL=1
# URL to source code
URL=http://www.netlib.org/blas/blas.tgz

# installation prefix
PREFIX=/usr/local

# ---------------------------
# The directory this script is located
TOPDIR=`pwd`
# Name of the source package
PKGNAME=${PKG}
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

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

unpack() {
(
   mkdir -p ${PKGNAME} && cd ${PKGNAME} && tar xzvf ${TOPDIR}/${SRCFILE};
)
}


build() {
( cd ${SRCDIR} && make -f makefile.mingw )
}

clean() {
( cd ${SRCDIR} && make -f makefile.mingw clean )
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/blas.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/libblas.dll.a ${INSTALL_LIB}
  cp ${CP_FLAGS} ${BUILDDIR}/libblas.def ${INSTALL_LIB}
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/blas.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libblas.dll.a
  rm ${RM_FLAGS} ${INSTALL_LIB}/libblas.def
)
}

all() {
  unpack
  applypatch
  build
  install
}
main $*
   
