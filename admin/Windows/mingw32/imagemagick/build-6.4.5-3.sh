#! /usr/bin/sh

# Name of package
PKG=ImageMagick
# Version of Package
VER=6.4.5
# Release of (this patched) package
REL=3
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}-0.tar.bz2
TAR_TYPE=j
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="ftp://ftp.imagemagick.org/pub/ImageMagick/ImageMagick-6.4.5-0.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
# MAKEFILE=win32/Makefile.gcc

# header files to be installed
#INSTALL_HEADERS="tiff.h tiffvers.h tiffio.h"
#INSTALL_HEADERS_BUILD="tiffconf.h"
#INCLUDE_DIR=

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
     LDFLAGS="${LDFLAGS} -L${LIBRARY_PATH}" \
     CPPFLAGS="${GCC_ARCH_FLAGS}" \
     CFLAGS="$CFLAGS ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_OPT_FLAGS} -Wall" \
     LIBS="" \
     --prefix="${PREFIX}" \
     --enable-shared \
     --without-perl \
     --without-x \
     --with-quantum-depth=8 \
     --with-fontconfig \
     FONTCONFIG_CFLAGS="$CFLAGS ${GCC_OPT_FLAGS} -Wall" \
     FONTCONFIG_LIBS="-lfontconfig -lexpat -lfreetype -lz" \
     --without-threads \
     --disable-installed
     )
}

build()
{
   ( cd ${BUILDDIR} && make CXXLIBS="$CXXLIBS" )
}

TOOLS="convert.exe"
MAGICKPP_HEADERS="
Blob.h
CoderInfo.h 
Color.h 
Drawable.h 
Exception.h 
Geometry.h 
Image.h 
Include.h 
Montage.h 
Pixels.h 
STL.h 
TypeMetric.h" 

MAGICK_HEADERS="
methods.h
magick-type.h
animate.h
annotate.h
artifact.h
blob.h
cache.h
cache-view.h
cipher.h
client.h
coder.h
color.h
colorspace.h
compare.h
composite.h
compress.h
configure.h
constitute.h
decorate.h
delegate.h
deprecate.h
display.h
distort.h
draw.h
effect.h
enhance.h
exception.h
fx.h
gem.h
geometry.h
hashmap.h
identify.h
image.h
layer.h
list.h
locale_.h
log.h
magic.h
magick.h
matrix.h
memory_.h
module.h
mime.h
monitor.h
montage.h
option.h
paint.h
pixel.h
prepress.h
profile.h
property.h
quantize.h
quantum.h
registry.h
random_.h
resample.h
resize.h
resource_.h
segment.h
semaphore.h
shear.h
signature.h
splay-tree.h
stream.h
statistic.h
string_.h
timer.h
token.h
transform.h
threshold.h
type.h
utility.h
version.h
xml-tree.h
xwindow.h
magickcore.h"

WAND_HEADERS="
animate.h
compare.h
composite.h
conjure.h
convert.h
deprecate.h
display.h
drawing-wand.h
identify.h
import.h
magick-property.h
magick-image.h
MagickWand.h
magick-wand.h
mogrify.h
montage.h
pixel-iterator.h
pixel-view.h
pixel-wand.h
stream.h"

modify_config()
{
   $SED \
   -e "s@-shared-libgcc@@g" \
   -e "s@-L[^ ]*@@g" \
   -e "s@-I[^ ]*@@g" \
   < $1 > $2
}
   
install()
{
   install_pre;
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick/.libs/libmagickcore.dll      ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick/.libs/libmagickcore.dll.a    ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick/.libs/libmagickcore.a        ${STATICLIBRARY_PATH}
   
   modify_config ${BUILDDIR}/magick/Magick-config ${BINARY_PATH}/Magick-config
   modify_config ${BUILDDIR}/magick/MagickCore-config ${BINARY_PATH}/MagickCore-config
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick++/lib/libmagick++.dll      ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick++/lib/libmagick++.dll.a    ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/magick++/lib/.libs/libmagick++.a        ${STATICLIBRARY_PATH}
   
   modify_config ${BUILDDIR}/magick++/bin/Magick++-config ${BINARY_PATH}/Magick++-config

   ${CP} ${CP_FLAGS} ${BUILDDIR}/wand/.libs/libmagickwand.dll      ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/wand/.libs/libmagickwand.dll.a    ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/wand/.libs/libmagickwand.a        ${STATICLIBRARY_PATH}
   
   modify_config ${BUILDDIR}/wand/Wand-config ${BINARY_PATH}/Wand-config
   modify_config ${BUILDDIR}/wand/MagickWand-config ${BINARY_PATH}/MagickWand-config
   
   for a in ${TOOLS}; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/utilities/.libs/$a ${BINARY_PATH}
   done
   
   mkdir -vp ${INCLUDE_PATH}/Magick++
   ${CP} ${CP_TOOLS} ${SRCDIR}/magick++/lib/Magick++.h ${INCLUDE_PATH}
   for a in ${MAGICKPP_HEADERS}; do
      ${CP} ${CP_TOOLS} ${SRCDIR}/magick++/lib/Magick++/$a ${INCLUDE_PATH}/Magick++
   done
   
   mkdir -vp ${INCLUDE_PATH}/Magick
   ${CP} ${CP_TOOLS} ${BUILDDIR}/magick/magick-config.h ${INCLUDE_PATH}/Magick
   for a in ${MAGICK_HEADERS}; do
      ${CP} ${CP_TOOLS} ${SRCDIR}/magick/$a ${INCLUDE_PATH}/Magick
   done
   
   mkdir -vp ${INCLUDE_PATH}/Wand
   for a in ${WAND_HEADERS}; do
      ${CP} ${CP_TOOLS} ${SRCDIR}/Wand/$a ${INCLUDE_PATH}/Wand
   done
   
   mkdir -vp ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/LICENSE ${LICENSE_PATH}/${PKG}
   mkdir -vp ${LICENSE_PATH}/${PKG}/Magick++
   ${CP} ${CP_FLAGS} ${SRCDIR}/Magick++/LICENSE ${LICENSE_PATH}/${PKG}/Magick++
   
   install_post
}

#install()
#{
#  ( cd ${BUILDDIR} && make install )
#}
   
uninstall()
{
   uninstall_pre;
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/libmagickcore.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libmagickcore.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libmagickcore.a
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/Magick-config
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/MagickCore-config
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/libmagick++.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libmagick++.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libmagick++.a
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/Magick++-config

   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/libmagickwand.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libmagickwand.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/libmagickwand.a
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/Wand-config
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/MagickWand-config
   
   for a in ${TOOLS}; do
      ${RM} ${RM_FLAGS} ${BINARY_PATH}/$a
   done
   
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/Magick++.h
   for a in ${MAGICKPP_HEADERS}; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/magick++/$a
   done
   rmdir -v ${INCLUDE_PATH}/Magick++
   
   for a in ${MAGICK_HEADERS}; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/magick/$a
   done
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/magick/magick-config.h
   rmdir -v ${INCLUDE_PATH}/Magick
   
   for a in ${WAND_HEADERS}; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/Wand/$a
   done
   rmdir -v ${INCLUDE_PATH}/Wand
   
   
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/LICENSE
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/Magick++/LICENSE
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
