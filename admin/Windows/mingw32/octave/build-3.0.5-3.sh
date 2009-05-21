#! /usr/bin/sh

# Name of package
PKG=octave
# Version of Package
VER=3.0.5
# Release of (this patched) package
REL=3
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
URL="ftp://ftp.octave.org/pub/octave/octave-3.0.5.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKG}-${VER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${PKG}-${VER}-orig

# Make file to use
MAKEFILE=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x configure -x config.h.in -x *~ -x .hg"

# header files to be installed
INSTALL_HEADERS=""
INCLUDE_DIR=

# --- load common functions ---
source ../gcc43_common.sh
source ../gcc43_pkg_version.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

# PATHS to supporting programs
PATH_GNUPLOT=${PACKAGE_ROOT}/bin

mkpatch_pre() 
{
  ( rm -rf ${SRCDIR}/autom4te.cache; rm -rf ${SRCDIR}/scripts/autom4te.cache )
}

conf()
{
   export PATH=${PATH_MIKTEX}:${PATH}:${PATH_GHOSTSCRIPT}:${PATH_GNUPLOT}
   ( cd ${SRCDIR} && ./autogen.sh );
   
   # remove pre-defined environment variable GNUPLOT
   GNUPLOT=
   
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC=${CC} \
     CXX=${CXX} \
     F77=${F77} \
     CPP=${CPP} \
     LDFLAGS="${LDFLAGS}" \
     CPPFLAGS="$CPPFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS}" \
     CFLAGS="$CFLAGS -Wall" \
     CXXFLAGS="$CXXFLAGS -Wall" \
     --prefix="${PREFIX_OCT}/${VER}-${REL}" \
     --enable-static \
     --enable-shared \
     LIBS="" \
     FLIBS="-lgfortran" \
     CXXLIBS="$CXXLIBS" \
     GNUPLOT=gnuplot \
     SED=/usr/bin/sed
   )
}

build_pre()
{
   export PATH=${PATH_MIKTEX}:${PATH_GNUPLOT}:${INSTALL_BIN}:${PATH}:${PATH_GHOSTSCRIPT}
   mkdir -vp ${PREFIX_OCT}
   ${TOPDIR}/../copy-if-changed.sh ${TOPDIR}/mkoctfile.cc.in ${BUILDDIR}
   ${TOPDIR}/../copy-if-changed.sh ${TOPDIR}/octave-config.cc.in ${BUILDDIR}
   
   # http://www.nabble.com/3.0.2-release-to18826350.html#a19153976
   sed -e 's@#define HAVE_ROUND 1@/* #undef HAVE_ROUND */@' ${BUILDDIR}/config.h > ${BUILDDIR}/config.h.mod
   ${CP} ${CP_FLAGS} ${BUILDDIR}/config.h.mod ${BUILDDIR}/config.h
   
}

# Install a ready "make&make install"-ed octave into our PACKAGE_ROOT directory
# where the required additional libraries & include files have been installed
install_pkg() {
 echo ${PREFIX_OCT}/${VER}-${REL}
 mkdir -vp ${PACKAGE_ROOT}
 ( cp -vr ${PREFIX_OCT}/${VER}-${REL}{/bin,/lib,/include,/libexec,/share} ${PACKAGE_ROOT};
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
   cp -vR ${BUILDDIR}/doc/interpreter/html/* ${PACKAGE_ROOT}/doc/html/interpreter
   cp -vR ${BUILDDIR}/doc/liboctave/html/* ${PACKAGE_ROOT}/doc/html/liboctave
   # Install Licensing information
   mkdir -vp ${PACKAGE_ROOT}/license/octave
   cp -vp ${SRCDIR}/COPYING ${PACKAGE_ROOT}/license/octave
   # Install ICO file
   cp -vp ${TOPDIR}/octave.ico ${PACKAGE_ROOT}/bin
 )
}

main $*
