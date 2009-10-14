#! /usr/bin/sh

# Name of package
PKG=arpack
# Version of Package
VER=96
# Release of (this patched) package
REL=4
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKG}${VER}.tar.gz
SRCPATCHFILE=patch.tar.gz
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://www.caam.rice.edu/software/ARPACK/SRC/arpack96.tar.gz http://www.caam.rice.edu/software/ARPACK/SRC/patch.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=makefile.mingw32
# Any extra flags to pass make to
MAKE_XTRA=

# subdirectory to install heraders to (empty for default)
INCLUDE_DIR=

# Herader files to install
HEADERS_INSTALL=

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x *.def"

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

unpack()
{
  unpack_pre;
  
  ${TAR} ${TAR_FLAGS} -xf ${TOPDIR}/${SRCFILE}
  ${TAR} ${TAR_FLAGS} -xf ${TOPDIR}/${SRCPATCHFILE}
  mv ARPACK ARPACK-${VER}
  
  unpack_post;
}

unpack_orig()
{
  unpack_orig_pre;
  
  mkdir tmp && cd tmp
  ${TAR} ${TAR_FLAGS} -xf ${TOPDIR}/${SRCFILE}
  ${TAR} ${TAR_FLAGS} -xf ${TOPDIR}/${SRCPATCHFILE}
  mv ARPACK ARPACK-${VER}
  mv ARPACK-${VER} ../${SRCDIR_ORIG}
  cd .. && rmdir tmp
  
  unpack_orig_post;
}

conf()
{
   conf_pre;
   substvars ${SRCDIR}/${MAKEFILE} ${BUILDDIR}/${MAKEFILE}
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/arpack.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libarpack.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libarpack.a ${STATICLIB_PATH}
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}
   done
   
   # Install license file
   # ${CP} ${CP_FLAGS} ${SRCDIR}/README ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/arpack.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libarpack.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libarpack.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   # Uninstall license file
   # ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/README
   
   uninstall_post;
}

check()
{
   check_pre;
   
   ( cd ${BUILDDIR} && make -f ${MAKEFILE} test )
   ( cd ${BUILDDIR} && make -f ${MAKEFILE} testdll )
   
   check_post;
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
