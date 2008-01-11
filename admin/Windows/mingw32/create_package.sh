#!/usr/bin/sh

# This packages OCTAVE MINGW32

source pkg_version.sh
source common.sh

# Name of the package we're building
PKG=octave-${PKG_VER}-${PKG_REL}_i686-pc-mingw32_gcc${GCC_VER}${GCC_SYS}
# Version of the package
#VER=${PKG_VER}
# Release No
#REL=${PKG_REL}
# URL to source code
URL=

# ---------------------------
# The directory this script is located
# Make sure that we have a MSYS patch starting with a drive letter!
TOPDIR=`pwd -W | sed -e 's+^\([a-zA-z]\):/+/\1/+'`
# Name of the source package
PKGNAME=${PKG}
# Full package name including revision
FULLPKG=${PKGNAME}
# Name of the source code package
#SRCPKG=${PKGNAME}
# Name of the patch file
#PATCHFILE=${FULLPKG}.diff
# Name of the source code file
#SRCFILE=${PKGNAME}.tar.bz2
# Directory where the source code is located
#SRCDIR=${TOPDIR}/${PKGNAME}
PKGFILE=${FULLPKG}

SEVENZIP="/c/Program Files/7-Zip/7z.exe"

# Create archive package
( cd ${PACKAGE_ROOT} && ${TAR} cjvf ${TOPDIR}/${PKGFILE}.tar.bz2 bin doc include info lib libexec man share mingw32 msys );
( cd ${PACKAGE_ROOT} && ${TAR} cjv --exclude=mingw32 --exclude=MSYS -f ${TOPDIR}/${PKGFILE}_wo-compiler.tar.bz2 . );
( cd ${PACKAGE_ROOT} && ${TAR} cjvf ${TOPDIR}/${PKGFILE}_mingw32-msys.tar.bz2 mingw32 msys );

CF=7
"${SEVENZIP}" a -t7z ${TOPDIR}/${PKGFILE}.exe ${PACKAGE_ROOT}{/bin,/doc,/include,/info,/lib,/libexec,/man,/share,/mingw32,/msys} -mx${CF} -sfx7z.sfx
"${SEVENZIP}" a -t7z ${TOPDIR}/${PKGFILE}_mingw32-msys.exe ${PACKAGE_ROOT}{/mingw32,/msys} -mx${CF} -sfx7z.sfx
"${SEVENZIP}" a -t7z ${TOPDIR}/${PKGFILE}_wo-compiler.exe ${PACKAGE_ROOT}{/bin,/doc,/include,/info,/lib,/libexec,/man,/share} -mx${CF} -sfx7z.sfx

#CF=9
#"${SEVENZIP}" a -t7z ${TOPDIR}/${PKGFILE}-CF${CF}.exe ${PACKAGE_ROOT} -mx${CF} -sfx7z.sfx
#"${SEVENZIP}" a -t7z ${TOPDIR}/${PKGFILE}_mingw32-msys-CF${CF}.exe ${PACKAGE_ROOT}{/mingw32,/msys} -mx${CF} -sfx7z.sfx
#"${SEVENZIP}" a -t7z ${TOPDIR}/${PKGFILE}_wo-compliler-CF${CF}.exe ${PACKAGE_ROOT}{/bin,/doc,/include,/info,/lib,/libexec,/man,/share} -mx${CF} -sfx7z.sfx
