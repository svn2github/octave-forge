#! /usr/bin/sh

# Name of package
PKG=qrupdate
# Version of Package
VER=1.0
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
URL="http://downloads.sourceforge.net/qrupdate/qrupdate-1.0.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE="Makefile"

# Additional DIFF Flags for generating diff file
#DIFF_FLAGS="-x *.def"

# header files to be installed
#INSTALL_HEADERS=""
#INCLUDE_DIR=

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

unpack()
{
   unpack_pre;
   rm -rf tmp
   ( mkdir tmp && cd tmp && $TAR -$TAR_TYPE -xf ${TOPDIR}/${SRCFILE} && mv $PKG ../$SRCDIR && cd .. && rm -rf tmp)
   unpack_post;
}

unpack_orig()
{
   unpack_orig_pre;
   rm -rf tmp
   ( mkdir tmp && cd tmp && $TAR -$TAR_TYPE -xf ${TOPDIR}/${SRCFILE} && mv $PKG ../$SRCDIR_ORIG && cd .. && rm -rf tmp)
   unpack_orig_post;
}

mkdirs_post()
{
   mkdir -vp ${BUILDDIR}/src
   mkdir -vp ${BUILDDIR}/test
}

conf()
{
   substvars ${SRCDIR}/makefile ${BUILDDIR}/makefile
   substvars ${SRCDIR}/src/makefile ${BUILDDIR}/src/makefile
   substvars ${SRCDIR}/test/makefile ${BUILDDIR}/test/makefile
}

build()
{
   ( cd ${BUILDDIR}/src && make_common lib )
   ( cd ${BUILDDIR}/src && make_common solib )
}

# 27-jan-2008 Benjamin Lindner <lindnerb@users.soruceforge.net>
#  using: mingw32-gfortran-4.3.0-dw2.exe (TDM 4.3.0-2)
#  all tests pass
# TOTAL:     PASSED 112     FAILED   0

check()
{
   ( cd ${BUILDDIR} && make_common test )
}

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/qrupdate.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libqrupdate.a ${STATICLIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/libqrupdate.dll.a ${LIBRARY_PATH}
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/qrupdate.dll
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libqrupdate.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libqrupdate.dll.a
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
