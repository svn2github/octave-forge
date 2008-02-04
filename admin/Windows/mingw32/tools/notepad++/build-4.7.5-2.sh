#! /usr/bin/sh

# Name of package
PKG=npp
# Version of Package
VER=4.7.5
# Release of (this patched) package
REL=2
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKG}.${VER}.src.zip
SRCBINFILE=${PKG}.${VER}.bin.zip
TAR_TYPE=j
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="http://downloads.sourceforge.net/notepad-plus/npp.4.7.5.src.zip http://downloads.sourceforge.net/notepad-plus/npp.4.7.5.bin.zip"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig
# Make file to use
MAKEFILE="makefile"

# Additional DIFF Flags for generating diff file
#DIFF_FLAGS="-x *.def"

# header files to be installed
INSTALL_HEADERS=""

# --- load common functions ---
source ../../gcc42_common.sh
source ../../gcc42_pkg_version.sh

# Directory the lib is built in
BUILDDIR_SCINTILLA=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}/scintilla/win32"
BUILDDIR_NPP=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}/PowerEditor/gcc"

TARGET_PATH=${PACKAGE_ROOT}/tools/notepad++

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

build_pre()
{
   GCC=${CC}
   export GCC
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
   #build_npp;
}

unpack() 
{
   unpack_pre
   ( mkdir -p ${SRCDIR} && cd ${SRCDIR} && ${TOPDIR}/${BSDTAR} xvf ${TOPDIR}/${SRCFILE} );
   ( mkdir -p ${SRCDIR}/npp-bin && cd ${SRCDIR}/npp-bin && ${TOPDIR}/${BSDTAR} xvf ${TOPDIR}/${SRCBINFILE} );
   unpack_post
}

remove_comic_font()
{
   ${SED} -e 's/fontName=\"Comic Sans MS\"\(.*\)fontSize=\"[0-9]*\"/fontName=\"\"\1fontSize=\"\"/' -e 's/\(<WidgetStyle name=\"Default Style\".*\)fontName=\"[^\"]*\"\(.*\)fontSize=\"[0-9]*\"/\1fontName=\"Lucida Console\"\2fontSize=\"9\"/' ${SRCDIR}/npp-bin/stylers.model.xml > ${TARGET_PATH}/stylers.model.xml
}

install_pre() { mkdir -p ${TARGET_PATH}; }

install_scilexerdll()
{
   ${CP} ${CP_FLAGS} ${BUILDDIR_SCINTILLA}/../bin/SciLexer.dll ${TARGET_PATH}
}

XML_FILES="config.model.xml contextMenu.xml langs.model.xml shortcuts.xml stylers.model.xml toolbarIcons.xml userDefineLang.xml"

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
   # install_libgcc;
   
   install_post
}

install_with_built_npp()
{
   install_pre

   ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/bin/notepad++.exe ${TARGET_PATH}
   strip ${STRIP_FLAGS} ${TARGET_PATH}/notepad++.exe
   ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/src/font/LineDraw.ttf ${TARGET_PATH}
   ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/bin/change.log ${TARGET_PATH}
   
   for a in ${XML_FILES}; do ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/src/$a ${TARGET_PATH}; done;

   ${CP} ${CP_FLAGS} ${SRCDIR}/PowerEditor/license.txt ${TARGET_PATH}
   remove_comic_font
   install_scilexerdll;
   install_libgcc;
   touch ${TARGET_PATH}/doLocalConf.xml
   
   mkdir -p ${TARGET_PATH}/plugins
   ${CP} ${CP_FLAGS} -R ${SRCDIR}/npp-bin/plugins ${TARGET_PATH}/plugins/
   install_post;
}

install_libgcc()
{
   MINGW_BIN=`which ${CC} | sed -e "s%\(.*\)/[^/]*%\1%"`
   GS=`echo ${GCC_SYS} | sed -e s%-%%`
   ${CP} ${CP_FLAGS} ${MINGW_BIN}/libgcc_${GS}_1.dll ${TARGET_PATH}
   ${CP} ${CP_FLAGS} ${MINGW_BIN}/libstdc++_${GS}_6.dll ${TARGET_PATH}
}

install() { echo $0: install not required; }

uninstall()
{
   ${RM} ${RM_FLAGS} ${TARGET_PATH}
}

install_pkg()
{
   install_with_npp_bin
   #install_with_built_npp
}
   
all() 
{
   download
   unpack
   applypatch
   mkdirs
   conf
   build
   install_pkg
}

main $*
