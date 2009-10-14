#! /usr/bin/sh

# Name of package
PKG=pango
# Version of Package
VER=1.25.6
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
URL="http://ftp.gnome.org/pub/GNOME/sources/pango/1.25/pango-1.25.6.tar.bz2"

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
INCLUDE_DIR=include/pango

# Herader files to install
HEADERS_INSTALL="
pango-attributes.h
pango-bidi-type.h
pango-break.h
pango-context.h
pango-coverage.h
pango-engine.h
pango-font.h
pango-fontmap.h
pango-fontset.h
pango-glyph-item.h
pango-glyph.h
pango-gravity.h
pango-item.h
pango-language.h
pango-layout.h
pango-matrix.h
pango-modules.h
pango-ot.h
pango-renderer.h
pango-script.h
pango-tabs.h
pango-types.h
pango-utils.h
pango.h
pangocairo.h
pangofc-decoder.h
pangofc-font.h
pangofc-fontmap.h
pangoft2.h
pangowin32.h"

HEADERSBUILD_INSTALL="
pango-features.h
pango-enum-types.h"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL="pango.pc pangocairo.pc pangoft2.pc pangowin32.pc"

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
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC="${CC} $LIBGCCLDFLAGS" \
     CXX="${CXX} $LIBGCCLDFLAGS" \
     F77="${F77} $LIBGCCLDFLAGS" \
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
     --prefix=${PREFIX} \
     --without-x \
     --enable-explicit-deps=no \
     --with-included-modules=yes
   )
   touch ${BUILDDIR}/have_configure
   modify_libtool_nolibprefix ${BUILDDIR}/libtool
   touch -r ${BUILDDIR}/config.lt ${BUILDDIR}/libtool
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/pango-1.0-0.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/libpango-1.0.dll.a ${LIBRARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/pangocairo-1.0-0.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/libpangocairo-1.0.dll.a ${LIBRARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/pangoft2-1.0-0.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/libpangoft2-1.0.dll.a ${LIBRARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/pangowin32-1.0-0.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/libpangowin32-1.0.dll.a ${LIBRARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/pango-querymodules.exe    ${BINARY_PATH}

   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/pango/$a ${INCLUDE_PATH}/`basename $a`
   done
   
   for a in $HEADERSBUILD_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/$a ${INCLUDE_PATH}/`basename $a`
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/pango-1.0-0.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libpango-1.0.dll.a
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/pangocairo-1.0-0.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libpangocairo-1.0.dll.a
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/pangoft2-1.0-0.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libpangoft2-1.0.dll.a
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/pangowin32-1.0-0.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libpangowin32-1.0.dll.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL $HEADERSBUILD_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/`basename $a`
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   
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
