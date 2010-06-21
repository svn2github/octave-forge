#! /usr/bin/sh

# Name of package
PKG=freetype
# Version of Package
VER=2.3.12
# Release of (this patched) package
REL=5
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.bz2
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://downloads.sourceforge.net/project/freetype/freetype2/$VER/freetype-$VER.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=
# Any extra flags to pass make to
MAKE_XTRA=

# Header files to install
HEADERS_INSTALL="include/ft2build.h"
HEADERS_BUILD_INSTALL=
HEADERS2_INSTALL="
freetype.h
ftbbox.h
ftbdf.h
ftbitmap.h
ftcache.h
ftchapters.h
ftcid.h
fterrdef.h
fterrors.h
ftgasp.h
ftglyph.h
ftgxval.h
ftgzip.h
ftimage.h
ftincrem.h
ftlcdfil.h
ftlist.h
ftlzw.h
ftmac.h
ftmm.h
ftmodapi.h
ftmoderr.h
ftotval.h
ftoutln.h
ftpfr.h
ftrender.h
ftsizes.h
ftsnames.h
ftstroke.h
ftsynth.h
ftsystem.h
fttrigon.h
fttypes.h
ftwinfnt.h
ftxf86.h
t1tables.h
ttnameid.h
tttables.h
tttags.h
ttunpat.h"
HEADERS3_INSTALL="
ftheader.h
ftoption.h
ftstdlib.h"
HEADERS4_INSTALL="
ftconfig.h
ftmodule.h"

# install subdirectory below $PREFIX/$INC_DIR (if any)
INC_SUBDIR=

# License file(s) to install
LICENSE_INSTALL=

# pkg-config .pc files to install
PKG_CONFIG_INSTALL="freetype2.pc"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc45_common.sh

# Directory the lib is built in (set this *after* loading gcc45_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

conf_post()
{
   modify_libtool_nolibprefix ${BUILDDIR}/libtool
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/freetype-6.dll    $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libfreetype.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libfreetype.a     $PREFIX/$STATICLIB_DIR
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/freetype-config         $PREFIX/$BIN_DIR
   
   if ! [ -e ${INCLUDE_PATH}/freetype ]; then mkdir -v $PREFIX/$INC_DIR/freetype; fi
   if ! [ -e ${INCLUDE_PATH}/freetype/config ]; then mkdir -v $PREFIX/$INC_DIR/freetype/config; fi

   for a in $HEADERS2_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/include/freetype/$a $PREFIX/$INC_DIR/freetype
   done
   
   for a in $HEADERS3_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/include/freetype/config/$a $PREFIX/$INC_DIR/freetype/config
   done
   
   for a in $HEADERS4_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a $PREFIX/$INC_DIR/freetype/config
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/GPL.txt     $PREFIX/$LIC_DIR/$PKG
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/LICENSE.txt $PREFIX/$LIC_DIR/$PKG
   ${CP} ${CP_FLAGS} ${SRCDIR}/src/pcf/README   $PREFIX/$LIC_DIR/$PKG/README.PCF

   install_common;
   install_post;
}

install_strip()
{
   install
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/freetype-6.dll 
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/freetype-6.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libfreetype.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libfreetype.a
   
   # Uninstall headers
   for a in $HEADERS2_INSTALL; do
      ${RM} ${RM_FLAGS} $PREFIX/$INC_DIR/freetype/$a
   done
   
   for a in $HEADERS3_INSTALL $HEADERS4_INSTALL; do
      ${RM} ${RM_FLAGS} $PREFIX/$INC_DIR/freetype/config/$a
   done
   
   rmdir --ignore-fail-on-non-empty $PREFIX/$INC_DIR/freetype/config
   rmdir --ignore-fail-on-non-empty $PREFIX/$INC_DIR/freetype
   
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/freetype-config
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} $PREFIX/$LIC_DIR/$PKG/GPL.txt
   ${RM} ${RM_FLAGS} $PREFIX/$LIC_DIR/$PKG/LICENSE.txt
   ${RM} ${RM_FLAGS} $PREFIX/$LIC_DIR/$PKG/README.PCF
   
   uninstall_common;
   uninstall_post;
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
