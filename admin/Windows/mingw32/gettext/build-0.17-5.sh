#! /usr/bin/sh

# Name of package
PKG=gettext
# Version of Package
VER=0.17
# Release of (this patched) package
REL=5
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.gz
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/gettext-$VER.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=
# Any extra flags to pass make to
MAKE_XTRA="CPP=cpp"

# Header files to install
HEADERS_INSTALL=
HEADERS_BUILD_INSTALL="gettext-runtime/intl/libintl.h"

# install subdirectory below $PREFIX/$INC_DIR (if any)
INC_SUBDIR=

# License file(s) to install
LICENSE_INSTALL="COPYING"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x *configure -x config.h.in"

# load common functions
source ../gcc45_common.sh

# Directory the lib is built in (set this *after* loading gcc45_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

conf_pre()
{
    CONFIGURE_XTRA_ARGS="\
     --disable-java \
     --disable-native-java \
     --disable-csharp \
     --enable-relocatable \
     --disable-openmp \
     --disable-largefile \
     --enable-static \
     --enable-shared \
     --disable-threads"
   
}

conf_post()
{
   touch ${BUILDDIR}/gettext-runtime/have_configure
   modify_libtool_all ${BUILDDIR}/gettext-runtime/libtool
}

build()
{
   build_pre;
   ( cd ${BUILDDIR}/gettext-runtime && make_common )
   build_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gettext-runtime/intl/.libs/intl.dll    $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gettext-runtime/intl/.libs/libintl.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gettext-runtime/intl/.libs/libintl.dll.a $PREFIX/$STATICLIB_DIR
   
   install_common;
   install_post;
}

install_strip()
{
   install
   $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/intl.dll
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/intl.dll
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libintl.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/libintl.dll.a
   
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
