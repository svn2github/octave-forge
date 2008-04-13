#! /usr/bin/sh

# Name of package
PKG=gnuplot
# Version of Package
VER=4.3.0-2008-03-24
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
URL="http://downloads.sourceforge.net/gnuplot/gnuplot-4.2.3.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=config/Makefile.mgw

# PATHS to supporting programs
PATH_MIKTEX=/c/Programs/MiKTeX24/miktex/bin/
PATH_HCW=/c/Programs/HelpWorkshop/

DIFF_FLAGS="-x *.orig"

# --- load common functions ---
source ../../gcc42_common.sh
source ../../gcc42_pkg_version.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

#check_pre() { MAKEFILE=""; }

CP=cp

echo ${PREFIX}

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

mkdirs_post() 
{ 
   mkdir -vp ${BUILDDIR}/config
   mkdir -vp ${BUILDDIR}/src
}

unpack_pre()
{
   mkdir tmp && cd tmp
}
unpack_post()
{
   mv gnuplot ../${SRCDIR} && cd .. && rm -rf tmp
}

unpack_orig()
{
   unpack_pre;
   ${TAR} -${TAR_TYPE} -${TAR_FLAGS} ${TOPDIR}/${SRCFILE}
   mv gnuplot ../${SRCDIR_ORIG} && cd .. && rm -rf tmp
}

conf()
{
   substvars ${SRCDIR}/${MAKEFILE} ${BUILDDIR}/${MAKEFILE}
}

build() {
(
  export PATH=${PATH_MIKTEX}:${PATH_HCW}:${PATH}
  cd ${BUILDDIR} && make -C src -f ../config/makefile.mgw
)
}

install() { echo $0: install not required; }

install_pkg()
{

   mkdir -vp ${PACKAGE_ROOT}/share/gnuplot/Postscript
   mkdir -vp ${PACKAGE_ROOT}/license/gnuplot
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/wgnuplot.exe ${PACKAGE_ROOT}/bin
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/pgnuplot.exe ${PACKAGE_ROOT}/bin
#   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/pgnuplot_win.exe ${PACKAGE_ROOT}/bin
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/wgnuplot.hlp ${PACKAGE_ROOT}/bin

   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/gnuplot.pdf ${PACKAGE_ROOT}/doc
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/term/Postscript/* ${PACKAGE_ROOT}/share/gnuplot/Postscript
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/copyright ${PACKAGE_ROOT}/license/gnuplot
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${PACKAGE_ROOT}/bin/{wgnuplot.exe,pgnuplot.exe,wgnuplot.hlp}
   ${RM} ${RM_FLAGS} ${PACKAGE_ROOT}/doc/gnuplot.pdf
   ${RM} ${RM_FLAGS} ${PACKAGE_ROOT}/share/gnuplot
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
