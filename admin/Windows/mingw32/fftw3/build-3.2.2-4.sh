#! /usr/bin/sh

# Name of package
PKG=fftw
# Version of Package
VER=3.2.2
# Release of (this patched) package
REL=4
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.gz
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://www.fftw.org/fftw-3.2.2.tar.gz"

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
INCLUDE_DIR=

# Herader files to install
HEADERS_INSTALL="fftw3.h"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL="fftw3.pc fftw3f.pc"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh
source ../gcc44_pkg_version.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"
BUILDDIR_SINGLE=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}_single"
BUILDDIR_SSE=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}_sse"
BUILDDIR_SSE2=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}_sse2"

# == override resp. specify build actions ==

FFTWPKGROOT=${PACKAGE_ROOT}/FFTW3/SSE2

mkdirs_pre()
{
   mkdirs_pre_general;
   mkdirs_pre_single;
   mkdirs_pre_sse;
   mkdirs_pre_sse2;
}

mkdirs_pre_general() 
{ 
   if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; 
}
mkdirs_pre_single() 
{ 
   if [ -e ${BUILDDIR_SINGLE} ]; then rm -rf ${BUILDDIR_SINGLE}; fi; 
}
mkdirs_pre_sse() 
{ 
   if [ -e ${BUILDDIR_SSE} ]; then rm -rf ${BUILDDIR_SSE}; fi; 
}
mkdirs_pre_sse2() 
{ 
   if [ -e ${BUILDDIR_SSE2} ]; then rm -rf ${BUILDDIR_SSE2}; fi; 
}

mkdirs()
{
   mkdirs_pre;

   mkdirs_general;
   mkdirs_single;
   mkdirs_sse;
   mkdirs_sse2;
}

mkdirs_general() 
{ 
   mkdir -v ${BUILDDIR}; 
}
mkdirs_single() 
{ 
  mkdir -v ${BUILDDIR_SINGLE}; 
}
mkdirs_sse() 
{ 
   mkdir -v ${BUILDDIR_SSE}; 
}
mkdirs_sse2() 
{ 
   mkdir -v ${BUILDDIR_SSE2}; 
}

conf()
{
   conf_general;
   conf_single;
   conf_sse;
   conf_sse2;
}

conf_core()
{
   conf_pre;
   
   BD=$1
   shift
   
   ( cd $BD && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC="$CC $LIBGCCLDFLAGS"\
     CXX="$CXX $LIBGCCLDFLAGS"\
     F77="$F77 $LIBGCCLDFLAGS"\
     CPP=$CPP\
     AR=$AR \
     RANLIB=$RANLIB \
     RC=$RC \
     STRIP=$STRIP \
     LD=$LD \
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CPPFLAGS="$CPPFLAGS" \
     LDFLAGS="${LDFLAGS}" \
     LIBS="" \
     CXXLIBS="${CXXLIBS}" \
     --prefix=${PREFIX} \
     --enable-shared \
     --enable-static $*
   )
   
   touch ${BD}/have_configure
   
   modify_libtool_all ${BD}/libtool
   conf_post;
}

conf_general()
{
   conf_core ${BUILDDIR} \
     --enable-portable-binary
}

conf_single()
{
   conf_core ${BUILDDIR_SINGLE} \
     --enable-portable-binary \
     --enable-single
}

conf_sse()
{
   conf_core ${BUILDDIR_SSE} \
     --enable-sse \
     --enable-single \
     --with-our-malloc16
}

conf_sse2()
{
   conf_core ${BUILDDIR_SSE2} \
     --enable-sse2 \
     --with-our-malloc16
}

build()
{
   build_general;
   build_single;
   build_sse;
   build_sse2;
}

build_general()
{
  ( cd ${BUILDDIR} && make_common )
}

build_single()
{
  ( cd ${BUILDDIR_SINGLE} && make_common )
}

build_sse()
{
  ( cd ${BUILDDIR_SSE} && make_common )
}

build_sse2()
{
  ( cd ${BUILDDIR_SSE2} && make_common )
}

# Make check: all tests pass 30-aug-2009 using mingw32-gcc-4.4.0 (mingw)

check()
{
   check_pre;
   
   check_general;
   check_single;
   check_sse;
   check_sse2;
   
   check_post;
}

check_general()
{
   ( cd ${BUILDDIR} && make_common check )
}

check_single()
{
   ( cd ${BUILDDIR_SINGLE} && make_common check )
}

check_sse()
{
   ( cd ${BUILDDIR_SSE} && make_common check )
}

check_sse2()
{
   ( cd ${BUILDDIR_SSE2} && make_common check )
}

install()
{
   install_pre;
   
   install_general;
   install_single;
   
   mkdir -vp ${FFTWPKGROOT}/${SHAREDLIB_DIR}
   mkdir -vp ${FFTWPKGROOT}/${LIBRARY_DIR}
   mkdir -vp ${FFTWPKGROOT}/${STATICLIB_DIR}
   
   install_sse;
   install_sse2;
   
   install_post;
}

install_general()
{
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/fftw3.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libfftw3.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libfftw3.a ${STATICLIB_PATH}
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/api/$a ${INCLUDE_PATH}
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYRIGHT ${LICENSE_PATH}/${PKG}
   
}

install_single()
{
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR_SINGLE}/.libs/fftw3f.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR_SINGLE}/.libs/libfftw3f.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR_SINGLE}/.libs/libfftw3f.a ${STATICLIB_PATH}
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR_SINGLE}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   #for a in $HEADERS_INSTALL; do
   #   ${CP} ${CP_FLAGS} ${SRCDIR}/api/$a ${INCLUDE_PATH}
   #done
   
   # Install license file
   #${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   #${CP} ${CP_FLAGS} ${SRCDIR}/COPYRIGHT ${LICENSE_PATH}/${PKG}
   
}

install_sse()
{
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR_SSE}/.libs/fftw3f.dll ${FFTWPKGROOT}/${SHAREDLIB_DIR}
   ${CP} ${CP_FLAGS} ${BUILDDIR_SSE}/.libs/libfftw3f.dll.a ${FFTWPKGROOT}/${LIBRARY_DIR}
   ${CP} ${CP_FLAGS} ${BUILDDIR_SSE}/.libs/libfftw3f.a ${FFTWPKGROOT}/${STATICLIB_DIR}
   strip ${STRIP_FLAGS} ${FFTWPKGROOT}/${SHAREDLIB_DIR}/fftw3f.dll
   strip ${STRIP_FLAGS} ${FFTWPKGROOT}/${STATICLIB_DIR}/libfftw3f.a
   
}

install_sse2()
{
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR_SSE2}/.libs/fftw3.dll ${FFTWPKGROOT}/${SHAREDLIB_DIR}
   ${CP} ${CP_FLAGS} ${BUILDDIR_SSE2}/.libs/libfftw3.dll.a ${FFTWPKGROOT}/${LIBRARY_DIR}
   ${CP} ${CP_FLAGS} ${BUILDDIR_SSE2}/.libs/libfftw3.a ${FFTWPKGROOT}/${STATICLIB_DIR}
   strip ${STRIP_FLAGS} ${FFTWPKGROOT}/${SHAREDLIB_DIR}/fftw3.dll
   strip ${STRIP_FLAGS} ${FFTWPKGROOT}/${STATICLIB_DIR}/libfftw3.a
   
}

uninstall()
{
   uninstall_pre;
   
   uninstall_general;
   uninstall_single;
   
   uninstall_post;
}

uninstall_general()
{
   #uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/fftw3.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfftw3.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libfftw3.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYRIGHT
   
   #uninstall_post;
}

uninstall_single()
{
   #uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/fftw3f.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfftw3f.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libfftw3f.a
   
   # Uninstall headers
   #for a in $HEADERS_INSTALL; do
   #   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   #done
   
   # Uninstall pkg-config .pc files
   #for a in $PKG_CONFIG_INSTALL; do
   #   ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   #done
   
   # Uninstall license file
   #${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   #${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYRIGHT
   
   #uninstall_post;
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
