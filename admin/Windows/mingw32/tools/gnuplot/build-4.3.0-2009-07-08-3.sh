#! /usr/bin/sh

# Name of package
PKG=gnuplot
# Version of Package
VER=4.3.0-2009-07-08
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
URL="http://www.gnuplot.info/development/binaries/gnuplot-4.3.0-2009-07-08.tar.gz"
#http://www.gnuplot.info/development/binaries/gnuplot-4.3.0-2008-11-21.tar.gz

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=config/Makefile.mgw

DIFF_FLAGS="-x *.orig -x *~"

# --- load common functions ---
source ../../gcc43_common.sh
source ../../gcc43_pkg_version.sh

# Directory the lib is built in
BUILDDIR_GUI=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}_gui"
BUILDDIR_CONSOLE=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}_console"

#check_pre() { MAKEFILE=""; }

CP=cp

echo ${PREFIX}

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
   ${SED} -e "s+@SRCDIR@+${TOPDIR}/${SRCDIR}+" -e "s+@TARGET@+wgnuplot.exe+" ${SRCDIR}/${MAKEFILE} > ${BUILDDIR_GUI}/${MAKEFILE}
   substvars ${SRCDIR}/docs/psdoc/makefile ${BUILDDIR_GUI}/docs/makefile

   ${SED} -e "s+@SRCDIR@+${TOPDIR}/${SRCDIR}+" -e "s+@TARGET@+gnuplot.exe+" ${SRCDIR}/${MAKEFILE} > ${BUILDDIR_CONSOLE}/${MAKEFILE}
   substvars ${SRCDIR}/docs/psdoc/makefile ${BUILDDIR_CONSOLE}/docs/makefile
}

# MIND! Gnuplot must be built with Optimization level 2 MAX!
# Using -O3 resuts in program crash!
# Furthermore, -mfpmath=sse results in program crash when trying to rotate an splot

build() {
 (
  export PATH=${BINARY_PATH}:${PATH_MIKTEX}:${PATH_HCW}:${PATH}

  # build executables using parallel make (if enabled)
  ( cd ${BUILDDIR_GUI}     && make $MAKE_FLAGS -C src -f ../config/makefile.mgw GCC_ARCH_FLAGS="${GCC_ARCH_FLAGS}" wgnuplot.exe )
  # build documentation using non-parallel make, parallel build fails
  ( cd ${BUILDDIR_GUI}     && make -C src -f ../config/makefile.mgw GCC_ARCH_FLAGS="${GCC_ARCH_FLAGS}" all )
  # executable again using parallel make
  ( cd ${BUILDDIR_CONSOLE} && make $MAKE_FLAGS -C src -f ../config/makefile.mgw GCC_ARCH_FLAGS="${GCC_ARCH_FLAGS}" gnuplot.exe )
  ( cd ${BUILDDIR_GUI}/docs && make pdf )
 )
}

install() { echo $0: install not required; }

install_pkg()
{
   install_pkg_octave
   install_pkg_standalone
}

install_pkg_standalone()
{
   SADIR=".standalonebin_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

#   GCCLIBS="libgcc_sjlj_1 libstdc++_sjlj_6"
#   for a in $GCCLIBS; do ${CP} ${CP_FLAGS} ${PACKAGE_ROOT}/bin/$a.dll ${SADIR}/bin; done

   PACKAGE_ROOT=$SADIR
   install_pkg_octave
   
   LIBS="fontconfig freetype-6 gd tiff-3 jpeg png12 zlib1 expat 
   iconv intl pcre-7 gio-2.0-0 glib-2.0-0 gmodule-2.0-0 gobject-2.0-0 gthread-2.0-0 
   pixman-1-0 cairo-2 
   pango-1.0-0 pangocairo-1.0-0 pangoft2-1.0-0 pangowin32-1.0-0 "
   for a in $LIBS; do ${CP} ${CP_FLAGS} ${BINARY_PATH}/$a.dll ${PACKAGE_ROOT}/bin; done
   
   strip ${STIP_FLAGS} ${PACKAGE_ROOT}/bin/*.exe
   strip ${STIP_FLAGS} ${PACKAGE_ROOT}/bin/*.dll
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
   
   ${CP} ${CP_FLAGS} ${BUILDDIR_GUI}/src/wgnuplot.exe ${PACKAGE_ROOT}/bin
   ${CP} ${CP_FLAGS} ${BUILDDIR_CONSOLE}/src/gnuplot.exe ${PACKAGE_ROOT}/bin/gnuplot.exe
   ${CP} ${CP_FLAGS} ${BUILDDIR_GUI}/src/wgnuplot.mnu ${PACKAGE_ROOT}/bin
   ${CP} ${CP_FLAGS} ${BUILDDIR_GUI}/src/wgnuplot.hlp ${PACKAGE_ROOT}/bin

   ${CP} ${CP_FLAGS} ${BUILDDIR_GUI}/src/gnuplot.pdf      ${PACKAGE_ROOT}/doc/gnuplot
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/psdoc/ps_file.doc ${PACKAGE_ROOT}/doc/gnuplot/postscript-terminal
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/psdoc/ps_guide.ps ${PACKAGE_ROOT}/doc/gnuplot/postscript-terminal
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/psdoc/README      ${PACKAGE_ROOT}/doc/gnuplot/postscript-terminal
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/psdoc/ps_symbols.gpi      ${PACKAGE_ROOT}/doc/gnuplot/postscript-terminal/ps_symbols.gp
   ${CP} ${CP_FLAGS} ${BUILDDIR_GUI}/docs/ps_fontfile_doc.pdf     ${PACKAGE_ROOT}/doc/gnuplot/postscript-terminal
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/term/Postscript/* ${PACKAGE_ROOT}/share/gnuplot/Postscript
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/copyright ${PACKAGE_ROOT}/license/gnuplot
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/pm3d/contrib/* ${PACKAGE_ROOT}/share/gnuplot/contrib/pm3d
   ${CP} ${CP_FLAGS} ${SRCDIR}/pm3d/README    ${PACKAGE_ROOT}/share/gnuplot/contrib
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/demo/*               ${PACKAGE_ROOT}/share/gnuplot/demo
   ${CP} ${CP_FLAGS} ${BUILDDIR_GUI}/src/binary{1,2,3} ${PACKAGE_ROOT}/share/gnuplot/demo
   
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${PACKAGE_ROOT}/bin/{wgnuplot.exe,gnuplot.exe,wgnuplot.hlp,wgnuplot.mnu}
   ${RM} ${RM_FLAGS} ${PACKAGE_ROOT}/doc/gnuplot
   ${RM} ${RM_FLAGS} ${PACKAGE_ROOT}/share/gnuplot
}

mkpatch()
{
   # Patch against CVS source
   ( cd ${TOPDIR} && diff -urN -x '*.exe' -x '*.dll' -x '*.o' -x '*.a' -x '*.bak' ${DIFF_FLAGS} `basename ${SRCDIR_ORIG}` `basename ${SRCDIR}` > ${PATCHFILE} )
   # Patch against latest released sources (LICENSING!)
   # ( cd ${TOPDIR} && diff -urN -x '*.bak' -x '.cvsignore' -x 'aclocal.m4' -x 'Makefile.am' -x 'Makefile.in' -x 'configure' -x '*.ja' -x 'faq-ja.tex' -x '*-ja.*' ${DIFF_FLAGS} gnuplot-4.2.3-orig `basename ${SRCDIR}` > ${FULLPKG}_vs_4.2.3.patch )
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
