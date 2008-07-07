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

DIRS=`ls -1 | sed -ne "/^ARCH_\([A-Za-z0-9]\)/p"`

unpack() { echo $MSG; }

unpack_orig() { echo $MSG; }

mkdirs() { echo $MSG; }

conf() { echo $MSG; }

build()
{
   FLDFLAGS="-Wl,-s"
   export FLDFLAGS
   
   for a in $DIRS; do
      echo "Entering directory .build_$a ..."
      mkdir -pv ".build_$a"
      sed \
		-e "s+@SRCDIR@+${TOPDIR}/$a+" \
		${TOPDIR}/makefile.in > ".build_$a/makefile" 
      make -C ".build_$a" shlibs
   done
}

install() { echo; }

install_pkg()
{
   echo "Installing libraries for the following architectures:"
   echo $DIRS
   
   for a in $DIRS; do
      TDBIN=${PACKAGE_ROOT}/ATLAS/$a/${SHAREDLIB_DEFAULT}
      TDLIB=${PACKAGE_ROOT}/ATLAS/$a/${LIBRARY_DEFAULT}
      TDSLB=${PACKAGE_ROOT}/ATLAS/$a/${STATICLIBRARY_DEFAULT}
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

      cp ${CP_FLAGS} .build_${a}/liblapack.a $TDSLB
      cp ${CP_FLAGS} ${a}/libatlas.a  $TDSLB
      cp ${CP_FLAGS} ${a}/libf77blas.a   $TDSLB
      cp ${CP_FLAGS} ${a}/libcblas.a  $TDSLB
      
      "${SEVENZIP}" $SEVENZIP_FLAGS ATLAS-${VER}-${REL}_$a.7z $TDBIN $TDLIB $TDSLB

   done
}

   
all() {
  build
  install_pkg
}

main $*
