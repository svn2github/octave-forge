#! /usr/bin/sh

# Name of package
PKG=libiconv
# Version of Package
VER=1.12
# Release of (this patched) package
REL=3
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}.tar.gz
TAR_TYPE=z
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="http://gd.tuwien.ac.at/gnu/gnusrc/libiconv/libiconv-1.12.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd -W | sed -e 's+\([a-zA-Z]\):/+/\1/+'`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=""

# Additional DIFF Flags for generating diff file
#DIFF_FLAGS="-x *.def"

# header files to be installed
#INSTALL_HEADERS=""

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=../${SRCDIR} \
     CC="${CC} $LIBGCCLDFLAGS" \
     CXX="${CXX} $LIBGCCLDFLAGS" \
     F77="${F77} $LIBGCCLDFLAGS" \
     CFLAGS="$CFLAGS -Wall" \
     CXXFLAGS="$CXXFLAGS -Wall" \
     LDFLAGS="${LDFLAGS}" \
     --prefix="${PREFIX}" \
     --enable-static \
     --enable-shared \
     --enable-relocatable
   )
}

build_pre()
{
   modify_libtool_all ${BUILDDIR}/libtool
   modify_libtool_all ${BUILDDIR}/libcharset/libtool
}

install()
{
   install_pre;
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/.libs/iconv.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/.libs/libiconv.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/.libs/libiconv.a ${STATICLIBRARY_PATH}

   ${CP} ${CP_FLAGS} ${BUILDDIR}/libcharset/lib/.libs/charset.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libcharset/lib/.libs/libcharset.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libcharset/lib/.libs/libcharset.a ${STATICLIBRARY_PATH}

   ${CP} ${CP_FLAGS} ${BUILDDIR}/include/iconv.h ${INCLUDE_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libcharset/include/libcharset.h ${INCLUDE_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libcharset/include/localcharset.h ${INCLUDE_PATH}
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING     ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING.LIB ${LICENSE_PATH}/${PKG}
   
   install_post;
   
}

uninstall()
{
   uninstall_pre;
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/{iconv.dll, charset.dll}
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/{libiconv.dll.a, libcharset.dll.a}
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/{libiconv.a, libcharset.a}
   
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/libiconv.h
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/libcharset.h
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/localcharset.h
   
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING.LIB
   
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

