#! /usr/bin/sh

# Name of package
PKG=CLN
# Version of Package
VER=1.2.2
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
URL="http://www.ginac.de/CLN/cln-1.2.2.tar.bz2"

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
INSTALL_HEADERS=""
INCLUDE_DIR=include/cln

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

# disable built-in rules, since make fails when restarting an 
# interrupted build process trying to call "m2c", and the same
# when doing make check ??
MAKE_FLAGS="-r"

# == make check ==
#
#  Test passed, 05-jun-2009
#

mkdirs_post()
{
   # configure fails if this directory is non-existent, since
   # it tries to move two include files there...
   mkdir -pv ${BUILDDIR}/include/cln
}
   
conf()
{
   # add -DNO_ASM to CPPFLAGS since otherwise there are doubly-defined
   # functions which the linker complains about.
   # This looks like a bug in the source to me (why are they doubly defined
   # anyway?) but I don't have the time to track it down.
   # The INSTALL file recommends to define this anyway...

   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=../${SRCDIR} \
     CC="${CC} $LIBGCCLDFLAGS" \
     CXX="${CXX} $LIBGCCLDFLAGS" \
     F77="${F77} $LIBGCCLDFLAGS" \
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CPPFLAGS="$CPPFLAGS -DNO_ASM" \
     CXXLIBS="$CXXLIBS" \
     LDFLAGS="${LDFLAGS}" \
     --prefix="${PREFIX}" \
     --enable-shared
   )
}

build_pre()
{
   modify_libtool_all ${BUILDDIR}/libtool
}

install()
{
   install_pre;
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/cln.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/.libs/libcln.a ${STATICLIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/libcln.dll.a ${LIBRARY_PATH}
   
   for a in ${SRCDIR}/include/cln/*.h; do
      ${CP} ${CP_FLAGS} $a ${INCLUDE_PATH}
   done
   
   for a in ${BUILDDIR}/include/cln/*.h; do
      ${CP} ${CP_FLAGS} $a ${INCLUDE_PATH}
   done
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/cln.pc ${PKGCONFIGDATA_PATH}
   
   install_post
}

uninstall()
{
   uninstall_pre;

   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/cln.dll
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libcln.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libcln.dll.a
   
   for a in ${INCLUDE_PATH}/*.h; do
      ${RM} ${RM_FLAGS} $a
   done
   
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   
   ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/cln.pc
   
   uninstall_post;
}

all()
{
   download
   unpack
   applypatch
   mkdirs
   conf
   build
   install
}

main $*
