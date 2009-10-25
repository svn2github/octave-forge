#! /usr/bin/sh

# Name of package
PKG=ftgl
# Version of Package
VER=2.1.3-rc5
# Release of (this patched) package
REL=4
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.bz2
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://downloads.sourceforge.net/ftgl/ftgl-2.1.3-rc5.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=ftgl-2.1.3~rc5
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=makefile.mingw32
# Any extra flags to pass make to
MAKE_XTRA=

# subdirectory to install heraders to (empty for default)
INCLUDE_DIR=include/FTGL

# Herader files to install
HEADERS_INSTALL="
FTBBox.h
FTBitmapGlyph.h
FTBuffer.h
FTBufferFont.h
FTBufferGlyph.h
FTExtrdGlyph.h
FTFont.h
ftgl.h
FTGLBitmapFont.h
FTGLExtrdFont.h
FTGLOutlineFont.h
FTGLPixmapFont.h
FTGLPolygonFont.h
FTGLTextureFont.h
FTGlyph.h
FTLayout.h
FTOutlineGlyph.h
FTPixmapGlyph.h
FTPoint.h
FTPolyGlyph.h
FTSimpleLayout.h
FTTextureGlyph.h"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

conf()
{
   conf_pre;
   substvars ${SRCDIR}/makefile.mingw32.in ${BUILDDIR}/makefile.mingw32
   ${CP} ${CP_FLAGS} ${SRCDIR}/msvc/config.h ${BUILDDIR}/config.h
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/ftgl.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libftgl.dll.a ${LIBRARY_PATH}
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/src/FTGL/$a ${INCLUDE_PATH}
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/ftgl.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libftgl.dll.a
   # ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libz.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   
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
