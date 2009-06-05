#! /usr/bin/sh

# Name of package
PKG=ginac
# Version of Package
VER=1.5.1
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
URL="ftp://ftpthep.physik.uni-mainz.de/pub/GiNaC/ginac-1.5.1.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=""

# Additional DIFF Flags for generating diff file
#DIFF_FLAGS="-x *.def"

# header files to be installed
INSTALL_HEADERS="
ginac.h add.h archive.h assertion.h basic.h class_info.h \
clifford.h color.h constant.h container.h ex.h excompiler.h expair.h expairseq.h \
exprseq.h fail.h factor.h fderivative.h flags.h function.h hash_map.h idx.h indexed.h \
inifcns.h integral.h lst.h matrix.h mul.h ncmul.h normal.h numeric.h operators.h \
power.h print.h pseries.h ptr.h registrar.h relational.h structure.h \
symbol.h symmetry.h tensor.h version.h wildcard.h \
parser/parser.h \
parser/parse_context.h"
INCLUDE_DIR=include/ginac

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

# disable built-in rules, since make fails when restarting an 
# interrupted build process trying to call "m2c", and the same
# when doing make check ??
#MAKE_FLAGS="-r"

# == make check ==
#
#

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=../${SRCDIR} \
     CC="${CC} $LIBGCCLDFLAGS" \
     CXX="${CXX} $LIBGCCLDFLAGS" \
     F77="${F77} $LIBGCCLDFLAGS" \
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXLIBS="$CXXLIBS" \
     LDFLAGS="${LDFLAGS}" \
     --prefix="${PREFIX}" \
     --enable-shared
   )
}

build_pre()
{
   modify_libtool_all ${BUILDDIR}/libtool
}

install()
{
   install_pre;
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/ginac/ginac.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/ginac/.libs/libginac.a ${STATICLIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/ginac/libginac.dll.a ${LIBRARY_PATH}
   
   for a in ${INSTALL_HEADERS}; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/ginac/$a ${INCLUDE_PATH}
   done
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/ginac.pc ${PKGCONFIGDATA_PATH}
   
   install_post
}

uninstall()
{
   uninstall_pre;

   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/ginac.dll
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libginac.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libginac.dll.a
   
   for a in ${INSTALL_HEADERS}; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   
   ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/ginac.pc
   
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
