#! /usr/bin/sh

# Name of package
PKG=fftw
# Version of Package
VER=3.1.2
# Release of (this patched) package
REL=2
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

source ../gcc42_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC=${CC} \
     CXX=${CXX} \
     F77=${F77} \
     CFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     LDFLAGS="${LDFLAGS}" \
     --prefix="${PREFIX}" \
     --enable-portable-binary \
     --enable-shared \
     --enable-static 
   )
}

build_post() {
   ${STRIP} ${STRIP_FLAGS} ${BUILDDIR}/.libs/fftw3.dll
}

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/fftw3.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libfftw3.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libfftw3.a ${STATICLIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/tools/.libs/fftw-wisdom.exe ${BINARY_PATH}
   ${CP} ${CP_FLAGS} ${SRCDIR}/api/fftw3.h ${INCLUDE_PATH}
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   install_post;
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/fftw3.dll
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/fft-wisdom.exe
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfftw3.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libfftw3.a
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/fftw3.h
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
