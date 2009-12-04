#! /usr/bin/sh

# Name of package
PKG=jogl
# Version of Package
VER=1.1.1
# Release of (this patched) package
REL=4
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}-windows-i586.zip
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://download.java.net/media/jogl/builds/archive/jsr-231-1.1.1/jogl-1.1.1-windows-i586.zip"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}-windows-i586
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=
# Any extra flags to pass make to
MAKE_XTRA=

# subdirectory to install heraders to (empty for default)
INCLUDE_DIR=

# Herader files to install
HEADERS_INSTALL=""

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# Distibuted binary files to eb installed
DIST_FILES="gluegen-rt.dll gluegen-rt.jar jogl.dll jogl.jar jogl_awt.dll jogl_cg.dll"

# == override resp. specify build actions ==

conf()
{
   echo This package is not configured...
}

mkdirs()
{
   echo This package is not configured...
}

build()
{
   echo This package is not built...
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   for a in $DIST_FILES; do
      ${CP} ${SRCDIR}/lib/$a ${BINARY_PATH};
   done
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}/`basename $a`
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYRIGHT.txt  ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/LICENSE-JOGL-${VER}.txt ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/README.txt     ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/Userguide.html ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/CHANGELOG.txt  ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   for a in $DIST_FILES; do
      ${RM} ${RM_FLAGS} ${BINARY_PATH}/$a
   done
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/`basename $a`
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYRIGHT.txt
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/LICENSE-JOGL-${VER}.txt
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/README.txt
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/Userguide.html
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/CHANGELOG.txt
   
   uninstall_post;
}

all() {
  download
  unpack
  install
}

main $*
