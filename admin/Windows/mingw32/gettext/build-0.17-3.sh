#! /usr/bin/sh

# Name of package
PKG=gettext
# Version of Package
VER=0.17
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
URL="http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/gettext-0.17.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=""
# header files to be installed
INSTALL_HEADERS="libintl.h"

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

echo ${PREFIX}

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
  ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure --srcdir=../${SRCDIR} \
    CC=${CC} \
    CXX=${CXX} \
    F77=${F77} \
    CPP=${CPP} \
    CPPFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    --disable-java \
    --disable-native-java \
    --disable-csharp \
    --enable-relocatable \
    --disable-openmp \
    --disable-largefile \
    --enable-static \
    --enable-shared \
    --prefix=${PREFIX} \
    --disable-threads

#    --with-libiconv-prefix=/opt/win_iconv

  )
}

build_pre()
{
   modify_libtool_all ${BUILDDIR}/gettext-runtime/libtool
   modify_libtool_all ${BUILDDIR}/gettext-tools/libtool
}

build()
{
   build_pre;
   
   ( cd ${BUILDDIR}/gettext-runtime && make all )
#   ( cd ${BUILDDIR}/gettext-tools && make )
   
   build_post;
}

install()
{
   install_pre;
   
   mkdir -v ${LICENSE_PATH}/${PKG}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gettext-runtime/intl/.libs/intl.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gettext-runtime/intl/.libs/libintl.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gettext-runtime/intl/.libs/libintl.a ${STATICLIBRARY_PATH}
   
   for a in ${INSTALL_HEADERS}; do ${CP} ${CP_FLAGS} ${BUILDDIR}/gettext-runtime/intl/$a ${INCLUDE_PATH}; done
   
   # install license information
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/gettext-runtime/COPYING ${LICENSE_PATH}/${PKG}/COPYING.gettext-runtime
   
   install_devbin;
   
   install_post;
}

# EXE_TOOLS="msgfmt.exe"

install_devbin()
{
   mkdir -vp ${DEVBIN_PATH}
   
   # Install a stub 'msgfmt' script. GLIB check for it, but obviously never
   # uses it. So we can skip the time-consuming build of gettext-tools
   ${CP} ${CP_FLAGS} ${TOPDIR}/msgfmt ${DEVBIN_PATH}
   
#   ${CP} ${CP_FLAGS} ${BUILDDIR}/gettext-tools/gnulib-lib/.libs/gettextlib.dll ${DEVBIN_PATH}
#   ${CP} ${CP_FLAGS} ${BUILDDIR}/gettext-tools/src/.libs/gettextsrc.dll        ${DEVBIN_PATH}
   
#   for a in ${EXE_TOOLS}; do ${CP} ${CP_FLAGS} ${BUILDDIR}/gettext-tools/src/.libs/$a ${DEVBIN_PATH}; done
   
}

uninstall()
{
   uninstall_pre;
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/intl.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libintl.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libintl.a
   
   for a in ${INSTALL_HEADERS}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
   
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING.gettext-runtime
   
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
