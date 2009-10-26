#! /usr/bin/sh

# Name of package
PKG=ginac
# Version of Package
VER=1.5.3
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
URL="ftp://ftpthep.physik.uni-mainz.de/pub/GiNaC/ginac-1.5.3.tar.bz2"

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
INCLUDE_DIR=include/ginac

# Herader files to install
HEADERS_INSTALL="
ginac.h add.h archive.h assertion.h basic.h class_info.h \
clifford.h color.h constant.h container.h ex.h excompiler.h expair.h expairseq.h \
exprseq.h fail.h factor.h fderivative.h flags.h function.h hash_map.h idx.h indexed.h \
inifcns.h integral.h lst.h matrix.h mul.h ncmul.h normal.h numeric.h operators.h \
power.h print.h pseries.h ptr.h registrar.h relational.h structure.h \
symbol.h symmetry.h tensor.h version.h wildcard.h \
parser/parser.h \
parser/parse_context.h"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL="ginac.pc"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

MAKE_XTRA=" CXXLIBS=$CXXLIBS"

conf()
{
   conf_pre;
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC="$CC $LIBGCCLDFLAGS" \
     CXX="$CXX $LIBGCCLDFLAGS" \
     F77="$F77 $LIBGCCLDFLAGS" \
     CPP=$CPP \
     AR=$AR \
     RANLIB=$RANLIB \
     RC=$RC \
     STRIP=$STRIP \
     LD=$LD \
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CPPFLAGS="$CPPFLAGS" \
     LDFLAGS="${LDFLAGS} -Wl,--allow-multiple-definition" \
     CXXLIBS="${CXXLIBS}" \
     --prefix=${PREFIX} \
     --enable-shared
   )
   touch ${BUILDDIR}/have_configure
   modify_libtool_all ${BUILDDIR}/libtool
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/ginac/ginac.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/ginac/libginac.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/ginac/.libs/libginac.a ${STATICLIB_PATH}
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/ginac/$a ${INCLUDE_PATH}/`basename $a`
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/ginac.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libginac.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libginac.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
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
