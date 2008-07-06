#! /usr/bin/sh

# Name of package
PKG=octave
# Version of Package
VER=3.0.0
# Release of (this patched) package
REL=2
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}.tar.bz2
TAR_TYPE=j
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
DIFF_FLAGS="-x configure -x config.h.in -x *~"

# header files to be installed
INSTALL_HEADERS=""
INCLUDE_DIR=

# PATHS to supporting programs
PATH_MIKTEX=/c/Programs/MiKTeX24/miktex/bin/
PATH_GNUPLOT=/c/Programs/gnuplot/4.2/bin
PATH_GHOSTSCRIPT=/c/Programs/gs/gs8.54/bin

# --- load common functions ---
source ../gcc42_common.sh
source ../gcc42_pkg_version.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

mkpatch_pre() 
{
  ( rm -rf ${SRCDIR}/autom4te.cache; rm -rf ${SRCDIR}/scripts/autom4te.cache )
}

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
   export PATH=${PATH_MIKTEX}:${PATH_GNUPLOT}:${INSTALL_BIN}:${PATH}:${PATH_GHOSTSCRIPT}
   ( cd ${SRCDIR} && ./autogen.sh );
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC=${CC} \
     CXX=${CXX} \
     F77=${F77} \
     LDFLAGS="${LDFLAGS}" \
     CPPFLAGS="${GCC_ARCH_FLAGS}" \
     CFLAGS="${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="${GCC_OPT_FLAGS} -Wall" \
     --prefix="${PREFIX_OCT}/${VER}-${REL}"
     )
}

build_pre()
{
   export PATH=${PATH_MIKTEX}:${PATH_GNUPLOT}:${INSTALL_BIN}:${PATH}:${PATH_GHOSTSCRIPT}
   mkdir -vp ${PREFIX_OCT}
   ${TOPDIR}/../copy-if-changed.sh ${TOPDIR}/mkoctfile.cc.in ${BUILDDIR}
   ${TOPDIR}/../copy-if-changed.sh ${TOPDIR}/octave-config.cc.in ${BUILDDIR}
}

# Install a ready "make&make install"-ed octave into our PACKAGE_ROOT directory
# where the required additional libraries & include files have been installed
install_pkg() {
 echo ${PREFIX_OCT}/${VER}-${REL}
 mkdir -vp ${PACKAGE_ROOT}
 ( cp -vr ${PREFIX_OCT}/${VER}-${REL}{/bin,/lib,/include,/info,/libexec,/man,/share} ${PACKAGE_ROOT};
   rm ${RM_FLAGS} ${PACKAGE_ROOT}/lib/octave-${VER}/*.${VER}
   strip ${STRIP_FLAGS} ${PACKAGE_ROOT}/bin/*.exe;
   strip ${STRIP_FLAGS} ${PACKAGE_ROOT}/bin/{liboctinterp,liboctave,libcruft}.dll;
   find ${PACKAGE_ROOT} -name *.oct -exec strip ${STRIP_FLAGS} "{}" \;
   # Install documentation: PDF
   mkdir -vp ${PACKAGE_ROOT}/doc/pdf
   cp -vR ${BUILDDIR}/doc/interpreter/octave.pdf ${PACKAGE_ROOT}/doc/pdf
   cp -vR ${BUILDDIR}/doc/liboctave/liboctave.pdf ${PACKAGE_ROOT}/doc/pdf
   cp -vR ${SRCDIR}/doc/faq/Octave-FAQ.pdf ${PACKAGE_ROOT}/doc/pdf
   cp -vR ${SRCDIR}/doc/refcard/refcard-a4.pdf ${PACKAGE_ROOT}/doc/pdf
   # Install documentation: HTML
   mkdir -vp ${PACKAGE_ROOT}/doc/html/faq
   mkdir -vp ${PACKAGE_ROOT}/doc/html/interpreter
   mkdir -vp ${PACKAGE_ROOT}/doc/html/liboctave
   cp -vR ${BUILDDIR}/doc/faq/*.html ${PACKAGE_ROOT}/doc/html/faq
   cp -vR ${BUILDDIR}/doc/interpreter/html/*.html ${PACKAGE_ROOT}/doc/html/interpreter
   cp -vR ${BUILDDIR}/doc/liboctave/html/*.html ${PACKAGE_ROOT}/doc/html/liboctave
   # Install Licensing information
   mkdir -vp ${PACKAGE_ROOT}/license/octave
   cp -vp ${SRCDIR}/COPYING ${PACKAGE_ROOT}/license/octave
   # Install ICO file
   cp -vp ${TOPDIR}/octave.ico ${PACKAGE_ROOT}/bin
 )
}

main $*
