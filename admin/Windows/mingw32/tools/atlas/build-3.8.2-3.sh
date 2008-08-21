#! /usr/bin/sh

# Name of package
PKG=atlas
# Version of Package
VER=3.8.2
# Release of (this patched) package
REL=3
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
URL="http://downloads.sourceforge.net/math-atlas/atlas3.8.2.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
#MAKEFILE=win32/Makefile.gcc

source ../../gcc43_common.sh
source ../../gcc43_pkg_version.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

echo ${PREFIX}

MSG="Building ATLAS libraries must be done using CYGWIN!";

DIRS=`ls -1 | sed -ne "/^ARCH_\([A-Za-z0-9]\+\)_atlas-${VER}_gcc${GCC_VER}/p"`
ARCHS=`ls -1 | sed -ne "s/^\(ARCH_[A-Za-z0-9]\+\)_atlas-${VER}_gcc${GCC_VER}/\1/p"`

unpack() { echo $MSG; }

unpack_orig() { echo $MSG; }

mkdirs() { echo $MSG; }

conf() { echo $MSG; }

build()
{
   FLDFLAGS="-Wl,-s"
   export FLDFLAGS
   
   for a in $DIRS; do
      BDIR=${BUILDDIR}_$a
      echo "Entering directory $BDIR ..."
      mkdir -pv $BDIR
      sed \
		-e "s+@SRCDIR@+${TOPDIR}/$a+" \
		${TOPDIR}/makefile.in > "${BDIR}/makefile" 
      make -C $BDIR shlibs
   done
}

install() { echo; }

install_pkg()
{
   echo "Installing libraries for the following architectures:"
   echo $ARCHS
   
   for a in $DIRS; do
      ARCH=`echo $a | sed -e "s/\(ARCH_[a-zA-Z0-9]\+\).*/\1/"`
      
      BDIR=${BUILDDIR}_$a
      TDBIN=${PACKAGE_ROOT}/ATLAS/${ARCH}/${SHAREDLIB_DEFAULT}
      TDLIB=${PACKAGE_ROOT}/ATLAS/${ARCH}/${LIBRARY_DEFAULT}
      TDSLB=${PACKAGE_ROOT}/ATLAS/${ARCH}/${STATICLIBRARY_DEFAULT}
      mkdir -vp $TDBIN
      mkdir -vp $TDLIB
      mkdir -vp $TDSLB
      cp ${CP_FLAGS} ${BDIR}/lapack.dll $TDBIN
      cp ${CP_FLAGS} ${BDIR}/atlas.dll  $TDBIN
      cp ${CP_FLAGS} ${BDIR}/blas.dll   $TDBIN
      cp ${CP_FLAGS} ${BDIR}/cblas.dll  $TDBIN

      cp ${CP_FLAGS} ${BDIR}/liblapack.dll.a $TDLIB
      cp ${CP_FLAGS} ${BDIR}/libatlas.dll.a  $TDLIB
      cp ${CP_FLAGS} ${BDIR}/libblas.dll.a   $TDLIB
      cp ${CP_FLAGS} ${BDIR}/libcblas.dll.a  $TDLIB

      cp ${CP_FLAGS} ${BDIR}/liblapack.a $TDSLB
      cp ${CP_FLAGS} ${a}/libatlas.a  $TDSLB
      cp ${CP_FLAGS} ${a}/libf77blas.a   $TDSLB
      cp ${CP_FLAGS} ${a}/libcblas.a  $TDSLB
      
      #"${SEVENZIP}" $SEVENZIP_FLAGS ATLAS-${VER}-${REL}_$a.7z $TDBIN $TDLIB $TDSLB

   done
}

   
all() {
  build
  install_pkg
}

main $*
