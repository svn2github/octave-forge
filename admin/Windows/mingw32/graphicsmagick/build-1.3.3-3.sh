#! /usr/bin/sh

# Name of package
PKG=GraphicsMagick
# Version of Package
VER=1.3.3
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
URL="http://downloads.sourceforge.net/graphicsmagick/GraphicsMagick-1.3.3.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
# MAKEFILE=win32/Makefile.gcc

# header files to be installed
INCLUDE_DIR=include/GraphicsMagick

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

conf()
{
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC="${CC} $LIBGCCLDFLAGS" \
     CXX="${CXX} $LIBGCCLDFLAGS" \
     F77="${F77} $LIBGCCLDFLAGS" \
     CPP=${CPP} \
     LDFLAGS="${LDFLAGS}" \
     CPPFLAGS="${GCC_ARCH_FLAGS}" \
     CFLAGS="$CFLAGS ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_OPT_FLAGS} -Wall" \
     LIBS="" \
     --prefix="${PREFIX}" \
     --enable-shared \
     --without-perl \
     --without-x \
     --with-quantum-depth=8 \
     --without-threads \
     --disable-installed 
     )

}

build()
{
   modify_libtool_all ${BUILDDIR}/libtool
   ( cd ${BUILDDIR} && make CXXLIBS="$CXXLIBS" )
}

TOOLS=""

MAGICKPP_HEADERS="
Blob.h \
CoderInfo.h \
Color.h \
Drawable.h \
Exception.h \
Geometry.h \
Image.h \
Include.h \
Montage.h \
Pixels.h \
STL.h \
TypeMetric.h" 

MAGICK_HEADERS="
PreRvIcccm.h \
api.h \
attribute.h \
blob.h \
channel.h \
color.h \
colorspace.h \
command.h \
compare.h \
composite.h \
compress.h \
constitute.h \
decorate.h \
delegate.h \
deprecate.h \
draw.h \
effect.h \
enhance.h \
error.h \
forward.h \
fx.h \
gem.h \
image.h \
list.h \
log.h \
magic.h \
magick.h \
magick_types.h \
memory.h \
module.h \
monitor.h \
montage.h \
operator.h \
paint.h \
pixel_cache.h \
pixel_iterator.h \
profile.h \
quantize.h \
registry.h \
render.h \
resize.h \
resource.h \
shear.h \
signature.h \
symbols.h \
timer.h \
transform.h \
utility.h \
version.h \
widget.h \
xwindow.h
"

install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick/.libs/GraphicsMagick.dll      ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick/.libs/libGraphicsMagick.dll.a    ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick/.libs/libGraphicsMagick.a        ${STATICLIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick/GraphicsMagick-config ${BINARY_PATH}

   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick++/lib/GraphicsMagick++.dll      ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick++/lib/libGraphicsMagick++.dll.a    ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick++/lib/.libs/libGraphicsMagick++.a        ${STATICLIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick++/bin/GraphicsMagick++-config ${BINARY_PATH}

   ${CP} ${CP_FLAGS} ${BUILDDIR}/wand/.libs/GraphicsMagickwand.dll      ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/wand/.libs/libGraphicsMagickwand.dll.a    ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/wand/.libs/libGraphicsMagickwand.a        ${STATICLIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/wand/GraphicsMagickWand-config ${BINARY_PATH}
   
   for a in ${TOOLS}; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/utilities/.libs/$a ${BINARY_PATH}
   done
   
   mkdir -vp ${INCLUDE_PATH}/magick
   for a in ${MAGICK_HEADERS}; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/Magick/$a ${INCLUDE_PATH}/magick
   done
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/Magick/magick_config_api.h ${INCLUDE_PATH}/magick/magick_config.h
   
   mkdir -vp ${INCLUDE_PATH}/Magick++
   ${CP} ${CP_TOOLS} ${SRCDIR}/magick++/lib/Magick++.h ${INCLUDE_PATH}
   for a in ${MAGICKPP_HEADERS}; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/magick++/lib/Magick++/$a ${INCLUDE_PATH}/Magick++
   done
   
   ${CP} ${BUILDDIR}/Magick/GraphicsMagick.pc ${PKGCONFIGDATA_PATH}
   ${CP} ${BUILDDIR}/Magick++/lib/GraphicsMagick++.pc ${PKGCONFIGDATA_PATH}
   ${CP} ${BUILDDIR}/wand/GraphicsMagickWand.pc ${PKGCONFIGDATA_PATH}
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/Copyright.txt ${LICENSE_PATH}/${PKG}
   mkdir -vp ${LICENSE_PATH}/${PKG}/Magick++
   ${CP} ${CP_FLAGS} ${SRCDIR}/Magick++/COPYING ${LICENSE_PATH}/${PKG}/Magick++
   
   install_post
}

uninstall()
{
   uninstall_pre;
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/GraphicsMagick.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libGraphicsMagick.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libGraphicsMagick.a
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/GraphicsMagick-config
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/GraphicsMagick++.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libGraphicsMagick++.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libGraphicsMagick++.a
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/GraphicsMagick++-config

   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/GraphicsMagickWand.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libGraphicsMagickWand.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libGraphicsMagickWand.a
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/GraphicsMagickWand-config
   
   for a in ${TOOLS}; do
      ${RM} ${RM_FLAGS} ${BINARY_PATH}/$a
   done
   
   for a in ${MAGICK_HEADERS}; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/magick/$a
   done
   
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/magick/magick_config.h
   rmdir -v ${INCLUDE_PATH}/Magick
   
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/Magick++.h
   for a in ${MAGICKPP_HEADERS}; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/magick++/$a
   done
   rmdir -v ${INCLUDE_PATH}/Magick++
   
   ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/GraphicsMagick.pc
   ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/GraphicsMagick++.pc
   ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/GraphicsMagickWand.pc
   
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/Copyright.txt
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/Magick++/COPYING
   rmdir ${LICENSE_PATH}/${PKG}/Magick++
   rmdir ${LICENSE_PATH}/${PKG}
   
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
