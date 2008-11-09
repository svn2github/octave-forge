#! /usr/bin/sh

# Name of package
PKG=pkg-config
# Version of Package
VER=0.23
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
URL="http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/pkg-config-0.23.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd -W | sed -e 's+\([a-z]\):/+/\1/+'`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=""

# Additional DIFF Flags for generating diff file
#DIFF_FLAGS="-x *.def"

# header files to be installed
#INSTALL_HEADERS=""

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=../${SRCDIR} \
     CC=${CC} \
     CXX=${CXX} \
     F77=${F77} \
     CFLAGS="$CFLAGS -Wall" \
     CXXFLAGS="$CXXFLAGS -Wall" \
     CPPFLAGS="$CPPFLAGS -I${INCLUDE_PATH}/glib" \
     LDFLAGS="${LDFLAGS}" \
     --prefix="${PREFIX}"
   )
}

install()
{
   install_pre;
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/pkg-config.exe ${BINARY_PATH}

   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING     ${LICENSE_PATH}/${PKG}
   
   install_post;
   
}

uninstall()
{
   uninstall_pre
   
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/pkg-config.exe
   
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   rmdir -v ${LICENSE_PATH}/${PKG}
   
   uninstall_post
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

