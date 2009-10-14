#! /usr/bin/sh

# Name of package
PKG=fltk
# Version of Package
VER=1.1.9
# Release of (this patched) package
REL=4
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}-source.tar.bz2
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://ftp.rz.tu-bs.de/pub/mirror/ftp.easysw.com/ftp/pub/fltk/1.1.9/fltk-1.1.9-source.tar.bz2"

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
INCLUDE_DIR=include/FL

# Herader files to install
HEADERS_INSTALL="
dirent.h
Enumerations.H
filename.H
Fl.H
Fl_Adjuster.H
fl_ask.H
Fl_Bitmap.H
Fl_BMP_Image.H
Fl_Box.H
Fl_Browser.H
Fl_Browser_.H
Fl_Button.H
Fl_Chart.H
Fl_Check_Browser.H
Fl_Check_Button.H
Fl_Choice.H
Fl_Clock.H
Fl_Color_Chooser.H
Fl_Counter.H
Fl_Dial.H
Fl_Double_Window.H
fl_draw.H
Fl_Export.H
Fl_File_Browser.H
Fl_File_Chooser.H
Fl_File_Icon.H
Fl_File_Input.H
Fl_Fill_Dial.H
Fl_Fill_Slider.H
Fl_Float_Input.H
Fl_FormsBitmap.H
Fl_FormsPixmap.H
Fl_Free.H
Fl_GIF_Image.H
Fl_Gl_Window.H
Fl_Group.H
Fl_Help_Dialog.H
Fl_Help_View.H
Fl_Hold_Browser.H
Fl_Hor_Fill_Slider.H
Fl_Hor_Nice_Slider.H
Fl_Hor_Slider.H
Fl_Hor_Value_Slider.H
Fl_Image.H
Fl_Input.H
Fl_Input_.H
Fl_Input_Choice.H
Fl_Int_Input.H
Fl_JPEG_Image.H
Fl_Light_Button.H
Fl_Line_Dial.H
Fl_Menu.H
Fl_Menu_.H
Fl_Menu_Bar.H
Fl_Menu_Button.H
Fl_Menu_Item.H
Fl_Menu_Window.H
fl_message.H
Fl_Multi_Browser.H
Fl_Multi_Label.H
Fl_Multiline_Input.H
Fl_Multiline_Output.H
Fl_Nice_Slider.H
Fl_Object.H
Fl_Output.H
Fl_Overlay_Window.H
Fl_Pack.H
Fl_Pixmap.H
Fl_PNG_Image.H
Fl_PNM_Image.H
Fl_Positioner.H
Fl_Preferences.H
Fl_Progress.H
Fl_Radio_Button.H
Fl_Radio_Light_Button.H
Fl_Radio_Round_Button.H
Fl_Repeat_Button.H
Fl_Return_Button.H
Fl_RGB_Image.H
Fl_Roller.H
Fl_Round_Button.H
Fl_Round_Clock.H
Fl_Scroll.H
Fl_Scrollbar.H
Fl_Secret_Input.H
Fl_Select_Browser.H
Fl_Shared_Image.H
fl_show_colormap.H
fl_show_input.H
Fl_Simple_Counter.H
Fl_Single_Window.H
Fl_Slider.H
Fl_Spinner.H
Fl_Sys_Menu_Bar.H
Fl_Tabs.H
Fl_Text_Buffer.H
Fl_Text_Display.H
Fl_Text_Editor.H
Fl_Tile.H
Fl_Tiled_Image.H
Fl_Timer.H
Fl_Toggle_Button.H
Fl_Toggle_Light_Button.H
Fl_Toggle_Round_Button.H
Fl_Tooltip.H
Fl_Valuator.H
Fl_Value_Input.H
Fl_Value_Output.H
Fl_Value_Slider.H
Fl_Widget.H
Fl_Window.H
Fl_Wizard.H
Fl_XBM_Image.H
Fl_XPM_Image.H
forms.H
gl.h
gl_draw.H
gl2opengl.h
glu.h
glut.H
mac.H
math.h
names.h
win32.H
x.H"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==
MAKE_PARALLEL="-j6"

mkdirs_post()
{
   mkdir -vp ${BUILDDIR}/src
   mkdir -vp ${BUILDDIR}/lib
}

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
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall -DFL_DLL" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall -DFL_DLL" \
     CPPFLAGS="$CPPFLAGS" \
     LDFLAGS="${LDFLAGS}" \
     LIBS="${CXXLIBS}" \
     --prefix=${PREFIX} \
     --enable-shared \
     --enable-gl
   )
   touch ${BUILDDIR}/have_configure

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

   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/mgwfltknox_forms-1.1.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/mgwfltknox_gl-1.1.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/mgwfltknox_images-1.1.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/mgwfltknox-1.1.dll ${SHAREDLIB_PATH}

   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/libfltk.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/libfltk_forms.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/libfltk_gl.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/src/libfltk_images.dll.a ${LIBRARY_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/fltk-config ${BINARY_PATH}
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/FL/$a ${INCLUDE_PATH}/`basename $a`
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/mgwfltknox_forms-1.1.dll
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/mgwfltknox_gl-1.1.dll
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/mgwfltknox_images-1.1.dll
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/mgwfltknox-1.1.dll
   
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfltk.dll.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfltk_forms.dll.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfltk_gl.dll.a
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libfltk_images.dll.a
   
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/fltk-config
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/`basename $a`
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   
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
