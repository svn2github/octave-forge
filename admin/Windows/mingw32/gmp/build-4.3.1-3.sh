#! /usr/bin/sh

# Name of package
PKG=gmp
# Version of Package
VER=4.3.1
# Release of (this patched) package
REL=3
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}.tar.bz2
TAR_TYPE=j
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="http://gd.tuwien.ac.at/gnu/gnusrc/gmp/gmp-4.3.1.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd -W | sed -e 's+\([a-zA-z]\):/+/\1/+'`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=""

# Additional DIFF Flags for generating diff file
#DIFF_FLAGS="-x *.def"

# header files to be installed
INSTALL_HEADERS=""

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

conf()
{
   # No optimization flags here!
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=../${SRCDIR} \
     CC="${CC} $LIBGCCLDFLAGS" \
     CXX="${CXX} $LIBGCCLDFLAGS" \
     F77="${F77} $LIBGCCLDFLAGS" \
     CFLAGS="$CFLAGS -Wall $GCC_ARCH_FLAGS $GCC_OPT_FLAGS" \
     CXXFLAGS="$CXXFLAGS -Wall $GCC_ARCH_FLAGS $GCC_OPT_FLAGS" \
     LDFLAGS="${LDFLAGS}" \
     --prefix="${PREFIX}" \
     --enable-shared \
     --disable-static \
     --enable-fat \
     ABI=32
   )
   # GMP cannot build static and dynamic library simultaneously!
}

# Running "make check" will produce all-failed tests if built with 
# --enable-shared. This is due to strange method of creating executable 
# within libtool.
# However, when building with --enable-static, make check reports ALL tests 
# as passed.
# Tested using TDM mingw32-gcc-4.3.0-2-dw2, 16-jun-2009, with NO optimization flags
# Tested using TDM mingw32-gcc-4.3.0-2-dw2, 16-jun-2009, with -O3 optimization flag
# Tested using TDM mingw32-gcc-4.3.0-2-dw2, 16-jun-2009, with -O2 -mtune=generic -march=i686 flags

build_pre()
{
  modify_libtool_all ${BUILDDIR}/libtool
}

install()
{
   install_pre;
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/gmp.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libgmp.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gmp.h ${INCLUDE_PATH}
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING     ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING.lib ${LICENSE_PATH}/${PKG}
   
   install_post;
   
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/gmp.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libgmp.dll.a
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/gmp.h
}

all() {
  download
  unpack
  applypatch
  mkdirs
  conf
  build
  install
}

main $*
