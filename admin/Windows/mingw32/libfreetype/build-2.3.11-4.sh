#! /usr/bin/sh

# Name of package
PKG=freetype
# Version of Package
VER=2.3.11
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

# subdirectory to install heraders to (empty for default)
INCLUDE_DIR=

# Herader files to install
HEADERS_INSTALL="ft2build.h"
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

# pkg-config .pc files to install
PKG_CONFIG_INSTALL="freetype2.pc"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

conf()
{
   # Do not specify --srcdir as freetype's configure script chokes on it...
   conf_pre;
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     CC="$CC $LIBGCCLDFLAGS"\
     CXX="$CXX $LIBGCCLDFLAGS" \
     F77="$F77 $LIBGCCLDFLAGS"\
     CPP=$CPP \
     AR=$AR \
     RANLIB=$RANLIB \
     RC=$RC \
     STRIP=$STRIP \
     LD=$LD \
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CPPFLAGS="$CPPFLAGS" \
     LDFLAGS="${LDFLAGS}" \
     CXXLIBS="${CXXLIBS}" \
     --prefix=${PREFIX}
   )
   touch ${BUILDDIR}/have_configure
   modify_libtool_nolibprefix ${BUILDDIR}/libtool
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/freetype-6.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libfreetype.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libfreetype.a ${STATICLIB_PATH}
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   if ! [ -e ${INCLUDE_PATH}/freetype ]; then mkdir -v ${INCLUDE_PATH}/freetype; fi
   if ! [ -e ${INCLUDE_PATH}/freetype/config ]; then mkdir -v ${INCLUDE_PATH}/freetype/config; fi

   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/include/$a ${INCLUDE_PATH}
   done
   
   for a in $HEADERS2_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/include/freetype/$a ${INCLUDE_PATH}/freetype
   done
   
   for a in $HEADERS3_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/include/freetype/config/$a ${INCLUDE_PATH}/freetype/config
   done
   
   for a in $HEADERS4_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${INCLUDE_PATH}/freetype/config
   done
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/freetype-config         ${BINARY_PATH}
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/GPL.txt ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/LICENSE.txt ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/src/pcf/README ${LICENSE_PATH}/${PKG}/README.PCF
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/freetype-6.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfreetype.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libfreetype.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   for a in $HEADERS2_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/freetype/$a
   done
   
   for a in $HEADERS3_INSTALL $HEADERS4_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/freetype/config/$a
   done
   
   rmdir --ignore-fail-on-non-empty ${INCLUDE_PATH}/freetype/config
   rmdir --ignore-fail-on-non-empty ${INCLUDE_PATH}/freetype
   
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/freetype-config
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/GPL.txt
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/LICENSE.txt
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/README.PCF
   
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
