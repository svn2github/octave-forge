#! /usr/bin/sh

# Name of package
PKG=glib
# Version of Package
VER=2.20.5
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
URL="http://ftp.gnome.org/pub/gnome/sources/glib/2.20/glib-2.20.5.tar.bz2"

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
INCLUDE_DIR=include/glib-2.0

# Herader files to install
HEADERS_INSTALL="
glib/glib.h
glib/glib-object.h
gmodule/gmodule.h"

HEADERS_GLIB="
galloca.h
garray.h
gasyncqueue.h
gatomic.h
gbacktrace.h
gbase64.h
gbookmarkfile.h
gcache.h
gchecksum.h
gcompletion.h
gconvert.h
gdataset.h
gdate.h
gdir.h
gerror.h
gfileutils.h
ghash.h
ghook.h
gi18n.h
gi18n-lib.h
giochannel.h
gkeyfile.h
glist.h
gmacros.h
gmain.h
gmappedfile.h
gmarkup.h
gmem.h
gmessages.h
gnode.h
goption.h
gpattern.h
gpoll.h
gprimes.h
gprintf.h
gqsort.h
gquark.h
gqueue.h
grand.h
gregex.h
grel.h
gscanner.h
gsequence.h
gshell.h
gslice.h
gslist.h
gspawn.h
gstdio.h
gstrfuncs.h
gstring.h
gtestutils.h
gthread.h
gthreadpool.h
gtimer.h
gtree.h
gtypes.h
gunicode.h
gurifuncs.h
gutils.h
gwin32.h"

HEADERS_GIO="
gappinfo.h
gasyncresult.h
gbufferedinputstream.h
gbufferedoutputstream.h
gcancellable.h
gcontenttype.h
gdatainputstream.h
gdataoutputstream.h
gdrive.h
gemblem.h
gemblemedicon.h
gfile.h
gfileattribute.h
gfileenumerator.h
gfileicon.h
gfileinfo.h
gfileinputstream.h
gfilemonitor.h
gfilenamecompleter.h
gfileoutputstream.h
gfilterinputstream.h
gfilteroutputstream.h
gicon.h
ginputstream.h
gio.h
gioenums.h
gioenumtypes.h
gioerror.h
giomodule.h
gioscheduler.h
giotypes.h
gloadableicon.h
gmemoryinputstream.h
gmemoryoutputstream.h
gmount.h
gmountoperation.h
gnativevolumemonitor.h
goutputstream.h
gseekable.h
gsimpleasyncresult.h
gthemedicon.h
gvfs.h
gvolume.h
gvolumemonitor.h"

HEADERS_GOBJECT="
gboxed.h
gclosure.h
genums.h
gmarshal.h
gobject.h
gobjectnotifyqueue.c
gparam.h
gparamspecs.h
gsignal.h
gsourceclosure.h
gtype.h
gtypemodule.h
gtypeplugin.h
gvalue.h
gvaluearray.h
gvaluecollector.h
gvaluetypes.h"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL="
glib-2.0.pc
gio-2.0.pc
gobject-2.0.pc
gmodule-2.0.pc
gmodule-no-export-2.0.pc
gthread-2.0.pc"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

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
     CPPFLAGS="$CPPFLAGS" \
     LDFLAGS="${LDFLAGS}" \
     CXXLIBS="${CXXLIBS}" \
     --prefix=${PREFIX} \
     --disable-static \
     --enable-shared \
     PKG_CONFIG=${TOPDIR}/pkg-config \
     --disable-gtk-doc \
     --with-pcre=system \
     PCRE_CFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS}" \
     PCRE_LIBS="-lpcre" \
     MSGFMT=${TOPDIR}/gettext/msgfmt
     
     # We must manually specify PCRE_CFLAGS and PCRE_LIBS because we do not have
     # pkg-config built yet!!
   )
   touch ${BUILDDIR}/have_configure
   modify_libtool_nolibprefix ${BUILDDIR}/libtool
   conf_post;
}

build_pre()
{
   ( cd ${BUILDDIR} && \
     make glibconfig.h.win32 && \
     make glibconfig.h && \
     mv glibconfig.h glibconfig.h.autogened && \
     cp -vp glibconfig.h.win32 glibconfig.h )
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gio/.libs/gio-2.0-0.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gio/.libs/libgio-2.0.dll.a ${LIBRARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/glib/.libs/glib-2.0-0.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/glib/.libs/libglib-2.0.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/glib/.libs/gspawn-win32-helper.exe ${BINARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/glib/.libs/gspawn-win32-helper-console.exe ${BINARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gmodule/.libs/gmodule-2.0-0.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gmodule/.libs/libgmodule-2.0.dll.a ${LIBRARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gobject/.libs/gobject-2.0-0.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gobject/.libs/libgobject-2.0.dll.a ${LIBRARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gthread/.libs/gthread-2.0-0.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gthread/.libs/libgthread-2.0.dll.a ${LIBRARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gobject/glib-mkenums ${BINARY_PATH}

   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   mkdir -vp ${INCLUDE_PATH}/glib
   mkdir -vp ${INCLUDE_PATH}/gio
   mkdir -vp ${INCLUDE_PATH}/gobject
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}/`basename $a`
   done
   
   for a in $HEADERS_GLIB; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/glib/$a ${INCLUDE_PATH}/glib/`basename $a`
   done
   
   for a in $HEADERS_GIO; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/gio/$a ${INCLUDE_PATH}/gio/`basename $a`
   done
   
   for a in $HEADERS_GOBJECT; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/gobject/$a ${INCLUDE_PATH}/gobject/`basename $a`
   done
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/glibconfig.h ${INCLUDE_PATH}
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/gmodule/COPYING ${LICENSE_PATH}/${PKG}/COPYING.gmodule
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/gio-2.0-0.dll
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/glib-2.0-0.dll
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/gmodule-2.0-0.dll
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/gobject-2.0-0.dll
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/gthread-2.0-0.dll
   
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libgio-2.0.dll.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libglib-2.0.dll.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libgmodule-2.0.dll.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libgobject-2.0.dll.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libgthread-2.0.dll.a
   
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/gspawn-win32-helper.exe
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/gspawn-win32-helper-console.exe
   
   # Uninstall headers
   for a in $HEADERS_INSTALL glibconfig.h; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/`basename $a`
   done
   
   for a in $HEADERS_GLIB; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/glib/`basename $a`
   done
   
   for a in $HEADERS_GIO; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/gio/`basename $a`
   done
   
   for a in $HEADERS_GOBJECT; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/gobject/`basename $a`
   done
   
   rmdir --ignore-fail-on-non-empty ${INCLUDE_PATH}/glib
   rmdir --ignore-fail-on-non-empty ${INCLUDE_PATH}/gio
   rmdir --ignore-fail-on-non-empty ${INCLUDE_PATH}/gobject
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING.gmodule
   
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
