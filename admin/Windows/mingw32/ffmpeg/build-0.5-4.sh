#! /usr/bin/sh

# Name of package
PKG=ffmpeg
# Version of Package
VER=0.5
# Release of (this patched) package
REL=4
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.bz2
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL=""

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

# Herader files to install
HEADERS_INSTALL="
libavcodec/avcodec.h
libavcodec/opt.h
libavcodec/vdpau.h
libavcodec/xvmc.h
libavfilter/avfilter.h
libavutil/avutil.h
libavutil/adler32.h
libavutil/avstring.h
libavutil/base64.h
libavutil/common.h
libavutil/crc.h
libavutil/fifo.h
libavutil/intfloat_readwrite.h
libavutil/log.h
libavutil/lzo.h
libavutil/mathematics.h
libavutil/md5.h
libavutil/mem.h
libavutil/pixfmt.h
libavutil/random.h
libavutil/rational.h
libavutil/sha1.h
libavdevice/avdevice.h
libavformat/avformat.h
libavformat/avio.h
libswscale/swscale.h
"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL="
libavcodec/libavcodec.pc
libavdevice/libavdevice.pc
libavformat/libavformat.pc
libavutil/libavutil.pc
libswscale/libswscale.pc
"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

# MAKE_PARALLEL=""

conf()
{
   conf_pre;
   ( 
     # configure script does not allow to set
     # variables on command line, only selected
     #
     # Also building with -O3 results in an ICE in h264.c
     # so patch configure to set optimization level to -O2
     cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --source-path=${TOPDIR}/${SRCDIR} \
     --cc=$CC \
     --arch=i686 \
     --cpu=i686 \
     --prefix=${PREFIX} \
     --enable-static \
     --enable-memalign-hack \
     --enable-swscale \
     --enable-gpl \
     --extra-ldflags="$LDFLAGS"
   )
   touch ${BUILDDIR}/have_configure
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   for a in avcodec avdevice avformat avutil swscale; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a.dll ${SHAREDLIB_PATH}
      ${CP} ${CP_FLAGS} ${BUILDDIR}/lib$a.dll.a ${LIBRARY_PATH}
      #${CP} ${CP_FLAGS} ${BUILDDIR}/lib$a.a ${STATICLIB_PATH}
   done
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}/`basename $a`
   done
   
   # Install headers
   for a in libavcodec libavfilter libavutil libavdevice libavformat libswscale; do
      mkdir -vp ${INCLUDE_PATH}/$a
   done
   
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}/$a
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/README ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING.GPL ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING.LGPL ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   for a in avcodec avdevice avformat avutil swscale; do
      ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/$a.dll
      ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/lib$a.dll.a
      #${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libglob.a
   done
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   for a in libavcodec libavfilter libavutil libavdevice libavformat libswscale; do
      rmdir --ignore-fail-on-non-empty ${INCLUDE_PATH}/$a
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/`basename $a`
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/README
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING.GPL
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING.LGPL
   
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
