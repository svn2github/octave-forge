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
   mkdir -vp ${BUILDDIR}/docs
#   mkdir -vp ${BUILDDIR}/tutorial
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
   substvars ${SRCDIR}/docs/psdoc/makefile ${BUILDDIR}/docs/makefile
#   substvars ${SRCDIR}/tutorial/makefile.dst ${BUILDDIR}/tutorial/makefile.dst
}

build() {
  export PATH=${PATH_MIKTEX}:${PATH_HCW}:${PATH}
  ( cd ${BUILDDIR} && make -C src -f ../config/makefile.mgw )
  ( cd ${BUILDDIR}/docs && make pdf )
#  ( cd ${BUILDDIR}/tutorial && make -f makefile.dst )
}

install() { echo $0: install not required; }

install_pkg()
{
#   install_pkg_octave
   install_pkg_standalone
}

install_pkg_standalone()
{
   SADIR=".standalonebin_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

   GCCLIBS="libgcc_sjlj_1 libstdc++_sjlj_6"
   for a in $GCCLIBS; do ${CP} ${CP_FLAGS} ${PACKAGE_ROOT}/bin/$a.dll ${SADIR}/bin; done

   PACKAGE_ROOT=$SADIR
   install_pkg_octave
   
   LIBS="fontconfig freetype-6 gd libtiff libjpeg libpng zlib1 xml2"
   for a in $LIBS; do ${CP} ${CP_FLAGS} ${BINARY_PATH}/$a.dll ${PACKAGE_ROOT}/bin; done
   
   
}

install_pkg_octave()
{

   mkdir -vp ${PACKAGE_ROOT}/bin
   mkdir -vp ${PACKAGE_ROOT}/share/gnuplot/Postscript
   mkdir -vp ${PACKAGE_ROOT}/share/gnuplot/contrib/pm3d
   mkdir -vp ${PACKAGE_ROOT}/share/gnuplot/demo
   mkdir -vp ${PACKAGE_ROOT}/license/gnuplot
   mkdir -vp ${PACKAGE_ROOT}/doc/gnuplot
   mkdir -vp ${PACKAGE_ROOT}/doc/gnuplot/postscript-terminal
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/wgnuplot.exe ${PACKAGE_ROOT}/bin
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/pgnuplot.exe ${PACKAGE_ROOT}/bin
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/wgnuplot.mnu ${PACKAGE_ROOT}/bin
#   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/pgnuplot_win.exe ${PACKAGE_ROOT}/bin
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/wgnuplot.hlp ${PACKAGE_ROOT}/bin

   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/gnuplot.pdf      ${PACKAGE_ROOT}/doc/gnuplot
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/psdoc/ps_file.doc ${PACKAGE_ROOT}/doc/gnuplot/postscript-terminal
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/psdoc/ps_guide.ps ${PACKAGE_ROOT}/doc/gnuplot/postscript-terminal
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/psdoc/README      ${PACKAGE_ROOT}/doc/gnuplot/postscript-terminal
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/psdoc/ps_symbols.gpi      ${PACKAGE_ROOT}/doc/gnuplot/postscript-terminal/ps_symbols.gp
   ${CP} ${CP_FLAGS} ${BUILDDIR}/docs/ps_fontfile_doc.pdf     ${PACKAGE_ROOT}/doc/gnuplot/postscript-terminal
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/term/Postscript/* ${PACKAGE_ROOT}/share/gnuplot/Postscript
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/copyright ${PACKAGE_ROOT}/license/gnuplot
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/pm3d/contrib/* ${PACKAGE_ROOT}/share/gnuplot/contrib/pm3d
   ${CP} ${CP_FLAGS} ${SRCDIR}/pm3d/README    ${PACKAGE_ROOT}/share/gnuplot/contrib
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/demo/*               ${PACKAGE_ROOT}/share/gnuplot/demo
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/binary{1,2,3} ${PACKAGE_ROOT}/share/gnuplot/demo
   
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${PACKAGE_ROOT}/bin/{wgnuplot.exe,pgnuplot.exe,wgnuplot.hlp}
   ${RM} ${RM_FLAGS} ${PACKAGE_ROOT}/doc/gnuplot.pdf
   ${RM} ${RM_FLAGS} ${PACKAGE_ROOT}/share/gnuplot
}

mkpatch()
{
   # Patch against CVS source
   ( cd ${TOPDIR} && diff -urN -x '*.exe' -x '*.dll' -x '*.o' -x '*.a' -x '*.bak' ${DIFF_FLAGS} `basename ${SRCDIR_ORIG}` `basename ${SRCDIR}` > ${PATCHFILE} )
   # Patch against latest released sources (LICENSING!)
   ( cd ${TOPDIR} && diff -urN -x '*.bak' -x '.cvsignore' -x 'aclocal.m4' -x 'Makefile.am' -x 'Makefile.in' -x 'configure' -x '*.ja' -x 'faq-ja.tex' -x '*-ja.*' ${DIFF_FLAGS} gnuplot-4.2.3-orig `basename ${SRCDIR}` > ${FULLPKG}_vs_4.2.3.patch )
}

srcpkg()
{
   "${SEVENZIP}" ${SEVENZIP_FLAGS} ${SRCPKG_PATH}/${PKG}-${VER}-${REL}-src.7z ${SRCFILE} gnuplot-4.2.3.tar.gz ${PATCHFILE} ${FULLPKG}_vs_4.2.3.patch build-${VER}.sh
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
