#! /bin/sh

# this script downloads, patches and builds readline.dll 

# Name of the package we're building
PKG=readline
# Version of the package
VER=5.2
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
MKPATCHFLAGS=""
INSTHEADERS="readline.h chardefs.h keymaps.h history.h tilde.h rlstdc.h rlconf.h rltypedefs.h"
INSTALLDIR_INCLUDE=include/readline

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

conf() {
(
   cd ${BUILDDIR} && ${SRCDIR}/configure CC=mingw32-gcc CXX=mingw32-g++ --prefix=${PREFIX} --srcdir=${SRCDIR}
)
}

build() {
( cd ${BUILDDIR} && make shared )
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/shlib/libreadline.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/shlib/libreadline.a ${INSTALL_LIB}/libreadline.dll.a
  cp ${CP_FLAGS} ${BUILDDIR}/shlib/libhistory.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/shlib/libhistory.a ${INSTALL_LIB}/libhistory.dll.a
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
   
