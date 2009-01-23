#! /usr/bin/sh

# Name of package
PKG=ftgl
# Version of Package
VER=2.1.3-rc5
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
URL="http://downloads.sourceforge.net/ftgl/ftgl-2.1.3-rc5.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=ftgl-2.1.3~rc5
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=makefile.mingw32

# Additional DIFF Flags for generating diff file
#DIFF_FLAGS="-x *.def"

# header files to be installed
INSTALL_HEADERS="
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
INCLUDE_DIR=include/FTGL

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

conf()
{
   substvars ${SRCDIR}/makefile.mingw32.in ${BUILDDIR}/makefile.mingw32
   ${CP} ${CP_FLAGS} ${SRCDIR}/msvc/config.h ${BUILDDIR}/config.h
}

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/ftgl.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libftgl.dll.a ${LIBRARY_PATH}
   
   for a in $INSTALL_HEADERS; do
      ${CP} ${CP_FLAGS} $SRCDIR/src/FTGL/$a ${INCLUDE_PATH}/$a
   done
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/ftgl.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libftgl.dll.a

   for a in $INSTALL_HEADERS; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   
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
