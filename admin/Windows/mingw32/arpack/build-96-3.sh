#! /usr/bin/sh

# Name of package
PKG=arpack
# Version of Package
VER=96
# Release of (this patched) package
REL=3
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKG}${VER}.tar.gz
SRCPATCHFILE=patch.tar.gz
TAR_TYPE=z
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="http://www.caam.rice.edu/software/ARPACK/SRC/arpack96.tar.gz
http://www.caam.rice.edu/software/ARPACK/SRC/patch.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=makefile.mingw32

# Additional DIFF Flags for generating diff file
#DIFF_FLAGS="-x *.def"

# header files to be installed
INSTALL_HEADERS=""
INCLUDE_DIR=include/glpk

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

unpack()
{
  ${TAR} -${TAR_TYPE} -${TAR_FLAGS} ${TOPDIR}/${SRCFILE}
  ${TAR} -${TAR_TYPE} -${TAR_FLAGS} ${TOPDIR}/${SRCPATCHFILE}
  mv ARPACK ARPACK-${VER}
}

conf()
{
   substvars ${SRCDIR}/makefile.mingw32.in ${BUILDDIR}/makefile.mingw32
}

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/arpack.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libarpack.dll.a ${LIBRARY_PATH}
   
#   mkdir -vp ${LICENSE_PATH}/${PKG}
#   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post
}

uninstall()
{
   uninstall_pre;
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/arpack.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libarpack.dll.a
   
   uninstall_post;
}

all()
{
   download
   unpack
   applypatch
   mkdirs
   conf
   build
   install
}

main $*
