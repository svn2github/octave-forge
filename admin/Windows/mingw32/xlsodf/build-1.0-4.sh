#! /usr/bin/sh

# Name of package
PKG=xlsodf
# Version of Package
VER=1.0
# Release of (this patched) package
REL=4
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL_ODF="
http://www.jopendocument.org/download/jOpenDocument-1.2b2.jar
http://www.gnu.org/licenses/gpl.txt
http://mirror.deri.at/apache/xerces/j/Xerces-J-bin.2.9.1.tar.gz
http://odftoolkit.org/projects/odfdom/downloads/download/previous-versions%252Freleases%252Fodfdom-0.7.5-binary.zip
"
URL_XLS="
http://mirror.deri.at/apache/poi/release/bin/poi-bin-3.6-20091214.tar.gz
http://downloads.sourceforge.net/dom4j/dom4j-1.6.1.tar.gz
http://downloads.sourceforge.net/jexcelapi/jexcelapi_2_6_10.tar.gz
http://www.gnu.org/licenses/lgpl-3.0.txt
http://mirror.deri.at/apache/xmlbeans/binaries/xmlbeans-2.5.0.zip
"
URL="$URL_ODF $URL_XLS"

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
INCLUDE_DIR=

# Herader files to install
HEADERS_INSTALL=""

# pkg-config .pc files to install
PKG_CONFIG_INSTALL=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# Distibuted binary files to eb installed
DIST_FILES="
jexcelapi/jxl.jar
odfdom-0.7.5/odfdom.jar
dom4j-1.6.1/dom4j-1.6.1.jar
jOpenDocument-1.2b2.jar
xerces-2_9_1/xercesImpl.jar
poi-3.6/poi-3.6-20091214.jar
poi-3.6/poi-ooxml-3.6-20091214.jar
poi-3.6/poi-ooxml-schemas-3.6-20091214.jar
xmlbeans-2.5.0/lib/xbean.jar
"

# == override resp. specify build actions ==

unpack()
{
   unpack_core Xerces-J-bin.2.9.1.tar.gz
   unpack_core dom4j-1.6.1.tar.gz
   ( mkdir odfdom-0.7.5 && cd odfdom-0.7.5 && unpack_core ../odfdom-0.7.5-binary.zip )
   unpack_core poi-bin-3.6-20091214.tar.gz
   unpack_core jexcelapi_2_6_10.tar.gz
   unpack_core xmlbeans-2.5.0.zip
}

conf()
{
   echo This package is not configured...
}

mkdirs()
{
   echo This package is not configured...
}

build()
{
   echo This package is not built...
}

install()
{
   install_pre;
   
   # Install Jar files
   for a in $DIST_FILES; do
      ${CP} ./$a ${BINARY_PATH};
   done
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${SRCDIR}/$a ${INCLUDE_PATH}/`basename $a`
   done
   
   # Install license files
   mkdir -p ${LICENSE_PATH}/${PKG}/odfdom
   $CP $CP_FLAGS odfdom-0.7.5/LICENSE.txt ${LICENSE_PATH}/${PKG}/odfdom
   
   mkdir -p ${LICENSE_PATH}/${PKG}/jexcelapi
   $CP $CP_FLAGS lgpl-3.0.txt ${LICENSE_PATH}/${PKG}/jexcelapi
   
   mkdir -p ${LICENSE_PATH}/${PKG}/poi
   $CP $CP_FLAGS poi-3.6/LICENSE ${LICENSE_PATH}/${PKG}/poi
   $CP $CP_FLAGS poi-3.6/NOTICE ${LICENSE_PATH}/${PKG}/poi
   
   mkdir -p ${LICENSE_PATH}/${PKG}/xerces
   $CP $CP_FLAGS xerces-2_9_1/LICENSE ${LICENSE_PATH}/${PKG}/xerces
   $CP $CP_FLAGS xerces-2_9_1/NOTICE ${LICENSE_PATH}/${PKG}/xerces
   
   mkdir -p ${LICENSE_PATH}/${PKG}/xmlbeans
   $CP $CP_FLAGS xmlbeans-2.5.0/LICENSE.txt ${LICENSE_PATH}/${PKG}/xmlbeans
   $CP $CP_FLAGS xmlbeans-2.5.0/NOTICE.txt ${LICENSE_PATH}/${PKG}/xmlbeans
   
   mkdir -p ${LICENSE_PATH}/${PKG}/jOpenDocument
   $CP $CP_FLAGS gpl.txt ${LICENSE_PATH}/${PKG}/jOpenDocument
   
   mkdir -p ${LICENSE_PATH}/${PKG}/dom4j
   $CP $CP_FLAGS dom4j-1.6.1/LICENSE.txt ${LICENSE_PATH}/${PKG}/dom4j
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   for a in $DIST_FILES; do 
      ${RM} ${RM_FLAGS} ${BINARY_PATH}/`basename $a`
   done
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/`basename $a`
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # Uninstall license file
   $RM $RM_FLAGS ${LICENSE_PATH}/${PKG}/odfdom/LICENSE.txt
   rmdir --ignore-fail-on-non-empty ${LICENSE_PATH}/${PKG}/odfdom
   
   $RM $RM_FLAGS ${LICENSE_PATH}/${PKG}/jexcelapi/lgpl-3.0.txt
   rmdir --ignore-fail-on-non-empty ${LICENSE_PATH}/${PKG}/jexcelapi
   
   $RM $RM_FLAGS ${LICENSE_PATH}/${PKG}/poi/LICENSE
   $RM $RM_FLAGS ${LICENSE_PATH}/${PKG}/poi/NOTICE
   rmdir --ignore-fail-on-non-empty ${LICENSE_PATH}/${PKG}/poi
   
   $RM $RM_FLAGS ${LICENSE_PATH}/${PKG}/xerces/LICENSE
   $RM $RM_FLAGS ${LICENSE_PATH}/${PKG}/xerces/NOTICE
   rmdir --ignore-fail-on-non-empty ${LICENSE_PATH}/${PKG}/xerces
   
   $RM $RM_FLAGS ${LICENSE_PATH}/${PKG}/xmlbeans/LICENSE.txt
   $RM $RM_FLAGS ${LICENSE_PATH}/${PKG}/xmlbeans/NOTICE.txt
   rmdir --ignore-fail-on-non-empty ${LICENSE_PATH}/${PKG}/xmlbeans
   
   $RM $RM_FLAGS ${LICENSE_PATH}/${PKG}/jOpenDocument/gpl.txt
   rmdir --ignore-fail-on-non-empty ${LICENSE_PATH}/${PKG}/jOpenDocument
   
   $RM $RM_FLAGS ${LICENSE_PATH}/${PKG}/dom4j/LICENSE.txt
   rmdir --ignore-fail-on-non-empty ${LICENSE_PATH}/${PKG}/dom4j

   uninstall_post;
}

all() {
  download
  unpack
  install
}

main $*
