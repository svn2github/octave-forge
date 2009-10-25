#! /usr/bin/sh

# Name of package
PKG=GraphicsMagick
# Version of Package
VER=1.3.7
# Release of (this patched) package
REL=4
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.lzma
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://downloads.sourceforge.net/project/graphicsmagick/graphicsmagick/1.3.7/GraphicsMagick-1.3.7.tar.lzma"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=
# Any extra flags to pass make to
MAKE_XTRA=

# subdirectory to install heraders to (empty for default)
INCLUDE_DIR=

# Header files to install
HEADERS_INSTALL=

TOOLS="gm.exe"

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
api.h \
attribute.h \
average.h \
blob.h \
cdl.h \
channel.h \
color.h \
colormap.h \
colorspace.h \
command.h \
compare.h \
composite.h \
compress.h \
confirm_access.h \
constitute.h \
decorate.h \
delegate.h \
describe.h \
deprecate.h \
draw.h \
effect.h \
enhance.h \
error.h \
forward.h \
fx.h \
gem.h \
gradient.h \
hclut.h \
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
plasma.h \
profile.h \
quantize.h \
random.h \
registry.h \
render.h \
resize.h \
resource.h \
shear.h \
signature.h \
statistics.h \
symbols.h \
texture.h \
timer.h \
transform.h \
utility.h \
version.h
"

MGK_CONFIG_SRC="colors.mgk log.mgk magic.mgk modules.mgk"

MGK_CONFIG_BUILD="delegates.mgk type.mgk type-ghostscript.mgk type-windows.mgk"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL="Magick/GraphicsMagick.pc Magick++/lib/GraphicsMagick++.pc wand/GraphicsMagickWand.pc"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

MAKE_XTRA="CXXLIBS=$CXXLIBS"

#
#  To check a successful build and installation, you can issue the commands
#   gm convert -list delegates
#   gm convert -list magic
#   gm convert -list format
#   gm convert -list module
#   gm convert -list ressource
#   gm convert -list type
#

conf()
{
   conf_pre;
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC="${CC} $LIBGCCLDFLAGS" \
     CXX="${CXX} $LIBGCCLDFLAGS" \
     F77="${F77} $LIBGCCLDFLAGS" \
     CPP=$CPP \
     AR=$AR \
     RANLIB=$RANLIB \
     RC=$RC \
     STRIP=$STRIP \
     LD=$LD \
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CPPFLAGS="$CPPFLAGS -DProvideDllMain" \
     LDFLAGS="${LDFLAGS}" \
     CXXLIBS="${CXXLIBS}" \
     --prefix=${PREFIX} \
     --enable-shared \
     --without-perl \
     --without-x \
     --with-quantum-depth=16 \
     --without-threads \
     --disable-installed 
   )
   touch ${BUILDDIR}/have_configure
   modify_libtool_all ${BUILDDIR}/libtool
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick/.libs/GraphicsMagick.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick/.libs/libGraphicsMagick.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick/.libs/libGraphicsMagick.a ${STATICLIB_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick/GraphicsMagick-config ${BINARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick++/lib/GraphicsMagick++.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick++/lib/libGraphicsMagick++.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick++/lib/.libs/libGraphicsMagick++.a ${STATICLIB_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick++/bin/GraphicsMagick++-config ${BINARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/wand/.libs/GraphicsMagickWand.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/wand/.libs/libGraphicsMagickWand.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/wand/.libs/libGraphicsMagickWand.a ${STATICLIB_PATH}
   
   # Install executable tools
   for a in ${TOOLS}; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/utilities/.libs/$a ${BINARY_PATH}
   done
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}/`basename $a`
   done
   
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}
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
   
   mkdir -vp ${SHARE_PATH}/${PKGVER}/config
   for a in ${MGK_CONFIG_SRC}; do
     ${CP} ${CP_FLAGS} ${SRCDIR}/config/$a ${SHARE_PATH}/${PKGVER}/config
   done;
   
   for a in ${MGK_CONFIG_BUILD}; do
     ${CP} ${CP_FLAGS} ${BUILDDIR}/config/$a ${SHARE_PATH}/${PKGVER}/config
   done;
   
   # Install license file
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/Copyright.txt ${LICENSE_PATH}/${PKG}
   mkdir -vp ${LICENSE_PATH}/${PKG}/Magick++
   ${CP} ${CP_FLAGS} ${SRCDIR}/Magick++/COPYING ${LICENSE_PATH}/${PKG}/Magick++
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/GraphicsMagick.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libGraphicsMagick.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libGraphicsMagick.a
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/GraphicsMagick++.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libGraphicsMagick++.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libGraphicsMagick++.a
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/GraphicsMagickWand.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libGraphicsMagickWand.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libGraphicsMagickWand.a
   
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/GraphicsMagick-config
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/GraphicsMagick++-config
   
   # Uninstall executable tools
   for a in ${TOOLS}; do
      ${RM} ${RM_FLAGS} ${BINARY_PATH}/$a
   done
   
   # Uninstall headers
   for a in $MAGICK_HEADERS magick_config.h; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/magick/$a
   done
   rmdir --ignore-fail-on-non-empty ${INCLUDE_PATH}/magick
   
   for a in $MAGICKPP_HEADERS; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/magick++/$a
   done
   rmdir --ignore-fail-on-non-empty ${INCLUDE_PATH}/magick++
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/Magick++.h
   
   for a in $MGK_CONFIG_SRC $MGK_CONFIG_BUILD; do
      ${RM} ${RM_FLAGS} ${SHARE_PATH}/${PKGVER}/config/$a
   done
   rmdir --ignore-fail-on-non-empty ${SHARE_PATH}/${PKGVER}/config
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/`basename $a`
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/Copyright.txt
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/Magick++/COPYING
   rmdir --ignore-fail-on-non-empty ${LICENSE_PATH}/${PKG}/Magick++
   
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

main $*
