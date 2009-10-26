#! /usr/bin/sh

# Name of package
PKG=cln
# Version of Package
VER=1.3.0
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
URL="http://www.ginac.de/CLN/cln-1.3.0.tar.bz2"

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
INCLUDE_DIR=include/cln

# Herader files to install
HEADERS_INSTALL="
cln/SV_real.h \
cln/GV_integer.h \
cln/floatformat.h \
cln/lfloat.h \
cln/null_ring.h \
cln/io.h \
cln/ring.h \
cln/V.h \
cln/GV.h \
cln/GV_number.h \
cln/complex_io.h \
cln/condition.h \
cln/integer_ring.h \
cln/dfloat_io.h \
cln/random.h \
cln/SV_ringelt.h \
cln/ffloat_io.h \
cln/float_class.h \
cln/cln.h \
cln/ffloat_class.h \
cln/float.h \
cln/string.h \
cln/lfloat_io.h \
cln/malloc.h \
cln/lfloat_class.h \
cln/number_io.h \
cln/numtheory.h \
cln/object.h \
cln/proplist.h \
cln/univpoly_rational.h \
cln/univpoly_real.h \
cln/output.h \
cln/real_io.h \
cln/ffloat.h \
cln/sfloat_io.h \
cln/timing.h \
cln/SV_number.h \
cln/complex_ring.h \
cln/univpoly_complex.h \
cln/version.h \
cln/rational.h \
cln/rational_class.h \
cln/rational_io.h \
cln/types.h \
cln/univpoly_modint.h \
cln/modinteger.h \
cln/rational_ring.h \
cln/univpoly_integer.h \
cln/number.h \
cln/GV_complex.h \
cln/GV_modinteger.h \
cln/GV_real.h \
cln/SV_complex.h \
cln/SV_integer.h \
cln/complex.h \
cln/exception.h \
cln/univpoly.h \
cln/SV_rational.h \
cln/complex_class.h \
cln/real.h \
cln/symbol.h \
cln/dfloat_class.h \
cln/modules.h \
cln/real_ring.h \
cln/float_io.h \
cln/GV_rational.h \
cln/input.h \
cln/integer_class.h \
cln/integer_io.h \
cln/real_class.h \
cln/sfloat.h \
cln/sfloat_class.h \
cln/dfloat.h \
cln/SV.h \
cln/integer.h
"

HEADERS2_INSTALL="
cln/config.h \
cln/intparam.h \
cln/host_cpu.h \
cln/floatparam.h \
cln/version.h
"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL="cln.pc"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

# make check passes all tests 2009-oct-26 using gcc-4.4.0 from http://www.mingw.org

mkdirs_post()
{
   # configure fails if this directory is non-existent, since
   # it tries to move two include files there...
   mkdir -pv ${BUILDDIR}/include/cln
}

conf()
{
   conf_pre;
   # Add CXXLIBS to $LIBS since cln is a pure c++ library
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
     LDFLAGS="${LDFLAGS} -Wl,--allow-multiple-definition" \
     CXXLIBS="${CXXLIBS}" \
     LIBS="${CXXLIBS}" \
     --prefix=${PREFIX} \
     --enable-shared \
     --enable-static
   )
   touch ${BUILDDIR}/have_configure
   modify_libtool_all ${BUILDDIR}/libtool
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/cln.dll        ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libcln.a ${STATICLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/libcln.dll.a   ${LIBRARY_PATH}
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/include/$a ${INCLUDE_PATH}/`basename $a`
   done
   
   # Install headers
   for a in $HEADERS2_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/include/$a ${INCLUDE_PATH}/`basename $a`
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/cln.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libcln.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libcln.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL $HEADERS2_INSTALL; do
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
