#! /usr/bin/sh

# Name of package
PKG=pango
# Version of Package
VER=1.22.2
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
URL="http://ftp.gnome.org/pub/GNOME/sources/pango/1.22/pango-1.22.2.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
# MAKEFILE=win32/Makefile.gcc

# header files to be installed
HEADERS="
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
HEADERS2="
pango-features.h
pango-enum-types.h"
INCLUDE_DIR=include/pango

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

echo ${PREFIX}

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC=${CC} \
     CXX=${CXX} \
     F77=${F77} \
     CPP=${CPP} \
     LDFLAGS="${LDFLAGS}" \
     CPPFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS}" \
     CFLAGS="$CFLAGS" \
     CXXFLAGS="$CXXFLAGS" \
     LIBS="" \
     --prefix="${PREFIX}" \
     --enable-shared  \
     --disable-gtk-doc \
     --without-x \
     --enable-explicit-deps=no \
     --with-included-modules=yes
     )
}

PCFILES="pango.pc pangocairo.pc pangoft2.pc pangowin32.pc"

install()
{
   install_pre;
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/libpango-1.0-0.dll    ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/libpango-1.0.dll.a    ${LIBRARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/libpangocairo-1.0-0.dll    ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/libpangocairo-1.0.dll.a    ${LIBRARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/libpangoft2-1.0-0.dll    ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/libpangoft2-1.0.dll.a    ${LIBRARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/libpangowin32-1.0-0.dll    ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/.libs/libpangowin32-1.0.dll.a    ${LIBRARY_PATH}
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   for a in $HEADERS; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/pango/$a ${INCLUDE_PATH}
   done
   
   for a in $HEADERS2; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/pango/$a ${INCLUDE_PATH}
   done
   
   for a in $PCFILES; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   
   install_post
}

  
uninstall()
{
   uninstall_pre;
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/libcairo-2.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libcairo.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libcairo.a
   
   for a in $HEADERS; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   for a in $HEADERS2; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   for a in $PCFILES; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
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
