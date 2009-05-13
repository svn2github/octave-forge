#! /usr/bin/sh

# Name of package
PKG=npp
# Version of Package
VER=5.3.1
# Release of (this patched) package
REL=3
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKG}.${VER}.src.zip
SRCBINFILE=${PKG}.${VER}.bin.zip
TAR_TYPE=j
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="
http://prdownloads.sourceforge.net/notepad-plus/npp.5.3.1.bin.zip
http://prdownloads.sourceforge.net/notepad-plus/npp.5.3.1.src.zip"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig
# Make file to use
MAKEFILE="makefile"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x *.svn -x *.hg -x *.rej -x *~"

# header files to be installed
INSTALL_HEADERS=""

# --- load common functions ---
source ../../gcc43_common.sh
source ../../gcc43_pkg_version.sh

# Directory the lib is built in
BUILDDIR_SCINTILLA=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}/scintilla/win32"
BUILDDIR_NPP=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}/PowerEditor/gcc"

TARGET_PATH_ANSI="${PACKAGE_ROOT}/tools/notepad++/ansi"
#TARGET_PATH_UNICODE="${PACKAGE_ROOT}/tools/notepad++/unicode"
TARGET_PATH_UNICODE="${PACKAGE_ROOT}/tools/notepad++"
#TARGET_PATH=${PACKAGE_ROOT}/tools/notepad++

BSDTAR=bsdtar
CP=cp

mkdirs_pre()
{ 
   if [ -e ${BUILDDIR_SCINTILLA} ]; then rm -rf ${BUILDDIR_SCINTILLA}; fi;
   if [ -e ${BUILDDIR_NPP} ]; then rm -rf ${BUILDDIR_NPP}; fi;
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
   sed -e "s%@SRCDIR@%${TOPDIR}/${SRCDIR}/scintilla%g" ${SRCDIR}/scintilla/win32/${MAKEFILE} > ${BUILDDIR_SCINTILLA}/${MAKEFILE}
   touch ${BUILDDIR_SCINTILLA}/deps.mak
   rm -f ${BUILDDIR_SCINTILLA}/deps
   sed -e "s%@SRCDIR@%${TOPDIR}/${SRCDIR}/PowerEditor%g" ${SRCDIR}/PowerEditor/gcc/${MAKEFILE} > ${BUILDDIR_NPP}/${MAKEFILE}
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
   clean_pre
   
   clean_scintilla
   clean_npp
   
   clean_post
}

make_common()
{
   make ${MAKE_FLAGS} -f $MAKEFILE GCC_OPT_FLAGS="$GCC_OPT_FLAGS" GCC_ARCH_FLAGS="$GCC_ARCH_FLAGS"
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
   ( mkdir -p ${SRCDIR} && cd ${SRCDIR} && ${TOPDIR}/${BSDTAR} xvf ${TOPDIR}/${SRCFILE} );
   ( mkdir -p ${SRCDIR}/npp-bin && cd ${SRCDIR}/npp-bin && ${TOPDIR}/${BSDTAR} xvf ${TOPDIR}/${SRCBINFILE} );
   unpack_post
}

unpack_orig() 
{
   unpack_orig_pre
   ( mkdir -p ${SRCDIR_ORIG} && cd ${SRCDIR_ORIG} && ${TOPDIR}/${BSDTAR} xvf ${TOPDIR}/${SRCFILE} );
   ( mkdir -p ${SRCDIR_ORIG}/npp-bin && cd ${SRCDIR_ORIG}/npp-bin && ${TOPDIR}/${BSDTAR} xvf ${TOPDIR}/${SRCBINFILE} );
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
  #mkdir -vp ${TARGET_PATH_ANSI}; 
  mkdir -vp ${TARGET_PATH_UNICODE}; 
}

install_scilexerdll()
{
   ${CP} ${CP_FLAGS} ${BUILDDIR_SCINTILLA}/../bin/SciLexer.dll ${TARGET_PATH}
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

install_with_npp_bin()
{
   install_pre

   # copy bin dist of npp
   ${CP} ${CP_FLAGS} -r ${SRCDIR}/npp-bin/* ${TARGET_PATH}
   # copy xml files from source tree
   for a in ${XML_FILES}; do ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/src/$a ${TARGET_PATH}; done;
   # install build scilexer dll
   install_scilexerdll;
   # remove Comic Sans MS font from stylers
   remove_comic_font;
   # install gcc runtime dll
   install_libgcc;
   
   install_post
}

install_with_built_npp_ansi()
{
   install_pre
   
   TARGET_PATH=$TARGET_PATH_ANSI

   ${CP} ${CP_FLAGS} ${BUILDDIR_NPP}/../bin/notepad++.exe ${TARGET_PATH}
   strip ${STRIP_FLAGS} ${TARGET_PATH}/notepad++.exe
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/src/font/LineDraw.ttf ${TARGET_PATH}
   ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/bin/change.log ${TARGET_PATH}
   
   for a in ${XML_FILES}; do 
      ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/src/$a ${TARGET_PATH}; 
   done;

   ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/license.txt ${TARGET_PATH}
   ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/bin/readme.txt ${TARGET_PATH}
   
   # remove_comic_font
   
   install_scilexerdll;
   
   # install_libgcc;
   
   # touch ${TARGET_PATH}/doLocalConf.xml
   
   mkdir -p ${TARGET_PATH}/plugins
   ${CP} ${CP_FLAGS} -R ${SRCDIR}/npp-bin/ansi/plugins ${TARGET_PATH}/
   
   install_fonts;
   install_plugins_ansi;
   
   install_post;
}

install_with_built_npp_unicode()
{
   install_pre

   TARGET_PATH=$TARGET_PATH_UNICODE

   ${CP} ${CP_FLAGS} ${BUILDDIR_NPP}/../bin/notepad++U.exe ${TARGET_PATH}/notepad++.exe
   strip ${STRIP_FLAGS} ${TARGET_PATH}/notepad++.exe
   
   ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/src/font/LineDraw.ttf ${TARGET_PATH}
   ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/bin/change.log ${TARGET_PATH}
   
   for a in ${XML_FILES}; do 
      ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/src/$a ${TARGET_PATH}; 
   done;
   
   mkdir -vp ${TARGET_PATH}/localization
   ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/installer/localization/* ${TARGET_PATH}/localization

   ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/license.txt ${TARGET_PATH}
   ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/bin/readme.txt ${TARGET_PATH}
   
   # remove_comic_font
   
   install_scilexerdll;
   
   # install_libgcc;
   
   # touch ${TARGET_PATH}/doLocalConf.xml
   
   mkdir -p ${TARGET_PATH}/plugins
   ${CP} ${CP_FLAGS} -R ${SRCDIR}/npp-bin/unicode/plugins ${TARGET_PATH}/
   
   install_fonts;
   install_plugins_unicode;
   
   install_post;
}

FONTS="Opti"
FONTS_URL="http://www.proggyfonts.com/download/download_bridge.php?get=Opti.zip"

#FONTS="Opti OptiSmall ProggyCleanSZ ProggySquareSZ ProggyTinySZ ProggySmall"
#FONTS_URL="http://www.proggyfonts.com/download/download_bridge.php?get=Opti.zip http://www.proggyfonts.com/download/download_bridge.php?get=OptiSmall.zip http://www.proggyfonts.com/download/download_bridge.php?get=ProggyCleanSZ.zip http://www.proggyfonts.com/download/download_bridge.php?get=ProggySquareSZ.zip http://www.proggyfonts.com/download/download_bridge.php?get=ProggyTinySZ.zip http://www.proggyfonts.com/download/download_bridge.php?get=ProggySmall.zip"

download_fonts() { download_core $FONTS_URL ; }

install_fonts()
{
  ( cd ${TARGET_PATH} && for a in ${FONTS}; do ${TOPDIR}/${BSDTAR} x -f ${TOPDIR}/$a.zip; done )
}

PLUGINS_ANSI="
WindowManager_1_1_2_dll
HexEditor_0_9_3_dll_ANSI"
PLUGINS_ANSI_URL="
http://downloads.sourceforge.net/npp-plugins/WindowManager_1_1_2_dll.zip
http://downloads.sourceforge.net/npp-plugins/HexEditor_0_9_3_dll_ANSI.zip"

PLUGINS_UNICODE="
WindowManager_1_2_1_dll
HexEditor_0_9_3_dll_UNI
Explorer_1_8_1_dll
fallingbricks_v1.1_unicode_dll"
PLUGINS_UNICODE_URL="
http://downloads.sourceforge.net/npp-plugins/WindowManager_1_2_1_dll.zip
http://downloads.sourceforge.net/npp-plugins/HexEditor_0_9_3_dll_UNI.zip
http://downloads.sourceforge.net/npp-plugins/Explorer_1_8_1_dll.zip
http://downloads.sourceforge.net/npp-plugins/fallingbricks_v1.1_unicode_dll.zip"

install_plugins()
{
   ( cd ${TARGET_PATH}/plugins && for a in $1; do ${TOPDIR}/${BSDTAR} xv -f ${TOPDIR}/$a.zip; done )
}

install_plugins_ansi() { install_plugins "${PLUGINS_ANSI}"; }
install_plugins_unicode() { install_plugins "${PLUGINS_UNICODE}"; }

download_plugins_ansi() { download_core ${PLUGINS_ANSI_URL} ;}
download_plugins_unicode() { download_core ${PLUGINS_UNICODE_URL} ; }

#install_libgcc()
#{
#   MINGW_BIN=`which ${CC} | sed -e "s%\(.*\)/[^/]*%\1%"`
#   GS=`echo ${GCC_SYS} | sed -e s%-%%`
#   ${CP} ${CP_FLAGS} ${MINGW_BIN}/libgcc_${GS}_1.dll ${TARGET_PATH}
#   ${CP} ${CP_FLAGS} ${MINGW_BIN}/libstdc++_${GS}_6.dll ${TARGET_PATH}
#}

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

srcpkg()
{
   PI="";
   F="";
   for a in ${PLUGINS}; do PI="${PI} $a.zip"; done
   for a in ${FONTS}; do F="${F} $a.zip"; done
   
   "${SEVENZIP}" ${SEVENZIP_FLAGS} ${SRCPKG_PATH}/${PKG}-${VER}-${REL}-src.7z ${SRCFILE} ${SRCBINFILE} ${PATCHFILE} $PI $F build-${VER}-${REL}.sh
}

download() {
  ( download_core ${URL} )
  ( download_fonts )
  ( download_plugins_ansi )
  ( download_plugins_unicode )
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
