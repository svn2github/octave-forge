#! /usr/bin/sh


# This script downloads and extracts MSYS 1.0.11

# Name of the package we're building
PKG=msys
# Version of the package
VER=1.0.11
# Release No
REL=3
# URL to source code

TOPDIR=`pwd`

DIR_MSYS=MSYS

# --- load common functions ---
source ../../gcc43_common.sh
source ../../gcc43_pkg_version.sh

CP=cp

# Download URLs
HTTP_ROOT="http://downloads.sourceforge.net/mingw"


URLS_MSYS="\
msysCORE-1.0.11-20080826.tar.gz"

download_core()
{
  ( for a in $1; do ${WGET} ${WGET_FLAGS} "${HTTP_ROOT}/$a"; done )
}

download() {
  download_core "${URLS_MSYS}"
}


install_pkg() {
   install_msys
}

install_msys() 
{
   # target directory in package tree
   TDIR=${PACKAGE_ROOT}/${DIR_MSYS}
   # create it if necessary
   mkdir -pv $TDIR
   
   TAR=tar
   TAROPT="-xz"
   
   ( cd $TDIR &&
   # extract files
   for a in ${URLS_MSYS}; do $TAR $TAROPT -f $TOPDIR/$a; done
   )
   
   # move .ico file because windows gets confused when you have also installed matlab
   mv ${TDIR}/m.ico ${TDIR}/the-m.ico
   
   # modify startup script to use smaller font
   sed -e "s/Courier-12/\"Lucida Console-10\"/" "${TDIR}/msys.bat" > msys.bat
   mv msys.bat ${TDIR}/msys.bat
}
   
srcpkg()
{
   "${SEVENZIP}" ${SEVENZIP_FLAGS} ${SRCPKG_PATH}/${PKG}-${VER}-${REL}-src.7z ${URLS_MSYS} build-${VER}-${REL}.sh
}

mkdirs() { echo $0: mkdirs not required; }
applypatch() { echo $0: applypatch not required; }
conf() { echo $0: conf not required; }
build() { echo $0: build not required; }
install() { echo $0: install not required; }

# do whatever the user specified...
$*