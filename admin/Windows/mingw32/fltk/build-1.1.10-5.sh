#! /usr/bin/sh

# Name of package
PKG=fltk
# Version of Package
VER=1.1.10
# Release of (this patched) package
REL=5
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}-source.tar.bz2
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://ftp.rz.tu-bs.de/pub/mirror/ftp.easysw.com/ftp/pub/fltk/$VER/fltk-$VER-source.tar.bz2"

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
fl/dirent.h
fl/Enumerations.H
fl/filename.H
fl/Fl.H
fl/Fl_Adjuster.H
fl/fl_ask.H
fl/Fl_Bitmap.H
fl/Fl_BMP_Image.H
fl/Fl_Box.H
fl/Fl_Browser.H
fl/Fl_Browser_.H
fl/Fl_Button.H
fl/Fl_Chart.H
fl/Fl_Check_Browser.H
fl/Fl_Check_Button.H
fl/Fl_Choice.H
fl/Fl_Clock.H
fl/Fl_Color_Chooser.H
fl/Fl_Counter.H
fl/Fl_Dial.H
fl/Fl_Double_Window.H
fl/fl_draw.H
fl/Fl_Export.H
fl/Fl_File_Browser.H
fl/Fl_File_Chooser.H
fl/Fl_File_Icon.H
fl/Fl_File_Input.H
fl/Fl_Fill_Dial.H
fl/Fl_Fill_Slider.H
fl/Fl_Float_Input.H
fl/Fl_FormsBitmap.H
fl/Fl_FormsPixmap.H
fl/Fl_Free.H
fl/Fl_GIF_Image.H
fl/Fl_Gl_Window.H
fl/Fl_Group.H
fl/Fl_Help_Dialog.H
fl/Fl_Help_View.H
fl/Fl_Hold_Browser.H
fl/Fl_Hor_Fill_Slider.H
fl/Fl_Hor_Nice_Slider.H
fl/Fl_Hor_Slider.H
fl/Fl_Hor_Value_Slider.H
fl/Fl_Image.H
fl/Fl_Input.H
fl/Fl_Input_.H
fl/Fl_Input_Choice.H
fl/Fl_Int_Input.H
fl/Fl_JPEG_Image.H
fl/Fl_Light_Button.H
fl/Fl_Line_Dial.H
fl/Fl_Menu.H
fl/Fl_Menu_.H
fl/Fl_Menu_Bar.H
fl/Fl_Menu_Button.H
fl/Fl_Menu_Item.H
fl/Fl_Menu_Window.H
fl/fl_message.H
fl/Fl_Multi_Browser.H
fl/Fl_Multi_Label.H
fl/Fl_Multiline_Input.H
fl/Fl_Multiline_Output.H
fl/Fl_Nice_Slider.H
fl/Fl_Object.H
fl/Fl_Output.H
fl/Fl_Overlay_Window.H
fl/Fl_Pack.H
fl/Fl_Pixmap.H
fl/Fl_PNG_Image.H
fl/Fl_PNM_Image.H
fl/Fl_Positioner.H
fl/Fl_Preferences.H
fl/Fl_Progress.H
fl/Fl_Radio_Button.H
fl/Fl_Radio_Light_Button.H
fl/Fl_Radio_Round_Button.H
fl/Fl_Repeat_Button.H
fl/Fl_Return_Button.H
fl/Fl_RGB_Image.H
fl/Fl_Roller.H
fl/Fl_Round_Button.H
fl/Fl_Round_Clock.H
fl/Fl_Scroll.H
fl/Fl_Scrollbar.H
fl/Fl_Secret_Input.H
fl/Fl_Select_Browser.H
fl/Fl_Shared_Image.H
fl/fl_show_colormap.H
fl/fl_show_input.H
fl/Fl_Simple_Counter.H
fl/Fl_Single_Window.H
fl/Fl_Slider.H
fl/Fl_Spinner.H
fl/Fl_Sys_Menu_Bar.H
fl/Fl_Tabs.H
fl/Fl_Text_Buffer.H
fl/Fl_Text_Display.H
fl/Fl_Text_Editor.H
fl/Fl_Tile.H
fl/Fl_Tiled_Image.H
fl/Fl_Timer.H
fl/Fl_Toggle_Button.H
fl/Fl_Toggle_Light_Button.H
fl/Fl_Toggle_Round_Button.H
fl/Fl_Tooltip.H
fl/Fl_Valuator.H
fl/Fl_Value_Input.H
fl/Fl_Value_Output.H
fl/Fl_Value_Slider.H
fl/Fl_Widget.H
fl/Fl_Window.H
fl/Fl_Wizard.H
fl/Fl_XBM_Image.H
fl/Fl_XPM_Image.H
fl/forms.H
fl/gl.h
fl/gl_draw.H
fl/gl2opengl.h
fl/glu.h
fl/glut.H
fl/mac.H
fl/math.h
fl/names.h
fl/win32.H
fl/x.H"
HEADERS_BUILD_INSTALL=

# install subdirectory below $PREFIX/$INC_DIR (if any)
INC_SUBDIR=FL

# License file(s) to install
LICENSE_INSTALL="COPYING"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc45_common.sh

# Directory the lib is built in (set this *after* loading gcc45_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

mkdirs_post()
{
   mkdir -vp ${BUILDDIR}/src
   mkdir -vp ${BUILDDIR}/lib
}

conf_pre()
{
    CONFIGURE_XTRA_ARGS="\
      --enable-shared \
      --enable-gl \
      --enable-threads \
      CFLAGS=-DFL_DLL \
      CXXFLAGS=-DFL_DLL"
}

conf_post()
{

   substvars ${SRCDIR}/src/makefile ${BUILDDIR}/src/makefile
   substvars ${SRCDIR}/makefile ${BUILDDIR}/makefile
   
   sed -e \
	"s@../FL@\$(SRCDIR)/FL@g" \
	${SRCDIR}/src/makedepend > ${BUILDDIR}/src/makedepend
   
   # Modify fltk-config
   sed \
	-e "/CFLAGS=/ s+-mwindows++g" \
	-e "/CFLAGS=/ s+-mno-cygwin++g" \
	-e "/CXXFLAGS=/ s+-mwindows++g" \
	-e "/CXXFLAGS=/ s+-mno-cygwin++g" \
	-e "/LDFLAGS=/ s+-mwindows++g" \
	-e "/LDFLAGS=/ s+-mno-cygwin++g" \
	${BUILDDIR}/fltk-config > ${BUILDDIR}/fltk-config.mod
   ${CP} ${CP_FLAGS} ${BUILDDIR}/fltk-config.mod ${BUILDDIR}/fltk-config

}

install()
{
   install_pre;
   
   # Install library, import library and static library
   for a in mgwfltknox_forms-1.1.dll mgwfltknox_gl-1.1.dll mgwfltknox_images-1.1.dll mgwfltknox-1.1.dll; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/src/$a $PREFIX/$BIN_DIR
   done

   for a in fltk fltk_forms fltk_gl fltk_images; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/src/lib$a.dll.a       $PREFIX/$LIB_DIR
   done

   ${CP} ${CP_FLAGS} ${BUILDDIR}/fltk-config $PREFIX/$BIN_DIR
   
   install_common;
   install_post;
}

install_strip()
{
   install
   for a in mgwfltknox_forms-1.1.dll mgwfltknox_gl-1.1.dll mgwfltknox_images-1.1.dll mgwfltknox-1.1.dll; do
      $STRIP $STRIP_FLAGS $PREFIX/$BIN_DIR/$a
   done
}

uninstall()
{
   uninstall_pre;
   
   for a in mgwfltknox_forms-1.1.dll mgwfltknox_gl-1.1.dll mgwfltknox_images-1.1.dll mgwfltknox-1.1.dll; do
      ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/$a
   done

   for a in fltk fltk_forms fltk_gl fltk_images; do
      ${RM} ${RM_FLAGS} $PREFIX/$LIB_DIR/lib$a.dll.a
   done

   ${RM} ${RM_FLAGS} $PREFIX/$BIN_DIR/fltk-config
   
   uninstall_common;
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
