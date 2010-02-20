#! /usr/bin/sh

# Name of package
PKG=npp
# Version of Package
VER=5.6.6
# Release of (this patched) package
REL=4
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKG}.${VER}.src.7z
SRCBINFILE=${PKG}.${VER}.bin.7z
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="
http://downloads.sourceforge.net/notepad-plus/npp.5.6.6.bin.7z
http://downloads.sourceforge.net/notepad-plus/npp.5.6.6.src.7z"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${PKGVER}-orig

# Make file to use (optional)
MAKEFILE="makefile"
# Any extra flags to pass make to
MAKE_XTRA=

# subdirectory to install heraders to (empty for default)
INCLUDE_DIR=

# Header files to install
HEADERS_INSTALL=

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x *.svn -x *.hg -x *.rej"

# load common functions
source ../../gcc44_common.sh
source ../../gcc44_pkg_version.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR_SCINTILLA=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}/scintilla/win32"
BUILDDIR_NPP=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}/PowerEditor/gcc"

BUILDDIRS="${BUILDDIR_SCINTILLA} ${BUILDDIR_NPP}"

TARGET_PATH_ANSI="${PACKAGE_ROOT}/tools/notepad++/ansi"
TARGET_PATH_UNICODE="${PACKAGE_ROOT}/tools/notepad++"

# == override resp. specify build actions ==

LDFLAGS+=" -Wl,--allow-multiple-definition"

mkdirs_pre()
{
   for a in $BUILDDIRS; do
      if [ -e $a ]; then
         rm -rf $a
      fi
   done
}

mkdirs()
{
   mkdirs_pre;
   mkdir -vp ${BUILDDIR_SCINTILLA}
   mkdir -vp ${BUILDDIR_SCINTILLA}/../bin
   mkdir -vp ${BUILDDIR_SCINTILLA}/../lib
   mkdir -vp ${BUILDDIR_NPP}
   mkdir -vp ${BUILDDIR_NPP}/../bin
   mkdirs_post;
}

conf()
{
   conf_pre;
   sed -e "s%@SRCDIR@%${TOPDIR}/${SRCDIR}/scintilla%g" ${SRCDIR}/scintilla/win32/${MAKEFILE} > ${BUILDDIR_SCINTILLA}/${MAKEFILE}
   touch ${BUILDDIR_SCINTILLA}/deps.mak
   rm -f ${BUILDDIR_SCINTILLA}/deps
   sed -e "s%@SRCDIR@%${TOPDIR}/${SRCDIR}/PowerEditor%g" ${SRCDIR}/PowerEditor/gcc/${MAKEFILE} > ${BUILDDIR_NPP}/${MAKEFILE}
   conf_post;
}

clean_scintilla()
{
   BUILDDIR=${BUILDDIR_SCINTILLA}
   ( cd ${BUILDDIR} && make_common clean )
}

clean_npp()
{
   BUILDDIR=${BUILDDIR_NPP}
   ( cd ${BUILDDIR} && make_common clean )
}

clean()
{
   clean_pre;
   
   clean_scintilla;
   clean_npp;
   
   clean_post;
}

build_scintilla()
{
   echo Building SCINTILLA...
   build_pre;
   BUILDDIR=${BUILDDIR_SCINTILLA}
   ( cd ${BUILDDIR} && make_common )
}

build_npp()
{
   echo Building NPP...
   build_pre;
   BUILDDIR=${BUILDDIR_NPP}
   ( cd ${BUILDDIR} && make_common )
}

build()
{
   build_scintilla;
   build_npp;
}

unpack() 
{
   unpack_pre
   ( mkdir -p ${SRCDIR} && cd ${SRCDIR} && 7za x ${TOPDIR}/${SRCFILE} );
   ( mkdir -p ${SRCDIR}/npp-bin && cd ${SRCDIR}/npp-bin && 7za x ${TOPDIR}/${SRCBINFILE} );
   unpack_post
}

unpack_orig() 
{
   unpack_orig_pre
   ( mkdir -p ${SRCDIR_ORIG} && cd ${SRCDIR_ORIG} && 7za x ${TOPDIR}/${SRCFILE} );
   ( mkdir -p ${SRCDIR_ORIG}/npp-bin && cd ${SRCDIR_ORIG}/npp-bin && 7za x ${TOPDIR}/${SRCBINFILE} );
   unpack_orig_post
}

remove_comic_font()
{
   ${SED} -e 's/fontName=\"Comic Sans MS\"\(.*\)fontSize=\"[0-9]*\"/fontName=\"\"\1fontSize=\"\"/' \
          -e 's/\(<WidgetStyle name=\"Default Style\".*\)fontName=\"[^\"]*\"\(.*\)fontSize=\"[0-9]*\"/\1fontName=\"ProggyOpti\"\2fontSize=\"8\"/' \
          ${SRCDIR}/npp-bin/stylers.model.xml > ${TARGET_PATH}/stylers.model.xml
}

install_pre()
{ 
  mkdir -vp ${TARGET_PATH_ANSI}; 
  mkdir -vp ${TARGET_PATH_UNICODE}; 
}

install_scilexerdll()
{
   cp ${CP_FLAGS} ${BUILDDIR_SCINTILLA}/../bin/SciLexer.dll ${TARGET_PATH}
   strip ${STRIP_FLAGS} ${TARGET_PATH}/SciLexer.dll
}

XML_FILES="
config.model.xml 
contextMenu.xml 
langs.model.xml 
shortcuts.xml 
stylers.model.xml 
toolbarIcons.xml 
userDefineLang.xml"

install_libgcc()
{
   cp -av /mingw/bin/libgcc_s_dw2-1.dll $TARGET_PATH
   cp -av /mingw/bin/libstdc++-6.dll $TARGET_PATH
}

install_with_built_npp_ansi()
{
   install_pre
   
   TARGET_PATH=$TARGET_PATH_ANSI

   cp ${CP_FLAGS} ${BUILDDIR_NPP}/../bin/notepad++.exe ${TARGET_PATH}
   strip ${STRIP_FLAGS} ${TARGET_PATH}/notepad++.exe
   
   cp ${CP_FLAGS} ${SRCDIR}/PowerEditor/bin/change.log ${TARGET_PATH}
   
   for a in ${XML_FILES}; do 
      cp ${CP_FLAGS} ${SRCDIR}/PowerEditor/src/$a ${TARGET_PATH}; 
   done;

   cp ${CP_FLAGS} ${SRCDIR}/PowerEditor/license.txt ${TARGET_PATH}
   cp ${CP_FLAGS} ${SRCDIR}/PowerEditor/bin/readme.txt ${TARGET_PATH}
   
   # remove_comic_font
   
   install_scilexerdll;
   
   # install_libgcc;
   
   # touch ${TARGET_PATH}/doLocalConf.xml
   
   mkdir -p ${TARGET_PATH}/plugins
   cp ${CP_FLAGS} -R ${SRCDIR}/npp-bin/ansi/plugins ${TARGET_PATH}/
   
   install_fonts;
   install_plugins_ansi;
   
   install_post;
}

install_with_built_npp_unicode()
{
   install_pre

   TARGET_PATH=$TARGET_PATH_UNICODE

   cp ${CP_FLAGS} ${BUILDDIR_NPP}/../bin/notepad++U.exe ${TARGET_PATH}/notepad++.exe
   strip ${STRIP_FLAGS} ${TARGET_PATH}/notepad++.exe
   
   cp ${CP_FLAGS} ${SRCDIR}/PowerEditor/bin/change.log ${TARGET_PATH}
   
   for a in ${XML_FILES}; do 
      cp ${CP_FLAGS} ${SRCDIR}/PowerEditor/src/$a ${TARGET_PATH}; 
   done;
   
   mkdir -vp ${TARGET_PATH}/localization
   cp ${CP_FLAGS} ${SRCDIR}/PowerEditor/installer/nativeLang/english.xml ${TARGET_PATH}/localization

   cp ${CP_FLAGS} ${SRCDIR}/PowerEditor/license.txt ${TARGET_PATH}
   cp ${CP_FLAGS} ${SRCDIR}/PowerEditor/bin/readme.txt ${TARGET_PATH}
   
   # remove_comic_font
   
   install_scilexerdll;
   
   # install_libgcc;
   
   # touch ${TARGET_PATH}/doLocalConf.xml
   
   mkdir -p ${TARGET_PATH}/plugins
   cp ${CP_FLAGS} -R ${SRCDIR}/npp-bin/unicode/plugins ${TARGET_PATH}/
   
   install_fonts;
   install_plugins_unicode;
   
   install_post;
}

FONTS="Opti"
FONTS_URL="http://www.proggyfonts.com/download/download_bridge.php?get=Opti.zip"

download_fonts()
{
  download_core "$FONTS_URL"
}

install_fonts()
{
  ( cd ${TARGET_PATH} && for a in ${FONTS}; do bsdtar xv -f ${TOPDIR}/$a.zip; done )
}

PLUGINS_ANSI="
WindowManager_1_1_2_dll
HexEditor_0_9_5_ANSI_dll
NppExec_0331_dll_ANSI
"
PLUGINS_ANSI_URL="
http://downloads.sourceforge.net/npp-plugins/WindowManager_1_1_2_dll.zip
http://downloads.sourceforge.net/npp-plugins/HexEditor_0_9_5_dll_ANSI.zip
http://downloads.sourceforge.net/npp-plugins/NppExec_0331_dll_ANSI.zip
"

PLUGINS_UNICODE="
WindowManager_1_2_2_UNI_dll
HexEditor_0_9_5_UNI_dll
Explorer_1_8_2_UNI_dll
fallingbricks_v1.1_unicode_dll
FunctionList_2_0_091109_UNI_dll
NppExec_0331_dll_Unicode"
PLUGINS_UNICODE_URL="
http://downloads.sourceforge.net/npp-plugins/WindowManager_1_2_2_UNI_dll.zip
http://downloads.sourceforge.net/npp-plugins/HexEditor_0_9_5_UNI_dll.zip
http://downloads.sourceforge.net/npp-plugins/Explorer_1_8_2_UNI_dll.zip
http://downloads.sourceforge.net/npp-plugins/fallingbricks_v1.1_unicode_dll.zip
http://downloads.sourceforge.net/npp-plugins/FunctionList_2_0_091109_UNI_dll.zip
http://downloads.sourceforge.net/npp-plugins/NppExec_0331_dll_Unicode.zip
"

install_plugins()
{
   ( cd ${TARGET_PATH}/plugins && for a in $1; do bsdtar xv -f ${TOPDIR}/$a.zip; done )
}

install_plugins_ansi() { install_plugins "${PLUGINS_ANSI}"; }
install_plugins_unicode() { install_plugins "${PLUGINS_UNICODE}"; }

download_plugins_ansi() { download_core "${PLUGINS_ANSI_URL}" ;}
download_plugins_unicode() { download_core "${PLUGINS_UNICODE_URL}" ; }

install() { echo $0: install not required; }

uninstall()
{
   ${RM} ${RM_FLAGS} ${TARGET_PATH}
}

install_pkg()
{
   #install_with_npp_bin
   #install_with_built_npp_ansi;
   install_with_built_npp_unicode;
}

download()
{
   download_core "${URL}"
   download_plugins_unicode
   download_fonts
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
