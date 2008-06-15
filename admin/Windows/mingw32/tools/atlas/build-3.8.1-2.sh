#! /usr/bin/sh

# Name of package
PKG=atlas
# Version of Package
VER=3.8.1
# Release of (this patched) package
REL=2
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKG}${VER}.tar.bz2
TAR_TYPE=j
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="http://downloads.sourceforge.net/math-atlas/atlas3.8.1.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
#MAKEFILE=win32/Makefile.gcc

source ../../gcc42_common.sh
source ../../gcc42_pkg_version.sh

# Directory the lib is built in
#BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

echo ${PREFIX}

MSG="Building ATLAS libraries must be done using CYGWIN!";

DIRS=`ls -1 | sed -ne "/ARCH_\([A-Za-z0-9]\)/p"`

unpack() { echo $MSG; }

unpack_orig() { echo $MSG; }

mkdirs() { echo $MSG; }

conf() { echo $MSG; }

build()
{
   for a in $DIRS; do
      if [ -e ".build_$a" ]; then rm -rf ".build_$a"; fi
      echo "Entering directory .build_$a ..."
      mkdir ".build_$a" && cd ".build_$a" && makeshlibs ${TOPDIR}/$a && cd ..
   done
}

makeshlibs()
{
  FLDFLAGS="-Wl,-s"
  
  $F77 $FLDFLAGS -shared -o atlas.dll \
	-Wl,--out-implib=libatlas.dll.a \
	-Wl,--whole-archive $1/libatlas.a \
	-Wl,--no-whole-archive

  $F77 $FLDFLAGS -shared -o blas.dll \
	-Wl,--out-implib=libblas.dll.a \
	-Wl,--whole-archive $1/libf77blas.a \
	-Wl,--no-whole-archive libatlas.dll.a

  $F77 $FLDFLAGS -shared -o cblas.dll \
	-Wl,--out-implib=libcblas.dll.a \
	-Wl,--whole-archive $1/libcblas.a \
	-Wl,--no-whole-archive libatlas.dll.a

  $F77 $FLDFLAGS -shared -o lapack.dll \
	-Wl,--out-implib=liblapack.dll.a \
	-Wl,--whole-archive $1/liblapack.a \
	-Wl,--no-whole-archive libblas.dll.a libcblas.dll.a libatlas.dll.a
}

install() { echo; }

install_pkg()
{
   echo "Installing libraries for the following architectures:"
   echo $DIRS
   
   for a in $DIRS; do
      TDBIN=${PACKAGE_ROOT}/ATLAS/${SHAREDLIB_DEFAULT}/$a
      TDLIB=${PACKAGE_ROOT}/ATLAS/${LIBRARY_DEFAULT}/$a
      TDSLB=${PACKAGE_ROOT}/ATLAS/${STATICLIBRARY_DEFAULT}/$a
      mkdir -vp $TDBIN
      mkdir -vp $TDLIB
      mkdir -vp $TDSLB
      cp ${CP_FLAGS} .build_${a}/lapack.dll $TDBIN
      cp ${CP_FLAGS} .build_${a}/atlas.dll  $TDBIN
      cp ${CP_FLAGS} .build_${a}/blas.dll   $TDBIN
      cp ${CP_FLAGS} .build_${a}/cblas.dll  $TDBIN

      cp ${CP_FLAGS} .build_${a}/liblapack.dll.a $TDLIB
      cp ${CP_FLAGS} .build_${a}/libatlas.dll.a  $TDLIB
      cp ${CP_FLAGS} .build_${a}/libblas.dll.a   $TDLIB
      cp ${CP_FLAGS} .build_${a}/libcblas.dll.a  $TDLIB

      cp ${CP_FLAGS} ${a}/liblapack.a $TDSLB
      cp ${CP_FLAGS} ${a}/libatlas.a  $TDSLB
      cp ${CP_FLAGS} ${a}/libf77blas.a   $TDSLB
      cp ${CP_FLAGS} ${a}/libcblas.a  $TDSLB
   done
}

   
all() {
  build
  install_pkg
}

main $*
