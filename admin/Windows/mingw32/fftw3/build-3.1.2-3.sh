#! /usr/bin/sh

# Name of package
PKG=fftw
# Version of Package
VER=3.1.2
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
URL="http://www.fftw.org/fftw-3.1.2.tar.gz"

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
INSTALL_HEADERS=""

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"
BUILDDIR_SSE2=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}_sse2"


mkdirs_pre()
{
   mkdirs_pre_general;
   mkdirs_pre_sse2;
}

mkdirs_pre_general() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }
mkdirs_pre_sse2() { if [ -e ${BUILDDIR_SSE2} ]; then rm -rf ${BUILDDIR_SSE2}; fi; }

mkdirs()
{
   mkdirs_pre;

   mkdirs_general;
   mkdirs_sse2;
}

mkdirs_general() { mkdir -v ${BUILDDIR}; }
mkdirs_sse2() { mkdir -v ${BUILDDIR_SSE2}; }

conf()
{
   conf_general;
   conf_sse2;
}

conf_general()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC="${CC} $LIBGCCLDFLAGS" \
     CXX="${CXX} $LIBGCCLDFLAGS" \
     F77="${F77} $LIBGCCLDFLAGS"\
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     LDFLAGS="${LDFLAGS}" \
     LIBS="" \
     --prefix="${PREFIX}" \
     --enable-portable-binary \
     --enable-shared \
     --enable-static 
   )
}

conf_sse2()
{
   ( cd ${BUILDDIR_SSE2} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC="${CC} $LIBGCCLDFLAGS" \
     CXX="${CXX} $LIBGCCLDFLAGS" \
     F77="${F77} $LIBGCCLDFLAGS" \
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     LDFLAGS="${LDFLAGS}" \
     LIBS="" \
     --prefix="${PREFIX}" \
     --enable-sse2 \
     --enable-shared \
     --enable-static \
     --with-our-malloc16
   )
}

build()
{
   build_general;
   build_sse2;
}

build_general()
{ 
  ( cd ${BUILDDIR} && make_common )
}

build_sse2()
{ 
  ( cd ${BUILDDIR_SSE2} && make_common )
}

install()
{
   install_pre;
   
   install_general;
   install_sse2;
   
   install_post;
}

install_general()
{
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/fftw3.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libfftw3.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libfftw3.a ${STATICLIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/tools/.libs/fftw-wisdom.exe ${BINARY_PATH}
   ${CP} ${CP_FLAGS} ${SRCDIR}/api/fftw3.h ${INCLUDE_PATH}
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
}

install_arch()
{
   mkdir -vp $1{/${SHAREDLIB_DEFAULT},/${LIBRARY_DEFAULT},/${STATICLIBRARY_DEFAULT}}
   
   ${CP} ${CPFLAGS} ${BUILDDIR_SSE2}/.libs/fftw3.dll $1/${SHAREDLIB_DEFAULT}
   ${CP} ${CPFLAGS} ${BUILDDIR_SSE2}/.libs/libfftw3.dll.a $1/${LIBRARY_DEFAULT}
   ${CP} ${CPFLAGS} ${BUILDDIR_SSE2}/.libs/libfftw3.a $1/${STATICLIBRARY_DEFAULT}
   ${CP} ${CPFLAGS} ${BUILDDIR_SSE2}/tools/.libs/fftw-wisdom.exe $1/${BINARY_DEFAULT}
}

install_sse2()
{
   P=${PREFIX}/FFTW/ARCH_SSE2
   install_arch ${P}
}

uninstall()
{
   uninstall_general;
   
   uninstall_sse2;
}

uninstall_general()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/fftw3.dll
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/fft-wisdom.exe
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfftw3.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libfftw3.a
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/fftw3.h
}

uninstall_arch()
{
   ${RM} ${RM_FLAGS} $1/${SHAREDLIB_DEFAULT}/fftw3.dll
   ${RM} ${RM_FLAGS} $1/${LIBRARY_DEFAULT}/libfftw3.dll.a
   ${RM} ${RM_FLAGS} $1/${STATICLIBRARY_DEFAULT}/libfftw3.a
   ${RM} ${RM_FLAGS} $1/${BINARY_DEFAULT}/libfftw3.a
   
   rmdir $1{/${SHAREDLIB_DEFAULT},/${LIBRARY_DEFAULT},/${STATICLIBRARY_DEFAULT}}
}

uninstall_sse2()
{
   P=${PREFIX}/FFTW/ARCH_SSE2
   uninstall_arch ${P}
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
