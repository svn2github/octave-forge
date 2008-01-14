#! /usr/bin/sh

# Name of the package we're building
PKG=tools
# Version of the package
VER=3.4.5
# Release No
REL=1
# URL to source code
URL=

# ---------------------------
# The directory this script is located
# Make sure that we have a MSYS patch starting with a drive letter!
TOPDIR=`pwd`
# Name of the source package
#PKGNAME=${PKG}-${VER}
# Full package name including revision
#FULLPKG=${PKGNAME}-${REL}
# Name of the source code package
#SRCPKG=${PKGNAME}
# Name of the patch file
#PATCHFILE=${FULLPKG}.diff
# Name of the source code file
#SRCFILE=${PKGNAME}.tar.bz2
# Directory where the source code is located
SRCDIR=${TOPDIR}


DIR_MINGW=mingw32
DIR_MSYS=MSYS

# --- load common functions ---
source ../../common.sh
source ../../pkg_version.sh

HTTP_ROOT="http://downloads.sourceforge.net/mingw"

URLS_GCC="\
gcc-core-${VER}-20060117-${REL}.tar.gz \
gcc-g++-${VER}-20060117-${REL}.tar.gz \
gcc-g77-${VER}-20060117-${REL}.tar.gz"

URLS_BINUTILS="binutils-2.17.50-20060824-1.tar.gz"
URLS_W32API="w32api-3.9.tar.gz"
URLS_MINGWRUNTIME="mingw-runtime-3.12.tar.gz"
URLS_MINGWMAKE="mingw32-make-3.81-1.tar.gz"

URLS_MINGW_TOOLS="${URLS_BINUTILS} ${URLS_W32API} ${URLS_MINGWRUNTIME} ${URLS_MINGWMAKE}"

URLS_MSYS_CORE="msysCORE-1.0.11-2007.01.19-1.tar.bz2"
URLS_MSYS_TOOLS="\
tar-1.13.19-MSYS-2005.06.08.tar.bz2 \
bzip2-1.0.3-MSYS-1.0.11-snapshot.tar.bz2 \
coreutils-5.97-MSYS-1.0.11-snapshot.tar.bz2 \
findutils-4.3.0-MSYS-1.0.11-snapshot.tar.bz2"

download_core() {
( for a in $1; do ${WGET} ${WGET_FLAGS} "${HTTP_ROOT}/$a"; done )
}

download() {
  download_core "${URLS_GCC}"
  download_core "${URLS_MINGW_TOOLS}"
  download_core "${URLS_MSYS_CORE}"
  download_core "${URLS_MSYS_TOOLS}"
}

install_mingw() {
  # extract MINGW (GCC)
  echo ${PACKAGE_ROOT}/${DIR_MINGW}
  mkdir -p ${PACKAGE_ROOT}/${DIR_MINGW}
  ( cd ${PACKAGE_ROOT}/${DIR_MINGW} && for a in ${URLS_GCC}; do ${TAR} xzvf "${TOPDIR}/$a"; done )
  # extract MINGW Tools
  ( cd ${PACKAGE_ROOT}/${DIR_MINGW} && for a in ${URLS_MINGW_TOOLS}; do ${TAR} xzvf "${TOPDIR}/$a"; done )

  # -- Post-processing --
  
  (
    cd ${PACKAGE_ROOT}/${DIR_MINGW}/bin
    # Create the mingw32-XXX-N.N.N executables
    cp mingw32-gcc.exe mingw32-gcc${GCC_VER}.exe
    cp mingw32-g++.exe mingw32-g++${GCC_VER}.exe
    cp mingw32-c++.exe mingw32-c++${GCC_VER}.exe
    cp g77.exe mingw32-g77${GCC_VER}.exe
    
    # remove duplicates
    ${RM} {cpp,gcc,g77,g++,c++}.exe
    ${RM} mingw32-{gcc,g++,c++,g77}.exe
    ${RM} mingw32-gcc-3.4.5
  )
}

install_msys() {
  # extract MSYS
  mkdir -p ${PACKAGE_ROOT}/${DIR_MSYS}
  ( cd ${PACKAGE_ROOT}/${DIR_MSYS} && for a in ${URLS_MSYS_CORE}; do ${TAR} xjvf "${TOPDIR}/$a"; done );
}

install_pkg() {
  install_mingw;
  install_msys;
}

all() {
  download;
#  install;
}

# do what the user specified...
$*
