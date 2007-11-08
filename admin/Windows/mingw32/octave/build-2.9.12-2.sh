#! /bin/sh

# this script downloads, patches and builds OCTAVE 2.9.12

# Name of the package we're building
PKG=octave
# Version of the package
VER=2.9.12
# Release No
REL=2
# URL to source code
URL=ftp://ftp.octave.org/pub/octave/bleeding-edge/octave-2.9.12.tar.bz2

# ---------------------------
# The directory this script is located
# Make sure that we have a MSYS patch starting with a drive letter!
TOPDIR=`pwd -W | sed -e 's+^\([a-zA-z]\):/+/\1/+'`
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
BUILDDIR=.build_mingw32_${VER}-${REL}
MKPATCHFLAGS="-x configure -x config.h.in -x *~"
INSTHEADERS=""
INSTALLDIR_INCLUDE=

# PATHS to supporting programs
PATH_MIKTEX=/c/Programs/MiKTeX24/miktex/bin/
PATH_GNUPLOT=/c/Programs/gnuplot/4.2/bin
PATH_GHOSTSCRIPT=/c/Programs/gs/gs8.54/bin

# --- load common functions ---
source ../common.sh

source ../pkg_version.sh

PREFIX_OCT=${PREFIX_OCTAVE}/${VER}

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

mkpatchpre() {
( rm -rf ${SRCDIR}/autom4te.cache; rm -rf ${SRCDIR}/scripts/autom4te.cache )
}

conf() {
(
   mkdirs;
   export PATH=${PATH_MIKTEX}:${PATH_GNUPLOT}:${INSTALL_BIN}:${PATH}:${PATH_GHOSTSCRIPT}
   ( cd ${SRCDIR} && ./autogen.sh );
   cd ${BUILDDIR} && ${SRCDIR}/configure CC=mingw32-gcc CFLAGS="" CPPFLAGS=-O3 CXX=mingw32-g++ CXXFLAGS="" F77=mingw32-g77 FFLAGS=-O3 --prefix=${PREFIX_OCT} --srcdir=${SRCDIR}
)
}

build() {
( export PATH=${PATH_MIKTEX}:${PATH_GNUPLOT}:${INSTALL_BIN}:${PATH}:${PATH_GHOSTSCRIPT};
  cd ${BUILDDIR} && make
)
}

install() {
( cd ${BUILDDIR} && make install; )
}

# Install a ready "make&make install"-ed octave into our PACKAGE_ROOT directory
# where the required additional libraries & include files have been installed
install_pkg() {
 echo ${PREFIX_OCT}
 mkdir -p ${PACKAGE_ROOT}
 ( cp -vR ${PREFIX_OCT}{/bin,/lib,/include,/info,/libexec,/man,/share} ${PACKAGE_ROOT};
   rm -f ${PACKAGE_ROOT}/lib/octave-${VER}/*.${VER}
   strip ${STRIP_FLAGS} ${PACKAGE_ROOT}/bin/*.exe;
   strip ${STRIP_FLAGS} ${PACKAGE_ROOT}/bin/{liboctinterp,liboctave,libcruft}.dll;
   find ${PACKAGE_ROOT} -name *.oct -exec strip ${STRIP_FLAGS} "{}" \;
   # Install documentation: PDF
   mkdir -p ${PACKAGE_ROOT}/doc/pdf
   cp -vR ${BUILDDIR}/doc/interpreter/octave.pdf ${PACKAGE_ROOT}/doc/pdf
   cp -vR ${BUILDDIR}/doc/liboctave/liboctave.pdf ${PACKAGE_ROOT}/doc/pdf
   # Install documentation: HTML
   mkdir -p ${PACKAGE_ROOT}/doc/html/faq
   mkdir -p ${PACKAGE_ROOT}/doc/html/interpreter
   mkdir -p ${PACKAGE_ROOT}/doc/html/liboctave
   cp -vR ${BUILDDIR}/doc/faq/html/*.html ${PACKAGE_ROOT}/doc/html/faq
   cp -vR ${BUILDDIR}/doc/interpreter/html/*.html ${PACKAGE_ROOT}/doc/html/interpreter
   cp -vR ${BUILDDIR}/doc/liboctave/html/*.html ${PACKAGE_ROOT}/doc/html/liboctave
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
   
