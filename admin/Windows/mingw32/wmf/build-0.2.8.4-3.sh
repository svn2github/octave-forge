#! /usr/bin/sh

# Name of package
PKG=libwmf
# Version of Package
VER=0.2.8.4
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
URL="http://downloads.sourceforge.net/wvware/libwmf-0.2.8.4.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
#MAKEFILE=Makefile

# Patch flags
DIFF_FLAGS="-x autom4te.cache"

# Header files to install from source directory
INCLUDE_DIR="include/libwmf"
HEADERS="api.h color.h defs.h fund.h ipa.h types.h macro.h font.h canvas.h \
foreign.h eps.h fig.h svg.h gd.h x.h"

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

# CREATING THE EXPORT FILES
#
#  echo LIBRARY libwmflite-0-2-7.dll>libwmflite.def
#  echo EXPORTS>>libwmflite.def
#  pexports.exe libwmflite-0-2-7.dll | grep ^wmf | grep -v DATA >> libwmflite.def
#
#  echo LIBRARY libwmf-0-2-7.dll>libwmf.def
#  echo EXPORTS>>libwmf.def
#  pexports.exe libwmf-0-2-7.dll | grep ^wmf | grep -v DATA >> libwmf.def

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
     CPPFLAGS="${GCC_ARCH_FLAGS}" \
     CFLAGS="$CFLAGS ${GCC_OPT_FLAGS} -Wall" \
     --prefix="${PREFIX}" \
     --enable-shared \
     --enable-static
     )
}

install()
{
   install_pre;
   
#   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libwmf-0-2-7.dll ${SHAREDLIB_PATH}
#   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libwmf.a ${STATICLIBRARY_PATH}
#   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libwmf.dll.a ${LIBRARY_PATH}

   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libwmflite-0-2-7.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libwmflite.a ${STATICLIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libwmflite.dll.a ${LIBRARY_PATH}

   ${CP} ${CP_FLAGS} ${BUILDDIR}/libwmf-config ${BINARY_PATH}
   
   for a in ${HEADERS}; do ${CP} ${CP_FLAGS} ${SRCDIR}/include/libwmf/$a ${INCLUDE_PATH}; done

   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
#   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/libwmf-0-2-7.dll
#   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libwmf.a
#   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libwmf.dll.a
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/libwmflite-0-2-7.dll
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libwmflite.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libwmflite.dll.a
   
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/libwmf-config
   
   for a in ${HEADERS_SRC}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
   
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/README

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
