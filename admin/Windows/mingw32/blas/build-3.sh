#! /usr/bin/sh

# Name of package
PKG=blas
# Version of Package
VER=
# Release of (this patched) package
REL=3
# Name&Version of Package
PKGVER=${PKG}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}.tgz
TAR_TYPE=z
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="http://www.netlib.org/blas/blas.tgz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig
## Directory the lib is built in
#BUILDDIR=${SRCDIR}

# Make file to use
MAKEFILE=makefile.mingw32

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x *.def"

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

# BLAS is packed NOT in a subdirectory, so we must manually create one...
unpack_pre()
{ 
   if [ -d ${SRCDIR} ]; then
      echo removing ${SRCDIR} ...
      rm -rf ${SRCDIR}
   fi
   mkdir ${SRCDIR} && cd ${SRCDIR}
}
unpack_post() { cd ..; }

conf()
{
   substvars ${SRCDIR}/${MAKEFILE} ${BUILDDIR}/${MAKEFILE}
}

srcpkg()
{
   "${SEVENZIP}" ${SEVENZIP_FLAGS} ${SRCPKG_PATH}/${FULLPKG}-src.7z ${SRCFILE} ${PATCHFILE} build-${REL}.sh
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
