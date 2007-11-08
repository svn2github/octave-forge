#! /bin/sh

# this script downloads, patches and builds cblas.dll 

# Name of the package we're building
PKG=cblas
# Version of the package
VER=
# Release No
REL=1
# URL to source code
URL=http://www.netlib.org/blas/blast-forum/cblas.tgz

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
export BUILDDIR=${SRCDIR}

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

build() {
( cd ${BUILDDIR} && make alllib )
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/lib/MINGW32/cblas.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/lib/MINGW32/libcblas.dll.a ${INSTALL_LIB}
  cp ${CP_FLAGS} ${BUILDDIR}/lib/MINGW32/libcblas.def ${INSTALL_LIB}
  cp ${CP_FLAGS} ${BUILDDIR}/src/{cblas.h,cblas_f77.h} ${INSTALL_INCLUDE}

)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/cblas.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libcblas.dll.a
  rm ${RM_FLAGS} ${INSTALL_LIB}/libcblas.def
  rm ${RM_FLAGS} ${INSTALL_INCLUDE}/{cblas.h,cblas_f77.h}
)
}

all() {
  download
  unpack
  applypatch
  build
  install
}
main $*
   
