#! /usr/bin/sh


# This script downloads and extracts mingw32 GCC 4.3.0-2

# Name of the package we're building
PKG=mingw32-gcc-tdm
# Version of the package
VER=4.3.0
# Release No
REL=3
# URL to source code

TOPDIR=`pwd`

DIR_MINGW=mingw32

# --- load common functions ---
source ../../gcc43_common.sh
source ../../gcc43_pkg_version.sh

SYS=`echo ${GCC_SYS} | sed -e s+-++g`
CP=cp

# the release number of GCC
GCC_REL=2

# Download URLs
HTTP_ROOT="http://downloads.sourceforge.net/mingw"
HTTP_ROOT_GCC="http://downloads.sourceforge.net/tdm-gcc"

URLS_GCC="
gcc-${VER}-tdm-${GCC_REL}-${SYS}-core.tar.gz
gcc-${VER}-tdm-${GCC_REL}-${SYS}-fortran.tar.gz
gcc-${VER}-tdm-${GCC_REL}-${SYS}-g++.tar.gz
"

URLS_BINUTILS="binutils-2.19-mingw32-bin.tar.gz"
URLS_W32API="w32api-3.13-mingw32-dev.tar.gz"
URLS_MINGWRUNTIME="mingwrt-3.15.2-mingw32-dev.tar.gz"
URLS_MINGWMAKE="mingw32-make-3.81-20080326-3.tar.gz"
URLS_MINGWUTILS="mingw-utils-0.3.tar.gz"
 
URLS_MINGW_TOOLS="${URLS_BINUTILS} ${URLS_W32API} ${URLS_MINGWRUNTIME} ${URLS_MINGWMAKE} ${URLS_MINGWUTILS}"

download_core_gcc()
{
  ( for a in $1; do ${WGET} ${WGET_FLAGS} "${HTTP_ROOT_GCC}/$a"; done )
}

download_core_tools()
{
  ( for a in $1; do ${WGET} ${WGET_FLAGS} "${HTTP_ROOT}/$a"; done )
}

download() {
  download_core_gcc "${URLS_GCC}"
  download_core_tools "${URLS_MINGW_TOOLS}"
}

install_gcc() {
(
  # extract GCC
  echo ${PACKAGE_ROOT}/${DIR_MINGW}
  mkdir -p ${PACKAGE_ROOT}/${DIR_MINGW}

  cd ${PACKAGE_ROOT}/${DIR_MINGW}
  # extact GCC
  for a in ${URLS_GCC}; do ${TAR} xzvf "${TOPDIR}/$a"; done
  # extract MINGW Tools
  for a in ${URLS_MINGW_TOOLS}; do ${TAR} xzvf "${TOPDIR}/$a"; done
  
  # -- Post-processing --
  
  cd bin
  # Create the mingw32-XXX-N.N.N-dw2 executables
  ${CP} mingw32-g++-${SYS}.exe mingw32-g++-${VER}-${SYS}.exe
  ${CP} mingw32-c++-${SYS}.exe mingw32-c++-${VER}-${SYS}.exe
  ${CP} mingw32-gfortran-${SYS}.exe mingw32-gfortran-${VER}-${SYS}.exe
  ${CP} cpp-${SYS}.exe mingw32-cpp-${VER}-${SYS}.exe

  # remove duplicates
  ${RM} {cpp,gcc,gfortran,g++,c++}-${SYS}.exe
  ${RM} mingw32-{gcc,g++,c++,gfortran}-${SYS}.exe  
  
  strip ${STRIP_FLAGS} libgcc_tdm_${SYS}_1.dll
  strip ${STRIP_FLAGS} libstdc++_tdm_${SYS}_1.dll
  
  # ensure that the "bin" directory exists...
  mkdir -v ${PACKAGE_ROOT}/bin
  # ... and move the shared libs there
  mv -v libgcc_tdm_${SYS}_1.dll ${PACKAGE_ROOT}/bin
  mv -v libstdc++_tdm_${SYS}_1.dll ${PACKAGE_ROOT}/bin
)
}

install_pkg() {
   install_gcc
}

srcpkg()
{
   "${SEVENZIP}" ${SEVENZIP_FLAGS} ${SRCPKG_PATH}/${PKG}-${VER}-${REL}-src.7z ${URLS_GCC} ${URLS_MINGW_TOOLS} build-${VER}-${REL}.sh
}

mkdirs() { echo $0: mkdirs not required; }
applypatch() { echo $0: applypatch not required; }
conf() { echo $0: conf not required; }
build() { echo $0: build not required; }
install() { echo $0: install not required; }

# do whatever the user specified...
$*