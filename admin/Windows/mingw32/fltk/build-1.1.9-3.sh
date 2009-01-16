#! /usr/bin/sh

# Name of package
PKG=fltk
# Version of Package
VER=1.1.9
# Release of (this patched) package
REL=3
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}-source.tar.bz2
TAR_TYPE=j
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="http://ftp.rz.tu-bs.de/pub/mirror/ftp.easysw.com/ftp/pub/fltk/1.1.9/fltk-1.1.9-source.tar.bz2"

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
INCLUDE_DIR=include/FL

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

mkdirs_post()
{
   mkdir -vp ${BUILDDIR}/src
   mkdir -vp ${BUILDDIR}/lib
}

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=../${SRCDIR} \
     CC=${CC} \
     CXX=${CXX} \
     F77=${F77} \
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall -DFL_DLL" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall -DFL_DLL" \
     LDFLAGS="${LDFLAGS}" \
     CXXLIBS="$CXXLIBS" \
     DSOFLAGS="${LDFLAGS}" \
     --prefix="${PREFIX}" \
     --enable-static \
     --enable-shared \
     --enable-gl
   )

   substvars ${SRCDIR}/src/makefile ${BUILDDIR}/src/makefile
   substvars ${SRCDIR}/makefile ${BUILDDIR}/makefile
   
   sed -e \
	"s@../FL@\$(SRCDIR)/FL@g" \
	${SRCDIR}/src/makedepend > ${BUILDDIR}/src/makedepend
}

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/mgwfltknox_forms-1.1.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/mgwfltknox_gl-1.1.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/mgwfltknox_images-1.1.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/mgwfltknox-1.1.dll ${SHAREDLIB_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/libfltk.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/libfltk_forms.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/libfltk_gl.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/libfltk_images.dll.a ${LIBRARY_PATH}
   
   #for a in $INSTALL_HEADERS; do
   #   ${CP} ${CP_FLAGS} ${SRCDIR}/FL/$a ${INCLUDE_PATH}/$a
   #done
   for a in ${SRCDIR}/FL/*.[hH]; do
      ${CP} ${CP_FLAGS} $a ${INCLUDE_PATH}
   done
   
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/fltk-config ${BINARY_PATH}
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post
}

uninstall()
{
   uninstall_pre;
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/mgwfltknox_forms-1.1.dll
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/mgwfltknox_gl-1.1.dll
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/mgwfltknox_images-1.1.dll
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/mgwfltknox-1.1.dll
   
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfltk.dll.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfltk_forms.dll.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfltk_gl.dll.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfltk_images.dll.a
   
   #for a in $INSTALL_HEADERS; do
   #   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   #done
   for a in ${SRCDIR}/FL/*.[hH]; do
      b=`basename $a`
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$b
   done
   
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/fltk-config
   
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   
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
