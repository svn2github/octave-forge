#! /usr/bin/sh

# Name of package
PKG=glib
# Version of Package
VER=2.24.0
# Release of (this patched) package
REL=5
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.bz2
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://ftp.gnome.org/pub/gnome/sources/glib/2.24/glib-2.24.0.tar.bz2"

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
gbitlock.h 
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
ghostutils.h 
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
gtestutils.h 
gstring.h 
gthread.h 
gthreadpool.h 
gtimer.h 
gtree.h 
gtypes.h 
gunicode.h 
gurifuncs.h 
gutils.h 
gvarianttype.h 
gvariant.h 
gwin32.h 
gprintf.h 
"

HEADERS_GIO="
gappinfo.h 
gasyncinitable.h 
gasyncresult.h 
gbufferedinputstream.h 
gbufferedoutputstream.h 
gcancellable.h 
gcontenttype.h 
gcharsetconverter.h 
gconverter.h 
gconverterinputstream.h 
gconverteroutputstream.h 
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
gfileiostream.h 
gfilterinputstream.h 
gfilteroutputstream.h 
gicon.h 
ginetaddress.h 
ginetsocketaddress.h 
ginputstream.h 
ginitable.h 
gio.h 
giotypes.h 
gioenums.h 
gioerror.h 
giomodule.h 
gioscheduler.h 
giostream.h 
gloadableicon.h 
gmount.h 
gmemoryinputstream.h 
gmemoryoutputstream.h 
gmountoperation.h 
gnativevolumemonitor.h 
gnetworkaddress.h 
gnetworkservice.h 
goutputstream.h 
gresolver.h 
gseekable.h 
gsimpleasyncresult.h 
gsocket.h 
gsocketaddress.h 
gsocketaddressenumerator.h 
gsocketclient.h 
gsocketconnectable.h 
gsocketconnection.h 
gsocketcontrolmessage.h 
gsocketlistener.h 
gsocketservice.h 
gsrvtarget.h 
gtcpconnection.h 
gthreadedsocketservice.h 
gthemedicon.h 
gvfs.h 
gvolume.h 
gvolumemonitor.h 
gzlibcompressor.h 
gzlibdecompressor.h 
"

HEADERS_GOBJECT="
gboxed.h 
gclosure.h 
genums.h 
gobject.h 
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
gvaluetypes.h 
gobjectnotifyqueue.c 
gmarshal.h
"

# install subdirectory below $PREFIX/$INC_DIR (if any)
INC_SUBDIR=glib-2.0

# License file(s) to install
LICENSE_INSTALL="COPYING"

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
source ../gcc45_common.sh

# Directory the lib is built in (set this *after* loading gcc45_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

conf_pre()
{
    # You must manually specify PCRE_LIBS because we do not have
    # pkg-config built yet!!
    CONFIGURE_XTRA_ARGS="\
     --disable-static \
     --enable-shared \
     PKG_CONFIG=${TOPDIR}/pkg-config \
     --disable-gtk-doc \
     --with-pcre=system \
     PCRE_LIBS=-lpcre \
     MSGFMT=${TOPDIR}/gettext/msgfmt"
}

conf_post()
{
   modify_libtool_nolibprefix ${BUILDDIR}/libtool
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
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gio/.libs/gio-2.0-0.dll $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gio/.libs/libgio-2.0.dll.a $PREFIX/$LIB_DIR
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/glib/.libs/glib-2.0-0.dll $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/glib/.libs/libglib-2.0.dll.a $PREFIX/$LIB_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/glib/.libs/gspawn-win32-helper.exe $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/glib/.libs/gspawn-win32-helper-console.exe $PREFIX/$BIN_DIR
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gmodule/.libs/gmodule-2.0-0.dll $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gmodule/.libs/libgmodule-2.0.dll.a $PREFIX/$LIB_DIR
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gobject/.libs/gobject-2.0-0.dll $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gobject/.libs/libgobject-2.0.dll.a $PREFIX/$LIB_DIR
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gthread/.libs/gthread-2.0-0.dll $PREFIX/$BIN_DIR
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gthread/.libs/libgthread-2.0.dll.a $PREFIX/$LIB_DIR
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gobject/glib-mkenums $PREFIX/$BIN_DIR

   mkdir -vp $PREFIX/$INC_DIR/$INC_SUBDIR/glib
   mkdir -vp $PREFIX/$INC_DIR/$INC_SUBDIR/gio
   mkdir -vp $PREFIX/$INC_DIR/$INC_SUBDIR/gobject
   
   # Install headers
   for a in $HEADERS_GLIB; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/glib/$a $PREFIX/$INC_DIR/$INC_SUBDIR/glib/`basename $a`
   done
   
   for a in $HEADERS_GIO; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/gio/$a $PREFIX/$INC_DIR/$INC_SUBDIR/gio/`basename $a`
   done
   
   for a in $HEADERS_GOBJECT; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/gobject/$a $PREFIX/$INC_DIR/$INC_SUBDIR/gobject/`basename $a`
   done
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/glibconfig.h $PREFIX/$INC_DIR/$INC_SUBDIR
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/gmodule/COPYING $PREFIX/$LIC_DIR/${PKG}/COPYING.gmodule
   
   install_common;
   install_post;
}

install_strip()
{
   install;
   for a in gio-2.0-0.dll glib-2.0-0.dll gmodule-2.0-0.dll gobject-2.0-0.dll gthread-2.0-0.dll; do
      $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/$a
   done
   
   for a in gspawn-win32-helper.exe gspawn-win32-helper-console.exe; do
      $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/$a
   done
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/gio-2.0-0.dll
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/glib-2.0-0.dll
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/gmodule-2.0-0.dll
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/gobject-2.0-0.dll
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/gthread-2.0-0.dll
   
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libgio-2.0.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libglib-2.0.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libgmodule-2.0.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libgobject-2.0.dll.a
   ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/libgthread-2.0.dll.a
   
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/gspawn-win32-helper.exe
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/gspawn-win32-helper-console.exe
   
   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/glib-mkenums
   
   uninstall_common;
   
   # Uninstall headers
   for a in glibconfig.h; do
      ${RM} ${RM_FLAGS} $PREFIX/$INC_DIR/$INC_SUBDIR/`basename $a`
   done
   
   for a in $HEADERS_GLIB; do
      ${RM} ${RM_FLAGS} $PREFIX/$INC_DIR/$INC_SUBDIR/glib/`basename $a`
   done
   
   for a in $HEADERS_GIO; do
      ${RM} ${RM_FLAGS} $PREFIX/$INC_DIR/$INC_SUBDIR/gio/`basename $a`
   done
   
   for a in $HEADERS_GOBJECT; do
      ${RM} ${RM_FLAGS} $PREFIX/$INC_DIR/$INC_SUBDIR/gobject/`basename $a`
   done
   
   rmdir --ignore-fail-on-non-empty $PREFIX/$INC_DIR/$INC_SUBDIR/glib
   rmdir --ignore-fail-on-non-empty $PREFIX/$INC_DIR/$INC_SUBDIR/gio
   rmdir --ignore-fail-on-non-empty $PREFIX/$INC_DIR/$INC_SUBDIR/gobject
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} $PREFIX/$LIC_DIR/${PKG}/COPYING.gmodule
   
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
