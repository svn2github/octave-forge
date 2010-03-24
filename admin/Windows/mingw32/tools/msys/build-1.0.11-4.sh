#! /usr/bin/sh

# This script downloads and extracts MSYS 1.0.11

# Name of the package we're building
PKG=msys
# Version of the package
VER=1.0.11
# Release No
REL=4

TOPDIR=`pwd`

# --- load common functions ---
source ../../gcc44_common.sh
source ../../gcc44_pkg_version.sh

# Download URLs
HTTP_ROOT="http://downloads.sourceforge.net/mingw"

URLS_MSYS="
${HTTP_ROOT}/msysCORE-1.0.11-bin.tar.gz"

#URLS_MSYSADD="
#${HTTP_ROOT}/sed-4.2.1-1-msys-1.0.11-bin.tar.lzma
#${HTTP_ROOT}/tar-1.22-1-msys-1.0.11-bin.tar.lzma"

URL="${URLS_MSYS} ${URLS_MSYSADD}"

# Directory to unpack msys to
DIR_MSYS=msys

CP=cp

install_msys() {
(
   # target directory in package tree
   TDIR=${PACKAGE_ROOT}/${DIR_MSYS}
   # create it if necessary
   mkdir -pv $TDIR
   
   cd $TDIR
   
   # extract files
   for a in ${URL}; do 
      echo bsdtar x -f "$TOPDIR/`basename $a`"
      bsdtar x -f "$TOPDIR/`basename $a`"
   done
   
   # delete the locales
   rm -rf $TDIR/share/lcoale
   
   # move .ico file because windows gets confused when you have also installed matlab
   mv ${TDIR}/m.ico ${TDIR}/the-m.ico
   
   # modify startup script to use smaller font
   sed -i -e "s/Courier-12/\"Lucida Console-10\"/" "${TDIR}/msys.bat" 
)
}

install_pkg() {
   install_msys
}

mkdirs() { echo $0: mkdirs not required; }
applypatch() { echo $0: applypatch not required; }
conf() { echo $0: conf not required; }
build() { echo $0: build not required; }
install() { echo $0: install not required; }

# do whatever the user specified...
$*