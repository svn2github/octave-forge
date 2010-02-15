#! /usr/bin/sh

# Name of package
PKG=wxwidgets
# Version of Package
VER=2.8.10
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
URL="http://downloads.sourceforge.net/project/wxwindows/wxAll/2.8.10/wxWidgets-2.8.10.tar.bz2"

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
INCLUDE_DIR=include/wx-2.8

# Herader files to install
HEADERS_INSTALL="
wx/afterstd.h 
wx/app.h 
wx/apptrait.h 
wx/archive.h 
wx/arrimpl.cpp 
wx/arrstr.h 
wx/beforestd.h 
wx/buffer.h 
wx/build.h 
wx/chkconf.h 
wx/clntdata.h 
wx/cmdline.h 
wx/confbase.h 
wx/config.h 
wx/convauto.h 
wx/containr.h 
wx/cpp.h 
wx/datetime.h 
wx/datstrm.h 
wx/dde.h 
wx/debug.h 
wx/defs.h 
wx/dir.h 
wx/dlimpexp.h 
wx/dynarray.h 
wx/dynlib.h 
wx/dynload.h 
wx/encconv.h 
wx/event.h 
wx/except.h 
wx/features.h 
wx/ffile.h 
wx/file.h 
wx/fileconf.h 
wx/filefn.h 
wx/filename.h 
wx/filesys.h 
wx/fontenc.h 
wx/fontmap.h 
wx/fs_arc.h 
wx/fs_filter.h 
wx/fs_mem.h 
wx/fs_zip.h 
wx/hash.h 
wx/hashmap.h 
wx/hashset.h 
wx/html/forcelnk.h 
wx/iconloc.h 
wx/init.h 
wx/intl.h 
wx/iosfwrap.h 
wx/ioswrap.h 
wx/ipc.h 
wx/ipcbase.h 
wx/isql.h 
wx/isqlext.h 
wx/link.h 
wx/list.h 
wx/listimpl.cpp 
wx/log.h 
wx/longlong.h 
wx/math.h 
wx/memconf.h 
wx/memory.h 
wx/memtext.h 
wx/mimetype.h 
wx/module.h 
wx/msgout.h 
wx/mstream.h 
wx/object.h 
wx/platform.h 
wx/platinfo.h 
wx/power.h 
wx/process.h 
wx/ptr_scpd.h 
wx/recguard.h 
wx/regex.h 
wx/scopeguard.h 
wx/snglinst.h 
wx/sstream.h 
wx/stack.h 
wx/stackwalk.h 
wx/stdpaths.h 
wx/stockitem.h 
wx/stopwatch.h 
wx/strconv.h 
wx/stream.h 
wx/string.h 
wx/sysopt.h 
wx/tarstrm.h 
wx/textbuf.h 
wx/textfile.h 
wx/thread.h 
wx/thrimpl.cpp 
wx/timer.h 
wx/tokenzr.h 
wx/txtstrm.h 
wx/types.h 
wx/uri.h 
wx/utils.h 
wx/variant.h 
wx/vector.h 
wx/version.h 
wx/volume.h 
wx/wfstream.h 
wx/wx.h 
wx/wxchar.h 
wx/wxprec.h 
wx/xti.h 
wx/xtistrm.h 
wx/zipstrm.h 
wx/zstream.h 
wx/msw/apptrait.h 
wx/msw/apptbase.h 
wx/msw/chkconf.h 
wx/msw/crashrpt.h 
wx/msw/dde.h 
wx/msw/debughlp.h 
wx/msw/gccpriv.h 
wx/msw/libraries.h 
wx/msw/mimetype.h 
wx/msw/mslu.h 
wx/msw/private.h 
wx/msw/regconf.h 
wx/msw/registry.h 
wx/msw/seh.h 
wx/msw/stackwalk.h 
wx/msw/stdpaths.h 
wx/msw/winundef.h 
wx/msw/wrapcctl.h 
wx/msw/wrapcdlg.h 
wx/msw/wrapwin.h  
wx/fs_inet.h 
wx/gsocket.h 
wx/protocol/file.h 
wx/protocol/ftp.h 
wx/protocol/http.h 
wx/protocol/protocol.h 
wx/sckaddr.h 
wx/sckipc.h 
wx/sckstrm.h 
wx/socket.h 
wx/url.h 
wx/msw/gsockmsw.h  
wx/xml/xml.h 
wx/xtixml.h 
wx/db.h 
wx/dbkeyg.h 
wx/dbtable.h 
wx/bmpbuttn.h 
wx/brush.h 
wx/button.h 
wx/checkbox.h 
wx/checklst.h 
wx/choicdlg.h 
wx/choice.h 
wx/cmndata.h 
wx/collpane.h 
wx/combo.h 
wx/combobox.h 
wx/control.h 
wx/ctrlsub.h 
wx/cursor.h 
wx/dc.h 
wx/dcclient.h 
wx/dcgraph.h 
wx/dcmemory.h 
wx/dcprint.h 
wx/dcscreen.h 
wx/dialog.h 
wx/dirdlg.h 
wx/dragimag.h 
wx/encinfo.h 
wx/filedlg.h 
wx/frame.h 
wx/gauge.h 
wx/gbsizer.h 
wx/gdicmn.h 
wx/generic/accel.h 
wx/generic/buttonbar.h 
wx/generic/choicdgg.h 
wx/generic/clrpickerg.h 
wx/generic/collpaneg.h 
wx/generic/colrdlgg.h 
wx/generic/combo.h 
wx/generic/dcpsg.h 
wx/generic/dirctrlg.h 
wx/generic/dragimgg.h 
wx/generic/filedlgg.h 
wx/generic/filepickerg.h 
wx/generic/fontdlgg.h 
wx/generic/fontpickerg.h 
wx/generic/logg.h 
wx/generic/msgdlgg.h 
wx/generic/numdlgg.h 
wx/generic/notebook.h 
wx/generic/panelg.h 
wx/generic/prntdlgg.h 
wx/generic/printps.h 
wx/generic/progdlgg.h 
wx/generic/scrolwin.h 
wx/generic/spinctlg.h 
wx/generic/splitter.h 
wx/generic/srchctlg.h 
wx/generic/textdlgg.h 
wx/generic/timer.h 
wx/generic/treectlg.h 
wx/graphics.h 
wx/helphtml.h 
wx/icon.h 
wx/layout.h 
wx/listbox.h 
wx/mdi.h 
wx/menu.h 
wx/msgdlg.h 
wx/numdlg.h 
wx/overlay.h 
wx/palette.h 
wx/panel.h 
wx/pen.h 
wx/radiobox.h 
wx/radiobut.h 
wx/renderer.h 
wx/scrolbar.h 
wx/scrolbar.h 
wx/scrolwin.h 
wx/selstore.h 
wx/settings.h 
wx/sizer.h 
wx/slider.h 
wx/statbmp.h 
wx/statbox.h 
wx/stattext.h 
wx/statusbr.h 
wx/textctrl.h 
wx/textdlg.h 
wx/toolbar.h 
wx/validate.h 
wx/valtext.h 
wx/window.h 
wx/wupdlock.h 
wx/accel.h 
wx/access.h 
wx/anidecod.h 
wx/artprov.h 
wx/bitmap.h 
wx/bookctrl.h 
wx/busyinfo.h 
wx/generic/busyinfo.h 
wx/caret.h 
wx/choicebk.h 
wx/clipbrd.h 
wx/clrpicker.h 
wx/cmdproc.h 
wx/colordlg.h 
wx/colour.h 
wx/cshelp.h 
wx/dataobj.h 
wx/dcmirror.h 
wx/dcps.h 
wx/dialup.h 
wx/dirctrl.h 
wx/display.h 
wx/display_impl.h 
wx/dnd.h 
wx/docmdi.h 
wx/docview.h 
wx/effects.h 
wx/evtloop.h 
wx/fdrepdlg.h 
wx/filepicker.h 
wx/fontpicker.h 
wx/fmappriv.h 
wx/font.h 
wx/fontdlg.h 
wx/fontenum.h 
wx/fontutil.h 
wx/gdiobj.h 
wx/geometry.h 
wx/gifdecod.h 
wx/glcanvas.h 
wx/help.h 
wx/helpbase.h 
wx/helpwin.h 
wx/iconbndl.h 
wx/imagbmp.h 
wx/image.h 
wx/imaggif.h 
wx/imagiff.h 
wx/imagjpeg.h 
wx/imaglist.h 
wx/imagpcx.h 
wx/imagpng.h 
wx/imagpnm.h 
wx/imagtga.h 
wx/imagtiff.h 
wx/imagxpm.h 
wx/listbase.h 
wx/listbook.h 
wx/listctrl.h 
wx/matrix.h 
wx/menuitem.h 
wx/metafile.h 
wx/minifram.h 
wx/notebook.h 
wx/ownerdrw.h 
wx/paper.h 
wx/pickerbase.h 
wx/popupwin.h 
wx/print.h 
wx/printdlg.h 
wx/prntbase.h 
wx/progdlg.h 
wx/ptr_scpd.h 
wx/quantize.h 
wx/rawbmp.h 
wx/region.h 
wx/scopeguard.h 
wx/spinbutt.h 
wx/spinctrl.h 
wx/splitter.h 
wx/srchctrl.h 
wx/statline.h 
wx/tab.h 
wx/tabctrl.h 
wx/tbarbase.h 
wx/tglbtn.h 
wx/tipwin.h 
wx/toolbook.h 
wx/tooltip.h 
wx/toplevel.h 
wx/treebase.h 
wx/treebook.h 
wx/treectrl.h 
wx/valgen.h 
wx/vidmode.h 
wx/vlbox.h 
wx/vms_x_fix.h 
wx/vscroll.h 
wx/xpmdecod.h 
wx/xpmhand.h
wx/msw/popupwin.h
wx/msw/uxtheme.h
wx/msw/uxthemep.h
wx/msw/htmlhelp.h
wx/msw/helpchm.h
wx/msw/helpwin.h
wx/generic/clrpickerg.h
wx/generic/fontpickerg.h
wx/generic/filepickerg.h
wx/msw/accel.h
wx/msw/app.h
wx/msw/bitmap.h
wx/msw/bmpbuttn.h
wx/msw/brush.h
wx/msw/button.h
wx/msw/caret.h
wx/msw/checkbox.h
wx/msw/choice.h
wx/msw/clipbrd.h
wx/msw/colordlg.h
wx/msw/colour.h
wx/msw/combo.h
wx/msw/combobox.h
wx/msw/control.h
wx/msw/cursor.h
wx/msw/dc.h
wx/msw/dcclient.h
wx/msw/dcmemory.h
wx/msw/dcprint.h
wx/msw/dcscreen.h
wx/msw/dialog.h
wx/msw/dib.h
wx/msw/dirdlg.h
wx/msw/dragimag.h
wx/msw/enhmeta.h
wx/msw/evtloop.h
wx/msw/filedlg.h
wx/msw/font.h
wx/msw/frame.h
wx/msw/gauge95.h
wx/msw/gdiimage.h
wx/msw/icon.h
wx/msw/imaglist.h
wx/msw/iniconf.h
wx/msw/listbox.h
wx/msw/listctrl.h
wx/msw/mdi.h
wx/msw/menu.h
wx/msw/menuitem.h
wx/msw/metafile.h
wx/msw/minifram.h
wx/msw/missing.h
wx/msw/msgdlg.h
wx/msw/msvcrt.h
wx/msw/notebook.h
wx/msw/ole/access.h
wx/msw/ole/dataform.h
wx/msw/ole/dataobj.h
wx/msw/ole/dataobj2.h
wx/msw/ole/dropsrc.h
wx/msw/ole/droptgt.h
wx/msw/ole/oleutils.h
wx/msw/palette.h
wx/msw/pen.h
wx/msw/printdlg.h
wx/msw/printwin.h
wx/msw/radiobox.h
wx/msw/radiobut.h
wx/msw/region.h
wx/msw/rcdefs.h
wx/msw/scrolbar.h
wx/msw/setup0.h
wx/msw/slider95.h
wx/msw/spinbutt.h
wx/msw/spinctrl.h
wx/msw/statbmp.h
wx/msw/statbox.h
wx/msw/statbr95.h
wx/msw/statline.h
wx/msw/stattext.h
wx/msw/tabctrl.h
wx/msw/tbar95.h
wx/msw/textctrl.h
wx/msw/tglbtn.h
wx/msw/timer.h
wx/msw/tooltip.h
wx/msw/toplevel.h
wx/msw/treectrl.h
wx/msw/window.h
wx/msw/wx.manifest
wx/msw/amd64.manifest
wx/msw/ia64.manifest
wx/msw/wx.rc
wx/msw/colours.bmp
wx/msw/csquery.bmp
wx/msw/blank.cur
wx/msw/bullseye.cur
wx/msw/cross.cur
wx/msw/hand.cur
wx/msw/magnif1.cur
wx/msw/pbrush.cur
wx/msw/pencil.cur
wx/msw/pntleft.cur
wx/msw/pntright.cur
wx/msw/rightarr.cur
wx/msw/roller.cur
wx/msw/cdrom.ico
wx/msw/child.ico
wx/msw/computer.ico
wx/msw/drive.ico
wx/msw/file1.ico
wx/msw/floppy.ico
wx/msw/folder1.ico
wx/msw/folder2.ico
wx/msw/mdi.ico
wx/msw/question.ico
wx/msw/removble.ico
wx/msw/std.ico
wx/msw/checklst.h
wx/msw/fdrepdlg.h
wx/msw/fontdlg.h
wx/msw/ole/automtn.h
wx/msw/ole/uuid.h
wx/animate.h
wx/animdecod.h
wx/bmpcbox.h
wx/calctrl.h
wx/dataview.h
wx/datectrl.h
wx/dateevt.h
wx/dcbuffer.h
wx/aboutdlg.h
wx/generic/aboutdlgg.h
wx/generic/animate.h
wx/generic/bmpcbox.h
wx/generic/calctrl.h
wx/generic/datectrl.h
wx/generic/dataview.h
wx/generic/grid.h
wx/generic/gridctrl.h
wx/generic/gridsel.h
wx/generic/helpext.h
wx/generic/laywin.h
wx/generic/propdlg.h
wx/generic/sashwin.h
wx/generic/splash.h
wx/generic/wizard.h
wx/grid.h
wx/hyperlink.h
wx/joystick.h
wx/laywin.h
wx/odcombo.h
wx/propdlg.h
wx/sashwin.h
wx/sound.h
wx/splash.h
wx/taskbar.h
wx/tipdlg.h
wx/wave.h
wx/wizard.h
wx/msw/sound.h
wx/msw/taskbar.h
wx/msw/joystick.h
wx/msw/datectrl.h
wx/mediactrl.h
wx/msw/ole/activex.h
wx/html/helpctrl.h
wx/html/helpdata.h
wx/html/helpdlg.h
wx/html/helpfrm.h
wx/html/helpwnd.h
wx/html/htmlcell.h
wx/html/htmldefs.h
wx/html/htmlfilt.h
wx/html/htmlpars.h
wx/html/htmlproc.h
wx/html/htmltag.h
wx/html/htmlwin.h
wx/html/htmprint.h
wx/html/m_templ.h
wx/html/winpars.h
wx/wxhtml.h
wx/htmllbox.h
wx/msw/helpbest.h
wx/msw/glcanvas.h
wx/debugrpt.h
wx/dbgrid.h
wx/xrc/xh_all.h
wx/xrc/xh_animatctrl.h
wx/xrc/xh_bmpbt.h
wx/xrc/xh_bmp.h
wx/xrc/xh_bmpcbox.h
wx/xrc/xh_bttn.h
wx/xrc/xh_cald.h
wx/xrc/xh_chckb.h
wx/xrc/xh_chckl.h
wx/xrc/xh_choic.h
wx/xrc/xh_choicbk.h
wx/xrc/xh_clrpicker.h
wx/xrc/xh_collpane.h
wx/xrc/xh_combo.h
wx/xrc/xh_datectrl.h
wx/xrc/xh_dirpicker.h
wx/xrc/xh_dlg.h
wx/xrc/xh_filepicker.h
wx/xrc/xh_fontpicker.h
wx/xrc/xh_frame.h
wx/xrc/xh_mdi.h
wx/xrc/xh_gauge.h
wx/xrc/xh_gdctl.h
wx/xrc/xh_grid.h
wx/xrc/xh_html.h
wx/xrc/xh_hyperlink.h
wx/xrc/xh_listb.h
wx/xrc/xh_listbk.h
wx/xrc/xh_listc.h
wx/xrc/xh_menu.h
wx/xrc/xh_notbk.h
wx/xrc/xh_odcombo.h
wx/xrc/xh_panel.h
wx/xrc/xh_propdlg.h
wx/xrc/xh_radbt.h
wx/xrc/xh_radbx.h
wx/xrc/xh_scrol.h
wx/xrc/xh_scwin.h
wx/xrc/xh_htmllbox.h
wx/xrc/xh_sizer.h
wx/xrc/xh_slidr.h
wx/xrc/xh_spin.h
wx/xrc/xh_split.h
wx/xrc/xh_statbar.h
wx/xrc/xh_stbmp.h
wx/xrc/xh_stbox.h
wx/xrc/xh_stlin.h
wx/xrc/xh_sttxt.h
wx/xrc/xh_text.h
wx/xrc/xh_tglbtn.h
wx/xrc/xh_toolb.h
wx/xrc/xh_tree.h
wx/xrc/xh_treebk.h
wx/xrc/xh_unkwn.h
wx/xrc/xh_wizrd.h
wx/xrc/xmlres.h
wx/aui/framemanager.h
wx/aui/dockart.h
wx/aui/floatpane.h
wx/aui/auibook.h
wx/aui/tabmdi.h
wx/aui/auibar.h
wx/aui/aui.h
wx/richtext/richtextctrl.h
wx/richtext/richtextbuffer.h
wx/richtext/richtexthtml.h
wx/richtext/richtextstyles.h
wx/richtext/richtextxml.h
wx/richtext/richtextformatdlg.h
wx/richtext/richtextsymboldlg.h
wx/richtext/richtextstyledlg.h
wx/richtext/richtextprint.h
"
HEADERS2_INSTALL="
wx/setup.h
wx/msw/rcdefs.h
"
HEADERS_DIRS="aui generic html meta msw/ole msw persist propgrid protocol richtext stc xml xrc"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

# wxwidgets' configrue script does not honour CXXLIBS,
# so specify them explicitly when calling make
MAKE_XTRA="CXXLIBS=$CXXLIBS"

conf()
{
   conf_pre;
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC=$CC \
     CXX=$CXX \
     F77=$F77 \
     CPP=$CPP \
     AR=$AR \
     RANLIB=$RANLIB \
     RC=$RC \
     STRIP=$STRIP \
     LD=$LD \
     WINDRES="windres --preprocessor=$CPP" \
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CPPFLAGS="$CPPFLAGS" \
     LDFLAGS="${LDFLAGS} -Wl,--allow-multiple-definition" \
     CXXLIBS="${CXXLIBS}" \
     --prefix=${PREFIX} \
     --enable-monolithic \
     --enable-shared \
     --enable-unicode
   )
   touch ${BUILDDIR}/have_configure
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/wxmsw28u_gcc_custom.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/libwx_mswu-2.8.dll.a ${LIBRARY_PATH}
   # ${CP} ${CP_FLAGS} ${BUILDDIR}/libglob.a ${STATICLIB_PATH}
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_DIRS; do
      mkdir -vp ${INCLUDE_PATH}/wx/$a
   done
   
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/include/$a ${INCLUDE_PATH}/$a
   done
   
   for a in $HEADERS2_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/wx/include/msw-unicode-release-2.8/$a ${INCLUDE_PATH}/`basename $a`
   done
   
   mkdir ${LIBRARY_PATH}/wx
   mkdir ${LIBRARY_PATH}/wx/config
   ${CP} ${CP_FLAGS} ${BUILDDIR}/lib/wx/config/msw-unicode-release-2.8 ${LIBRARY_PATH}/wx/config
   
   # Install various tools
   ${CP} ${CP_FLAGS} ${BUILDDIR}/wx-config ${BINARY_PATH}
   #${CP} ${CP_FLAGS} ${BUILDDIR}/utils/wxrc.exe ${BINARY_PATH}
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/licence.txt ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/gpl.txt ${LICENSE_PATH}/${PKG}
   ${CP} ${CP_FLAGS} ${SRCDIR}/docs/lgpl.txt ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/wxmsw280u_gcc_custom.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libwx_mswu-2.8.dll.a
   #${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libglob.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/`basename $a`
   done
   
   for a in $HEADERS_DIRS; do
      rmdir --ignore-fail-if-non-empty ${INCLUDE_PATH}/wx/$a
   done
   
   ${RM} ${RM_FLAGS} ${BUILDDIR}/lib/wx/config/msw-unicode-release-2.9 ${LIBRARY_PATH}/wx/config
   rmdir --ignore-fail-if-non-empty ${LIBRARY_PATH}/wx/config
   rmdir --ignore-fail-if-non-empty ${LIBRARY_PATH}/wx
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # uninstall tools
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/wx-config
   #${RM} ${RM_FLAGS} ${BINARY_PATH}/wxrc.exe
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/licence.txt
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/gpl.txt
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/lgpl.txt
   
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
