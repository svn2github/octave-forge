#! /usr/bin/sh

# This script downloads and extracts mingw32 GCC 4.4.0

# Name of the package we're building
PKG=mingw32-gcc
# Version of the package
VER=4.4.0
# Release No
REL=4

TOPDIR=`pwd`

# --- load common functions ---
source ../../gcc44_common.sh
source ../../gcc44_pkg_version.sh

# Download URLs
HTTP_ROOT="http://downloads.sourceforge.net/mingw"

URLS_GCC="
${HTTP_ROOT}/gcc-c++-4.4.0-mingw32-bin.tar.gz
${HTTP_ROOT}/gcc-c++-4.4.0-mingw32-dll.tar.gz
${HTTP_ROOT}/gcc-core-4.4.0-mingw32-bin.tar.gz
${HTTP_ROOT}/gcc-core-4.4.0-mingw32-dll.tar.gz
${HTTP_ROOT}/gcc-fortran-4.4.0-mingw32-bin.tar.gz
${HTTP_ROOT}/gcc-fortran-4.4.0-mingw32-dll.tar.gz
"
URLS_GCC_LIBS="
${HTTP_ROOT}/gmp-4.2.4-mingw32-dll.tar.gz
${HTTP_ROOT}/mpfr-2.4.1-mingw32-dll.tar.gz
${HTTP_ROOT}/pthreads-w32-2.8.0-mingw32-dll.tar.gz
${HTTP_ROOT}/libiconv-1.13-mingw32-dll-2.tar.gz
"
URLS_BINUTILS="${HTTP_ROOT}/binutils-2.19.1-mingw32-bin.tar.gz"
URLS_W32API="${HTTP_ROOT}/w32api-3.13-mingw32-dev.tar.gz"
URLS_MINGWRUNTIME="
${HTTP_ROOT}/mingwrt-3.16-mingw32-dll.tar.gz 
${HTTP_ROOT}/mingwrt-3.16-mingw32-dev.tar.gz
"
URLS_MINGWMAKE="${HTTP_ROOT}/make-3.81-20090911-mingw32-bin.tar.gz"
URLS_MINGWUTILS="${HTTP_ROOT}/mingw-utils-0.3.tar.gz"
 
URL="${URLS_GCC} ${URLS_GCC_LIBS} ${URLS_BINUTILS} ${URLS_W32API} ${URLS_MINGWRUNTIME} ${URLS_MINGWMAKE} ${URLS_MINGWUTILS}"

# Directory to unpack gcc to
DIR_MINGW=mingw32

CP=cp

install_gcc() {
(
  # extract GCC
  echo ${PACKAGE_ROOT}/${DIR_MINGW}
  mkdir -p ${PACKAGE_ROOT}/${DIR_MINGW}

  cd ${PACKAGE_ROOT}/${DIR_MINGW}

  for a in ${URL}; do 
    echo bsdtar x -f "${TOPDIR}/`basename $a`"; 
    bsdtar x -f "${TOPDIR}/`basename $a`"; 
  done
  
  # -- Post-processing --
  
  cd bin
  # Create the mingw32-XXX-N.N.N-dw2 executables
  ${CP} -av mingw32-gcc-${GCC_VER}.exe mingw32-gcc-${GCC_VER}-${GCC_SYS}.exe
  ${CP} -av mingw32-g++.exe mingw32-g++-${GCC_VER}-${GCC_SYS}.exe
  ${CP} -av mingw32-gfortran.exe mingw32-gfortran-${GCC_VER}-${GCC_SYS}.exe
  ${CP} -av cpp.exe mingw32-cpp-${GCC_VER}-${GCC_SYS}.exe

  # mingw-c++.exe is a forward wrapper for mingw-g++.exe
  ${CP} -av mingw32-g++.exe  mingw32-c++-${GCC_VER}-${GCC_SYS}.exe
  
  # remove duplicates
  ${RM} {cpp,gcc,gfortran,g++,c++}.exe
  ${RM} mingw32-{gcc,g++,c++,gfortran}.exe  
  ${RM} mingw32-gcc-${GCC_VER}.exe  
  
  # strip GCC runtime libraries
  strip ${STRIP_FLAGS} exchndl.dll
  strip ${STRIP_FLAGS} libcharset-1.dll
  strip ${STRIP_FLAGS} libgmp-3.dll
  strip ${STRIP_FLAGS} libgmpxx-4.dll
  strip ${STRIP_FLAGS} libgomp-1.dll
  strip ${STRIP_FLAGS} libiconv-2.dll
  strip ${STRIP_FLAGS} libmpfr-1.dll
  strip ${STRIP_FLAGS} libssp-0.dll

  # strip binutils executables
  for a in *.exe; do
     echo strip ${STRIP_FLAGS} $a
     strip ${STRIP_FLAGS} $a
  done
  
  # 
  #  Fix  bug in libstd++ headers
  #  See  SF # 2836185
  #  "https://sourceforge.net/tracker/?func=detail&aid=2836185&group_id=2435&atid=102435"
  #
  sed -i -e "s@class _GLIBCXX_IMPORT@class @g" "${PACKAGE_ROOT}/${DIR_MINGW}/lib/gcc/mingw32/${GCC_VER}/include/c++/exception"
  sed -i -e "s@class _GLIBCXX_IMPORT@class @g" "${PACKAGE_ROOT}/${DIR_MINGW}/lib/gcc/mingw32/${GCC_VER}/include/c++/new"
  sed -i -e "s@class _GLIBCXX_IMPORT@class @g" "${PACKAGE_ROOT}/${DIR_MINGW}/lib/gcc/mingw32/${GCC_VER}/include/c++/typeinfo"

  #
  #  fix bug with libtool messing up shared libstd++ builds (again, sigh)
  #  move the libstdc++.la file out of the way 
  #  See the following links:
  #    http://sourceforge.net/mailarchive/forum.php?thread_name=4A97B057.2040803%40gmail.com&forum_name=mingw-users
  #    http://thread.gmane.org/gmane.comp.gnu.mingw.user/30206/focus=30243
  #
  (
  cd ../lib/gcc/mingw32/${GCC_VER}
  mv -v "libstdc++.la" "libstdc++.la.bak"
  )

  # ensure that the "bin" directory exists...
  mkdir -v ${PACKAGE_ROOT}/bin
  # ... and move the shared libs there
  mv -v libgcc_s_${GCC_SYS}-1.dll ${PACKAGE_ROOT}/bin
  mv -v libstdc++-6.dll ${PACKAGE_ROOT}/bin
  mv -v libgfortran-3.dll ${PACKAGE_ROOT}/bin
  mv -v mingwm10.dll ${PACKAGE_ROOT}/bin
)
}

install_pkg() {
   install_gcc
}

mkdirs() { echo $0: mkdirs not required; }
applypatch() { echo $0: applypatch not required; }
conf() { echo $0: conf not required; }
build() { echo $0: build not required; }
install() { echo $0: install not required; }

# do whatever the user specified...
$*