#! /usr/bin/sh

# Name of package
PKG=ncurses
# Version of Package
VER=5.7
# Release of (this patched) package
REL=5
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.gz
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://ftp.gnu.org/pub/gnu/ncurses/ncurses-5.7.tar.gz"
ROLLUPPATCHURL="ftp://invisible-island.net/ncurses/5.7/ncurses-5.7-20100424-patch.sh.bz2"
PATCHURL="ftp://invisible-island.net/ncurses/5.7/ncurses-5.7-20100501.patch.gz"

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

# Header files to install
HEADERS_INSTALL="term.h curses.h unctrl.h termcap.h ncurses_dll.h"

# License file(s) to install
LICENSE_INSTALL="README"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc45_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

# for install & uninstall...
NCURSES_ABI=5

download()
{
   download_core "$URL" 
   download_core "$ROLLUPPATCHURL"
   download_core "$PATCHURL"
}

unpack_post()
{
   ( cd $SRCDIR && unpack_rolluppatch )
   ( cd $SRCDIR && unpack_patch )
   # remove read-only attribute
   ( cd $SRCDIR && c:/windows/system32/attrib -r //s //d )
}

unpack_orig_post()
{
   ( cd $SRCDIR_ORIG && unpack_rolluppatch )
   ( cd $SRCDIR_ORIG && unpack_patch )
   # remove read-only attribute
   ( cd $SRCDIR_ORIG && c:/windows/system32/attrib -r //s //d )
}

unpack_patch()
{
   # apply official patches...
   for a in $PATCHURL; do
      p=`basename $a`
      echo applying $p...
      case $p in
         *.bz2)
	    bunzip2 -dc $TOPDIR/$p | patch -p1 
	    ;;
	 *.gz)
	    gunzip -cd $TOPDIR/$p | patch -p1 
	    ;;
      esac
   done
}

unpack_rolluppatch()
{
   rm -f include/ncurses_dll.h
   
   # apply official patches...
   for a in $ROLLUPPATCHURL; do
      p=`basename $a`
      echo applying $p...
      case $p in
         *.bz2)
	    bunzip2 -dc $TOPDIR/$p | patch -p1 
	    ;;
	 *.gz)
	    gunzip -cd $TOPDIR/$p | patch -p1 
	    ;;
      esac
   done
}

conf_pre()
{
    CONFIGURE_XTRA_ARGS="\
     --without-ada \
     --without-cxx \
     --without-cxx-binding \
     --with-shared \
     --with-libtool \
     --with-normal \
     --enable-term-driver \
     --enable-sp-funcs"
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   for a in ncurses form menu panel; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/.libs/lib$a-$NCURSES_ABI.dll    $PREFIX/$BIN_DIR
      ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/.libs/lib$a.dll.a  $PREFIX/$LIB_DIR
      ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/.libs/lib$a.a      $PREFIX/$STATICLIB_DIR
   done
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a $PREFIX/$PKGCONFIG_DIR
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/include/$a $PREFIX/$INC_DIR
   done
   
   ( cd ${BUILDDIR}/misc && make install prefix=$PREFIX ticdir=$PREFIX/share/terminfo )
   # ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/ncurses5-config

   # Install license file
   for a in $LICENSE_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/$a $PREFIX/$LIC_DIR/$PKG
   done
   
   install_post;
}

install_strip()
{
   install;
   for a in ncurses form menu panel; do
      $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/lib$a-$NCURSES_ABI.dll
   done
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   for a in ncurses form menu panel; do
      ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/lib$a-$NCURSES_ABI.dll
      ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/lib$a.dll.a
      ${RM} ${RM_FLAGS} $PREFIX/$STATICLIB_DIR/lib$a.a
   done
   
   # Uninstall headers
   for a in $HEADERS_INSTALL $HEADERS2_INSTALL ncurses.h; do
      ${RM} ${RM_FLAGS} $PREFIX/$INC_DIR/$a
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} $PREFIX/$PKGCONFIG_DIR/$a
   done
   
   ${RM} -rvf $PREFIX/$SHARE_DIR/terminfo
   ${RM} -rvf $PREFIX/$SHARE_DIR/tabset
   
   # Uninstall license file
   for a in $LICENSE_INSTALL; do
      ${RM} ${RM_FLAGS} $PREFIX/$LIC_DIR/$PKG/$a
   done
   
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
