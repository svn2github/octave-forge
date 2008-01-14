#! /usr/bin/sh


# This script downloads and extracts mingw32 GCC 4.2.1

# Name of the package we're building
PKG=mingw32-gcc
# Version of the package
VER=4.2.1
# Release No
REL=2
# URL to source code

TOPDIR=`pwd`

DIR_MINGW=mingw32
DIR_MSYS=MSYS

# --- load common functions ---
source ../../gcc42_common.sh
source ../../gcc42_pkg_version.sh

SYS=`echo ${GCC_SYS} | sed -e s+-++g`
CP=cp

# Download URLs
HTTP_ROOT="http://downloads.sourceforge.net/mingw"

URLS_GCC="
gcc-core-4.2.1-${SYS}-${REL}.tar.gz
gcc-g++-4.2.1-${SYS}-${REL}.tar.gz
gcc-gfortran-4.2.1-${SYS}-${REL}.tar.gz
"

URLS_BINUTILS="binutils-2.17.50-20060824-1.tar.gz"
URLS_W32API="w32api-3.10.tar.gz"
URLS_MINGWRUNTIME="mingw-runtime-3.13.tar.gz"
URLS_MINGWMAKE="mingw32-make-3.81-2.tar.gz"
URLS_MINGWUTILS="mingw-utils-0.3.tar.gz"
 
URLS_MINGW_TOOLS="${URLS_BINUTILS} ${URLS_W32API} ${URLS_MINGWRUNTIME} ${URLS_MINGWMAKE} ${URLS_MINGWUTILS}"

URLS_MSYS_CORE="msysCORE-1.0.11-2007.01.19-1.tar.bz2"
URLS_MSYS_TOOLS="\
tar-1.13.19-MSYS-2005.06.08.tar.bz2 \
bzip2-1.0.3-MSYS-1.0.11-snapshot.tar.bz2 \
coreutils-5.97-MSYS-1.0.11-snapshot.tar.bz2 \
findutils-4.3.0-MSYS-1.0.11-snapshot.tar.bz2"

download_core()
{
  ( for a in $1; do ${WGET} ${WGET_FLAGS} "${HTTP_ROOT}/$a"; done )
}

download() {
  download_core "${URLS_GCC}"
  download_core "${URLS_MINGW_TOOLS}"
  download_core "${URLS_MSYS_CORE}"
  download_core "${URLS_MSYS_TOOLS}"
}

install_msys() {
  # extract MSYS
  mkdir -p ${PACKAGE_ROOT}/${DIR_MSYS}
  ( cd ${PACKAGE_ROOT}/${DIR_MSYS} && for a in ${URLS_MSYS_CORE}; do ${TAR} xjvf "${TOPDIR}/$a"; done );
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

  # libgcc dll
  cp ${TOPDIR}/libgcc_${SYS}_1.dll.gz . && gzip -df libgcc_${SYS}_1.dll.gz
  
  # create stdc++ import library
  cd ..
  mv ./lib/gcc/mingw32/${VER}-${SYS}/libstdc++_s.a ./lib/gcc/mingw32/${VER}-${SYS}/libstdc++.dll.a
  
  # create libgcc_s.a import library
  cd bin
  echo "pexports libgcc_${SYS}_1.dll >libgcc_s.def" | cmd
  echo "dlltool -d libgcc_s.def -l libgcc_s.a libgcc_${SYS}_1.dll" | cmd
  ${MV} ${MV_FLAGS} libgcc_s.a ../lib/gcc/mingw32/${VER}-${SYS}/libgcc_s.a
  ${RM} ${RM_FLAGS} libgcc_s.def
  cd ..

  # move stdc++ runtime libs to octave binary directory
  mv ./bin/libgcc_${SYS}_1.dll ${PACKAGE_ROOT}/bin
  mv ./bin/libstdc++_${SYS}_6.dll ${PACKAGE_ROOT}/bin
  
)
}

install_pkg() {
   install_gcc
   install_msys
}

# do whatever the user specified...
$*