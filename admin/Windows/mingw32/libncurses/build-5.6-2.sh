#! /usr/bin/sh

# Name of package
PKG=ncurses
# Version of Package
VER=5.6
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
URL=""

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
INSTALL_HEADERS="term.h curses.h unctrl.h termcap.h"
#INSTALL_HEADERS="curses.h cursesapp.h cursesf.h cursesm.h cursesp.h cursesw.h cursslk.h eti.h etip.h form.h menu.h panel.h term.h termcap.h unctrl.h"
INSTALL_HEADERS2="ncurses_dll.h"
INCLUDE_DIR=include/ncurses

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
     --prefix=${PREFIX} \
	 --without-ada \
	 --with-shared
   )
}

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/ncurses-5.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/libncurses.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/libncurses.a ${STATICLIBRARY_PATH}
   for a in ${INSTALL_HEADERS}; do ${CP} ${CP_FLAGS} ${BUILDDIR}/include/$a ${INCLUDE_PATH}; done
   for a in ${INSTALL_HEADERS2}; do ${CP} ${CP_FLAGS} ${SRCDIR}/include/$a ${INCLUDE_PATH}; done

   ( cd ${BUILDDIR}/misc && make install )
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/ncurses5-config
   
   install_post;
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/ncurses-5.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libncurses.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libncurses.a
   for a in ${INSTALL_HEADERS}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
   for a in ${INSTALL_HEADERS2}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a; done
   rm -rvf ${PREFIX}/share/terminfo
   rm -rvf ${PREFIX}/share/tabset
   
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
