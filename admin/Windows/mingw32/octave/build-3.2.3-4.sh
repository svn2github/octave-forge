#! /usr/bin/sh

# Name of package
PKG=octave
# Version of Package
VER=3.2.3
# Release of (this patched) package
REL=4
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}.tar.bz2
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="ftp://ftp.octave.org/pub/octave/octave-3.2.3.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${PKGVER}-orig

# Make file to use (optional)
MAKEFILE=
# Any extra flags to pass make to
MAKE_XTRA=

# subdirectory to install heraders to (empty for default)
INCLUDE_DIR=

# Herader files to install
HEADERS_INSTALL=""

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x configure"

# load common functions
source ../gcc44_common.sh
source ../gcc44_pkg_version.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

# PATHS to supporting programs
# PATH_GNUPLOT=${PACKAGE_ROOT}/bin

conf_pre()
{
   export PATH=${PATH_MIKTEX}:${PATH}:${PATH_GHOSTSCRIPT}
   ( cd ${SRCDIR} && ./autogen.sh );
}

conf()
{
   conf_pre;

   # remove pre-defined environment variable GNUPLOT
   GNUPLOT=
   
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC=$CC \
     CXX=$CXX \
     F77=$F77 \
     CPP=$CPP \
     AR=$AR \
     RANLIB=$RANLIB \
     RC=$RC \
     STRIP=$STRIP \
     LD=$LD \
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CPPFLAGS="$CPPFLAGS" \
     LDFLAGS="${LDFLAGS} -Wl,--allow-multiple-definition" \
     CXXLIBS="${CXXLIBS}" \
     --prefix="${PREFIX_OCTAVE}/${VER}-${REL}" \
     LIBS="" \
     FLIBS="-lgfortran" \
     CXXLIBS="$CXXLIBS" \
     GNUPLOT=gnuplot \
     SED=/usr/bin/sed
   )
   touch ${BUILDDIR}/have_configure
   conf_post;
}

build_pre()
{
   export PATH=${PATH_MIKTEX}:${PATH}:${PATH_GHOSTSCRIPT}
}

install_pkg()
{
   mkdir -vp ${PACKAGE_ROOT}
   
   for a in bin lib include libexec share; do
      echo cp -ar ${PREFIX_OCTAVE}/${VER}-${REL}/$a ${PACKAGE_ROOT}
      cp -ar ${PREFIX_OCTAVE}/${VER}-${REL}/$a ${PACKAGE_ROOT}
   done
   
   rm -vf ${PACKAGE_ROOT}/lib/octave-${VER}/*.dll.a.${VER}
   
   strip ${STRIP_FLAGS} ${PACKAGE_ROOT}/bin/*.exe;
   strip ${STRIP_FLAGS} ${PACKAGE_ROOT}/bin/{liboctinterp,liboctave,libcruft}.dll;
   find ${PACKAGE_ROOT} -name *.oct -exec strip ${STRIP_FLAGS} "{}" \;
   
   # Install documentation: PDF
   mkdir -vp ${PACKAGE_ROOT}/doc/octave/pdf
   cp -aR ${BUILDDIR}/doc/interpreter/octave.pdf ${PACKAGE_ROOT}/doc/octave/pdf
   cp -aR ${BUILDDIR}/doc/liboctave/liboctave.pdf ${PACKAGE_ROOT}/doc/octave/pdf
   cp -aR ${SRCDIR}/doc/faq/Octave-FAQ.pdf ${PACKAGE_ROOT}/doc/octave/pdf
   cp -aR ${SRCDIR}/doc/refcard/refcard-a4.pdf ${PACKAGE_ROOT}/doc/octave/pdf
   
   # Install documentation: HTML
   mkdir -vp ${PACKAGE_ROOT}/doc/octave/html/faq
   mkdir -vp ${PACKAGE_ROOT}/doc/octave/html/interpreter
   mkdir -vp ${PACKAGE_ROOT}/doc/octave/html/liboctave
   cp -aR ${BUILDDIR}/doc/faq/*.html ${PACKAGE_ROOT}/doc/octave/html/faq
   cp -aR ${BUILDDIR}/doc/interpreter/html/* ${PACKAGE_ROOT}/doc/octave/html/interpreter
   cp -aR ${BUILDDIR}/doc/liboctave/html/* ${PACKAGE_ROOT}/doc/octave/html/liboctave
   
   # Install Licensing information
   mkdir -vp ${PACKAGE_ROOT}/license/octave
   cp -vp ${SRCDIR}/COPYING ${PACKAGE_ROOT}/license/octave

   # Install ICO file
   cp -vp ${TOPDIR}/octave.ico ${PACKAGE_ROOT}/bin
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/glob.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libglob.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libglob.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/`basename $a`
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   
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

runoctave() 
{
   ( PATH=${BINARY_PATH}:${PATH}; cd ${BUILDDIR} && ./run-octave --no-init-file )
}

if [ "$1" == "run" ]; then
   runoctave;
else
   main $*
fi
