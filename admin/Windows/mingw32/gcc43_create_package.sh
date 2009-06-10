#!/usr/bin/sh

# This packages OCTAVE MINGW32

source gcc43_common.sh
source gcc43_pkg_version.sh

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

SRCES="${PACKAGE_ROOT}/bin \
${PACKAGE_ROOT}/doc \
${PACKAGE_ROOT}/include \
${PACKAGE_ROOT}/info \
${PACKAGE_ROOT}/lib \
${PACKAGE_ROOT}/libexec \
${PACKAGE_ROOT}/man \
${PACKAGE_ROOT}/share \
${PACKAGE_ROOT}/mingw32 \
${PACKAGE_ROOT}/msys \
${PACKAGE_ROOT}/tools \
${PACKAGE_ROOT}/license"

# create zip package
#"${SEVENZIP}" $SEVENZIP_FLAGS ${TOPDIR}/${PKGFILE}.7z $SRCES 

WPACKAGE_ROOT=`cd ${PACKAGE_ROOT}; pwd -W | sed -e 's+/+\\\\\\\\+g'`

echo WPACKAGE_ROOT=$WPACKAGE_ROOT

SUBWCREV="C:/Program Files/TortoiseSVN/bin/subwcrev.EXE"

rm -rf octave_nsi.log

create_octave_forge_deps_nsi()
{
   # Create Dependency checks
   DF=`find ${PACKAGE_ROOT}/share/octave/packages/ -name DESCRIPTION`

   for a in $DF; do
      PACK=`echo $a | sed -e "s/^.*packages\/\([a-zA-Z-]\+\)-.*$/\1/"`
      sed -ne "s/^[dD]epends: *//p" $a | \
        awk -F ', ' '{c=split($0, s); for(n=1; n<=c; ++n) printf("%s\n", s[n]) }' | \
        sed -n -e "s/^octave.*$//" -e "s/^\([a-zA-Z0-9_-]\+\).*$/\!insertmacro CheckDependency \${SEC_FORGE_${PACK}} \${SEC_FORGE_\1}/p"
   done
}

create_octave_forge_nsi()
{
   DF=`find ${PACKAGE_ROOT}/share/octave/packages/ -maxdepth 1 -mindepth 1`
   
   for a in $DF; do
      PACKNAME=`echo $a | sed -ne "s+^.*/\(.\+\)-\([0-9]\+\.[0-9]\+\.[0-9]\+\)$+\1+p"`
      PACKVER=`echo $a | sed -ne "s+^.*/\(.\+\)-\([0-9]\+\.[0-9]\+\.[0-9]\+\)$+\2+p"`
      
      PACKNAMEVER=$PACKNAME-$PACKVER
      
      echo Section /o \"$PACKNAME\" SEC_FORGE_$PACKNAME
      echo;
      
      if [ -d ${PACKAGE_ROOT}/share/octave/packages/$PACKNAMEVER ]; then
         echo "  SetOutPath \"\$INSTDIR\\share\\octave\\packages\\$PACKNAMEVER\""
         echo "  File /r \"\${PACKAGE_ROOT}\\share\\octave\\packages\\$PACKNAMEVER\\*.*\""
      fi
      if [ -d ${PACKAGE_ROOT}/libexec/octave/packages/$PACKNAMEVER ]; then
         echo "  SetOutPath \"\$INSTDIR\\libexec\\octave\\packages\\$PACKNAMEVER\""
         echo "  File /r \"\${PACKAGE_ROOT}\\libexec\\octave\\packages\\$PACKNAMEVER\\*.*\""
      fi
      
      echo;
      echo SectionEnd
      echo;

   done
}

create_readme_file()
{
   BUILD_REVISION=`"$SUBWCREV" . | sed -ne "s/Last committed at revision \([0-9]\+\)/\1/p"`
   GCCVER=`$CC -v 2>&1 | sed -ne "/gcc version/p"`
   
   # Create the readme file
   sed \
    -e "s/@OCTAVE_VERSION@/${PKG_VER}/" \
    -e "s/@BUILD_REVISION@/${BUILD_REVISION}/" \
    -e "s/@GCC_VERSION@/${GCCVER}/" \
    README.txt.in
   
   cat forgelist.txt | sort | sed -e "s/^\(.*\)$/   \1/"
   
   echo;
   
   cat ${PACKAGE_ROOT}/share/octave/${PKG_VER}/etc/NEWS
}
   
create_octave_forge_nsi > octave_forge.nsi
create_octave_forge_deps_nsi > octave_forge_deps.nsi
create_readme_file > README.txt
unix2dos README.txt

# create installer package
sed \
	-e "s/@OCTAVE_VERSION@/${PKG_VER}/" \
	-e "s/@OCTAVE_RELEASE@/${PKG_REL}/" \
	-e "s/@GCC_VERSION@/${GCC_VER}/" \
	-e "s+@PACKAGE_ROOT@+${WPACKAGE_ROOT}+" \
	octave.nsi.in > octave.nsi
${MAKENSIS} octave.nsi | tee octave_nsi.log
