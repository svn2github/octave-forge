#! /usr/bin/sh

# Name of package
PKG=freetype
# Version of Package
VER=2.3.7
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
URL="http://downloads.sourceforge.net/freetype/freetype-2.3.7.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=""

# header files to be installed
INCLUDE_DIR=""
HEADERS="ft2build.h"
HEADERS2="
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
HEADERS_CONFIG="
ftheader.h
ftoption.h
ftstdlib.h"
HEADERS_CONFIG2="
ftconfig.h
ftmodule.h"

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     CC=${CC} \
     CXX=${CXX} \
     F77=${F77} \
     CPP=${CPP} \
     CPPFLAGS="$CPPFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CFLAGS="$CFLAGS" \
     CXXFLAGS="$CXXFLAGS" \
     LDFLAGS="${LDFLAGS}" \
     --prefix="${PREFIX}"
   )
}

build_pre()
{
   modify_libtool_nolibprefix ${BUILDDIR}/libtool;
}

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/freetype-6.dll    ${BINARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libfreetype.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libfreetype.a     ${STATICLIBRARY_PATH}

   for a in ${INSTALL_HEADERS}; do ${CP} ${CP_FLAGS} ${SRCDIR}/include/$a ${INCLUDE_PATH}; done
   
   if ! [ -e ${INCLUDE_PATH}/freetype ]; then mkdir -v ${INCLUDE_PATH}/freetype; fi
   if ! [ -e ${INCLUDE_PATH}/freetype/config ]; then mkdir -v ${INCLUDE_PATH}/freetype/config; fi
   
   for a in $HEADERS; do 
      ${CP} ${CP_FLAGS} ${SRCDIR}/include/$a ${INCLUDE_PATH}
   done
   
   for a in $HEADERS2; do 
      ${CP} ${CP_FLAGS} ${SRCDIR}/include/freetype/$a ${INCLUDE_PATH}/freetype
   done
   
   for a in $HEADERS_CONFIG; do 
      ${CP} ${CP_FLAGS} ${SRCDIR}/include/freetype/config/$a ${INCLUDE_PATH}/freetype/config
   done
   
   for a in $HEADERS_CONFIG2; do 
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${INCLUDE_PATH}/freetype/config
   done
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/freetype-config         ${BINARY_PATH}
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/GPL.TXT ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/LICENSE.TXT ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/src/pcf/README ${LICENSE_PATH}/${PKG}/README.PCF
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/freetype2.pc ${PKGCONFIGDATA_PATH}
   
   install_post
}

uninstall()
{
   uninstall_pre;
   
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/freetype-6.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfreetype.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libfreetype.a
   
   for a in $HEADERS; do 
      ${RM} ${RM_FLAGS} $a ${INCLUDE_PATH}/$a
   done
   
   for a in $HEADERS2; do 
      ${RM} ${RM_FLAGS} $a ${INCLUDE_PATH}/freetype/$a
   done
   
   for a in $HEADERS_CONFIG; do 
      ${RM} ${RM_FLAGS} $a ${INCLUDE_PATH}/freetype/config/$a
   done
   
   for a in $HEADERS_CONFIG2; do 
      ${RM} ${RM_FLAGS} $a ${INCLUDE_PATH}/freetype/config/$a
   done
   
   rmdir --ignore-fail-on-non-empty ${INCLUDE_PATH}/freetype/config
   rmdir --ignore-fail-on-non-empty ${INCLUDE_PATH}/freetype

   ${RM} ${RM_FLAGS} ${BINARY_PATH}/freetype-config

   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/{GPL.TXT LICENSE.TXT README.PCF}
   
   ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/freetype2.pc
   
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
