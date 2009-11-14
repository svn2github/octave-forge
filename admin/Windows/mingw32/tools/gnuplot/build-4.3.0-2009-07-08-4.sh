#! /usr/bin/sh

# Name of package
PKG=gnuplot
# Version of Package
VER=4.3.0-2009-07-08
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
URL="http://www.gnuplot.info/development/binaries/gnuplot-4.3.0-2009-07-08.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=config/Makefile.mgw
# Any extra flags to pass make to
MAKE_XTRA=

# subdirectory to install heraders to (empty for default)
INCLUDE_DIR=

# Herader files to install
HEADERS_INSTALL=""

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../../gcc44_common.sh

CP=${TOPDIR}/../../copy-if-changed.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
# BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"
BUILDDIR_GUI=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}_gui"
BUILDDIR_CONSOLE=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}_console"

# == override resp. specify build actions ==

mkdirs_pre() 
{ 
   if [ -e ${BUILDDIR_GUI} ]; then rm -rf ${BUILDDIR_GUI}; fi; 
   if [ -e ${BUILDDIR_CONSOLE} ]; then rm -rf ${BUILDDIR_CONSOLE}; fi; 
}

mkdirs() 
{ 
   mkdirs_pre;
   
   mkdir -vp ${BUILDDIR_GUI}/config
   mkdir -vp ${BUILDDIR_GUI}/src
   mkdir -vp ${BUILDDIR_GUI}/docs

   mkdir -vp ${BUILDDIR_CONSOLE}/config
   mkdir -vp ${BUILDDIR_CONSOLE}/src
   mkdir -vp ${BUILDDIR_CONSOLE}/docs

   mkdirs_post;
}

# must add version number to source directory explicitly
unpack() { unpack_add_ver; }
# ditto
unpack_orig() { unpack_orig_add_ver; }

conf()
{
   conf_pre;
   
   ${SED} -e "s+@SRCDIR@+${TOPDIR}/${SRCDIR}+" -e "s+@TARGET@+wgnuplot.exe+" ${SRCDIR}/${MAKEFILE} > ${BUILDDIR_GUI}/${MAKEFILE}
   substvars ${SRCDIR}/docs/psdoc/makefile ${BUILDDIR_GUI}/docs/makefile

   ${SED} -e "s+@SRCDIR@+${TOPDIR}/${SRCDIR}+" -e "s+@TARGET@+gnuplot.exe+" ${SRCDIR}/${MAKEFILE} > ${BUILDDIR_CONSOLE}/${MAKEFILE}
   substvars ${SRCDIR}/docs/psdoc/makefile ${BUILDDIR_CONSOLE}/docs/makefile
   
   conf_post;
}

# MIND! Gnuplot must be built with Optimization level 2 MAX!
# Using -O3 resuts in program crash!
# Furthermore, -mfpmath=sse results in program crash when trying to rotate an splot

build() {
 (
  export PATH=${BINARY_PATH}:${PATH_MIKTEX}:${PATH_HCW}:${PATH}

  MAKEFILE="../$MAKEFILE"
  
  #  build executables using parallel make (if enabled)
  ( cd ${BUILDDIR_GUI}     && make_common -C src wgnuplot.exe )
  # executable again using parallel make
  ( cd ${BUILDDIR_CONSOLE} && make_common -C src gnuplot.exe )
  
  # build documentation using non-parallel make, parallel build fails
  MAKE_PARALLEL=""
  ( cd ${BUILDDIR_GUI}     && make_common -C src all )
  
  ( cd ${BUILDDIR_GUI}/docs && make pdf )
 )
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   #${CP} ${CP_FLAGS} ${BUILDDIR}/zlib1.dll ${SHAREDLIB_PATH}
   #${CP} ${CP_FLAGS} ${BUILDDIR}/libz.dll.a ${LIBRARY_PATH}
   #${CP} ${CP_FLAGS} ${BUILDDIR}/libz.a ${STATICLIB_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR_GUI}/src/wgnuplot.exe ${BINARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR_GUI}/src/wgnuplot.mnu ${BINARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR_GUI}/src/wgnuplot.hlp ${BINARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR_CONSOLE}/src/gnuplot.exe ${BINARY_PATH}
   
   mkdir -vp ${SHARE_PATH}/${PKG}/Postscript
   ${CP} ${CP_FLAGS} ${SRCDIR}/term/Postscript/* ${SHARE_PATH}/${PKG}/Postscript
   
   mkdir -vp ${SHARE_PATH}/${PKG}/contrib/pm3d
   ${CP} ${CP_FLAGS} ${SRCDIR}/pm3d/contrib/* ${SHARE_PATH}/${PKG}/contrib/pm3d
   ${CP} ${CP_FLAGS} ${SRCDIR}/pm3d/README    ${SHARE_PATH}/${PKG}/contrib
   
   mkdir -vp ${SHARE_PATH}/${PKG}/demo
   ${CP} ${CP_FLAGS} ${SRCDIR}/demo/*               ${SHARE_PATH}/${PKG}/demo
   ${CP} ${CP_FLAGS} ${BUILDDIR_GUI}/src/binary{1,2,3} ${SHARE_PATH}/${PKG}/demo
   
   mkdir -vp ${DOC_PATH}/${PKG}
   mkdir -vp ${DOC_PATH}/${PKG}/postscript-terminal
   ${CP} ${CP_FLAGS} ${BUILDDIR_GUI}/src/gnuplot.pdf      ${DOC_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/psdoc/ps_file.doc ${DOC_PATH}/${PKG}/postscript-terminal
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/psdoc/ps_guide.ps ${DOC_PATH}/${PKG}/postscript-terminal
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/psdoc/README      ${DOC_PATH}/${PKG}/postscript-terminal
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/psdoc/ps_symbols.gpi      ${DOC_PATH}/${PKG}/postscript-terminal/ps_symbols.gp
   ${CP} ${CP_FLAGS} ${BUILDDIR_GUI}/docs/ps_fontfile_doc.pdf     ${DOC_PATH}/${PKG}/postscript-terminal
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/copyright ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   #${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/zlib1.dll
   #${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libz.dll.a
   #${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libz.a
   
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/wgnuplot.exe
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/wgnuplot.hlp
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/wgnuplot.mnu
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/gnuplot.exe
   
   ${RM} ${RM_FLAGS} ${PACKAGE_ROOT}/doc/${PKG}
   ${RM} ${RM_FLAGS} ${PACKAGE_ROOT}/share/${PKG}

   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/copyright
   
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
