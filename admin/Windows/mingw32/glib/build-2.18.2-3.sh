#! /usr/bin/sh

# Name of package
PKG=glib
# Version of Package
VER=2.18.2
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
URL="http://ftp.gnome.org/pub/gnome/sources/glib/2.18/glib-2.18.2.tar.bz2"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use
MAKEFILE=""
# header files to be installed
INCLUDE_DIR=include/glib-2.0

INSTALL_GLIB="
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

INSTALL_GIO="
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

INSTALL_GOBJECT="
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

PKG_CONFIG_FILES="
glib-2.0.pc
gio-2.0.pc
gobject-2.0.pc
gmodule-2.0.pc
gthread-2.0.pc"

source ../gcc43_common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

echo ${PREFIX}

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }

conf()
{
  ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure --srcdir=../${SRCDIR} \
    CC=${CC} \
    CXX=${CXX} \
    F77=${F77} \
    CPP=${CPP} \
    CPPFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS}" \
    LDFLAGS="${LDFLAGS}" \
    --disable-static \
    --enable-shared \
    --prefix=${PREFIX}/gtk \
    PKG_CONFIG=${TOPDIR}/pkg-config \
    --disable-gtk-doc \
    --with-pcre=system \
    PCRE_CFLAGS="${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS}" \
    PCRE_LIBS="-lpcre"
  )
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
   
   mkdir -v ${LICENSE_PATH}/${PKG}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gio/.libs/libgio-2.0-0.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gio/.libs/libgio-2.0.dll.a ${LIBRARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/glib/.libs/libglib-2.0-0.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/glib/.libs/libglib-2.0.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/glib/.libs/gspawn-win32-helper.exe ${BINARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/glib/.libs/gspawn-win32-helper-console.exe ${BINARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gmodule/.libs/libgmodule-2.0-0.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gmodule/.libs/libgmodule-2.0.dll.a ${LIBRARY_PATH}

   ${CP} ${CP_FLAGS} ${BUILDDIR}/gobject/.libs/libgobject-2.0-0.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gobject/.libs/libgobject-2.0.dll.a ${LIBRARY_PATH}

   ${CP} ${CP_FLAGS} ${BUILDDIR}/gthread/.libs/libgthread-2.0-0.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/gthread/.libs/libgthread-2.0.dll.a ${LIBRARY_PATH}

   mkdir -vp ${INCLUDE_PATH}/glib
   mkdir -vp ${INCLUDE_PATH}/gio
   mkdir -vp ${INCLUDE_PATH}/gobject
   
   for a in ${INSTALL_GLIB}; do ${CP} ${CP_FLAGS} ${SRCDIR}/glib/$a ${INCLUDE_PATH}/glib; done
   for a in ${INSTALL_GIO};  do ${CP} ${CP_FLAGS} ${SRCDIR}/gio/$a  ${INCLUDE_PATH}/gio;  done
   for a in ${INSTALL_GOBJECT};  do ${CP} ${CP_FLAGS} ${SRCDIR}/gobject/$a  ${INCLUDE_PATH}/gobject;  done
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/glib/glib.h ${INCLUDE_PATH}
   ${CP} ${CP_FLAGS} ${SRCDIR}/glib/glib-object.h ${INCLUDE_PATH}
   ${CP} ${CP_FLAGS} ${SRCDIR}/gmodule/gmodule.h ${INCLUDE_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/glibconfig.h ${INCLUDE_PATH}
   
   # install license information
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/gmodule/COPYING ${LICENSE_PATH}/${PKG}/COPYING.gmodule
   
   # install pkg-config information
   for a in ${PKG_CONFIG_FILES}; do ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}; done
   
}

uninstall()
{
   uninstall_pre;
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/libgio-2.0-0.dll
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/libglib-2.0-0.dll
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/libgmodule-2.0-0.dll
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/libgobject-2.0-0.dll
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/libgthread-2.0-0.dll
   
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libgio-2.0.dll.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libglib-2.0.dll.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libgmodule-2.0.dll.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libgobject-2.0.dll.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libgthread-2.0.dll.a
   
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/gspawn-win32-helper.exe
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/gspawn-win32-helper-console.exe
   
   for a in ${INSTALL_GLIB}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/glib/$a; done
   for a in ${INSTALL_GIO}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/gio/$a; done
   for a in ${INSTALL_GOBJECT}; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/gobject/$a; done
   
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/glib.h
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/glib-object.h
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/gmodule.h
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/glibconfig.h
   
   rmdir -v ${INCLUDE_PATH}
   
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING.gmodule
   
   rmdir -v ${LICENSE_PATH}/${PKG}
   
   # uninstall pkg-config information
   for a in ${PKG_CONFIG_FILES}; do ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a; done
   rmdir --ignore-fail-on-non-empty ${PKGCONFIGDATA_PATH}

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
