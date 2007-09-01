#!/bin/sh
# Copyright (C) 2007, Thomas Treichl and Paul Kienzle
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
# 02110-1301 USA


# You must install the Octave.app at least on your desktop - you need
# read/write permission for installing packages with Octave's 'pkg'
# command.

# This is the binary of Octave that has been created. The absolute
# path and the version number need to be given.
OCTBIN=/tmp/dependencies-ppc/bin/octave-2.9.13

# This is the temporary directory that is used for copying Octave and
# its libraries that depend on the Octave.app.
TEMPDIR=/tmp/TEMPDIR

# This is the directory where all the dependencies have been
# installed. Make sure that there are no other files in this directory
# that are not needed.
DEPSDIR=/tmp/dependencies-ppc

# These are the files that are copied into the docs directory of the
# octave-VERSION-ARCH.dmg file. The files that are needed are
# Octave-FAQ.pdf, octave.pdf, liboctave.pdf, refcard-a4.pdf,
# refcard-legal.pdf and refcard-letter.pdf.
PDFDOCS=~/tmp/octave-ppc/solvedeps/octave-2.9.13/doc/{faq/Octave-FAQ.pdf,interpreter/octave.pdf,liboctave/liboctave.pdf,refcard/refcard-{a4,legal,letter}.pdf}

OCEXTRAS=~/Savings/gnuplot-4.2.2-ppc.dmg

# This is the temporary directory that is used for installing all
# files and libraries that are then packed into the
# octave-VERSION-ARCH.dmg file.
DMGDIR=/tmp/dmgdirectory

# This file can be taken to redirect the output of stdout and stderr to
# a build file. Sometimes this is wanted to not display a lot of build
# messages.
OUTFILE=/tmp/octaveapp.msg # /dev/stdout

##########################################################################
#####            Don't modify anything downwards from here           #####
##########################################################################

# Function:    evalfailexit
# Input args:  ${1} is the string that has to be evaluated
#              ${OUTFILE} is used for the output of messages
# Output args: 
# Description: Evaluates the ${1} string, prints a message and exits on fail
evalfailexit() {
  if ! ( eval "${1} 2>&1>${OUTFILE}" ); then
    echo "makeoctaveapp.sh: Building Octave.app has failed"
    echo "The command that failed was"
    echo "  ${1}"
    exit 1
  fi
}

# Function:    solvedeps
# Input args:  ${1} is a file for which the libs have to be found and copied
#              ${2} is the string that has to be found for copying the libs
#              ${3} is the destination folder to where the libs are copied
# Output args: 
# Description: Copies the founded libs to ${3}/lib that depend on the given
#              file ${1} and that do match the string ${2}. This function is
#              a recursive function and should find all dynamic libraries.
solvedeps() {
  local LIBS=`otool -L ${1} | xargs grep -silent ${2} | grep ${2}`
  for FILE in ${LIBS}; do
    if [ ${1} != ${FILE} ]; then 
      echo "makeoctaveapp.sh: Installing ${FILE} ..."
      evalfailexit "install -c -S -m 755 ${FILE} ${3}/lib"
      echo "makeoctaveapp.sh: Checking ${FILE} ..."
      solvedeps ${FILE} ${2} ${3}
    fi
  done
}

# This is the main bash routine
if [ $# -ne 1 ]; then
  echo "Usage: makeoctaveapp.sh --ppc|--i386"
  exit 1
else

  VERSION=${OCTBIN##*octave-}
  PREFIX=${OCTBIN%/bin*}
  DATE=`date`

  case ${1} in
    --ppc)
      ARCH="ppc"
      ;;
    --i386)
      ARCH="i386"
      ;;
    *)
      echo "makeoctaveapp.sh: Unknown option ${1}"
      exit 1
      ;;
  esac

  echo "makeoctaveapp.sh: Checking if tmp-directory is empty ..."
  evalfailexit "if [ ! -d ${TEMPDIR} ]; then mkdir ${TEMPDIR}; fi"
  evalfailexit "rm -rf ${TEMPDIR}/*"

  echo "makeoctaveapp.sh: Creating Readme.html.in file from octaveapp.texi ..."
  evalfailexit "export LANG=en; makeinfo --html --no-split octaveapp.texi -o Readme.html.in"

  echo "makeoctaveapp.sh: Collecting Octave files ..."
  evalfailexit "install -d ${TEMPDIR}{,/bin,/include,/info,/lib,/libexec,/man,/man/man1,/share}"
  evalfailexit "cp -R -P -vp ${PREFIX}/bin/{mkoctfile,octave,octave-bug,octave-config}-${VERSION} ${TEMPDIR}/bin"
  evalfailexit "cp -R -P -vp ${PREFIX}/include/octave-${VERSION} ${TEMPDIR}/include"
  evalfailexit "cp -R -P -vp ${PREFIX}/info/dir ${TEMPDIR}/info"
  evalfailexit "cp -R -P -vp ${PREFIX}/info/octave.info{,-1,-2,-3,-4,-5} ${TEMPDIR}/info"
  evalfailexit "cp -R -P -vp ${PREFIX}/lib/octave-${VERSION} ${TEMPDIR}/lib"
  evalfailexit "cp -R -P -vp ${PREFIX}/libexec/octave ${TEMPDIR}/libexec"
  evalfailexit "cp -R -P -vp ${PREFIX}/man/man1/{mkoctfile,octave,octave-bug,octave-config}.1 ${TEMPDIR}/man/man1"
  evalfailexit "cp -R -P -vp ${PREFIX}/share/octave ${TEMPDIR}/share"

echo "FIXME - COPYING *ALL* *a,*la LIBS AND *ALL* INCLUDES"
  evalfailexit "cp -R -P -vp ${DEPSDIR}/bin/* ${TEMPDIR}/bin"
  evalfailexit "cp -R -P -vp ${DEPSDIR}/include/* ${TEMPDIR}/include"
  evalfailexit "cp -R -P -vp ${DEPSDIR}/lib/*  ${TEMPDIR}/lib"
  evalfailexit "cp -R -P -vp ${DEPSDIR}/share/*  ${TEMPDIR}/share"
echo "FIXME - COPYING *ALL* *a,*la LIBS AND *ALL* INCLUDES"

  # echo "makeoctaveapp.sh: Solving dependencies ..."
  # solvedeps ${TEMPDIR}/bin/octave-${VERSION} ${DEPSDIR} ${TEMPDIR}

  # The following line can be used to check the macports octave version
  # solvedeps /opt/local/bin/octave /opt/local /opt/local

  echo "makeoctaveapp.sh: Checking if dmg-directory is empty ..."
  evalfailexit "if [ ! -d ${DMGDIR} ]; then mkdir ${DMGDIR}; fi"
  evalfailexit "rm -rf ${DMGDIR}/*"

  echo "makeoctaveapp.sh: Creating the Octave.app ..."
  # This routine creates a string of the form "-f <dir1> -f <dir2>" etc.
  # of all directories in ${TEMPDIR}
  PLATYFFLAG="";
  for DIRS in ${TEMPDIR}/*; do
    PLATYFFLAG="${PLATYFFLAG} -f ${DIRS}"
  done
  # Cf. http://www.sveinbjorn.org/Files/manpages/platypus.man.pdf about
  # which options are accepted by platypus and how it is working
  evalfailexit "platypus -a Octave.app -t shell -V ${VERSION} \
    -u \"John W. Eaton\" ${PLATYFFLAG} -I \"org.octave\" -R ./applicationstartup.sh.in \
    ${DMGDIR}/Octave.app" # -o TextWindow"

  # Workaround for the missing -i option of platypus. Install icon manually
  echo "makeoctaveapp.sh: Installing the Octave icon ..."
  evalfailexit "install -c -S -m 777 ./octave.icns \
    ${DMGDIR}/Octave.app/Contents/Resources/appIcon.icns"

  echo "makeoctaveapp.sh: Setting variables in startup script ..."
  sed "s/%VERSION%/${VERSION}/g;s/%ARCH%/${ARCH}/g" octave.in > octave
  evalfailexit "install -c -S -m 777 octave \
    ${DMGDIR}/Octave.app/Contents/Resources/bin/octave"

  echo "makeoctaveapp.sh: Setting variables in mkoctfile script ..."
  sed "s/%VERSION%/${VERSION}/g;s/%ARCH%/${ARCH}/g" mkoctfile.in > mkoctfile
  evalfailexit "install -c -S -m 777 mkoctfile \
    ${DMGDIR}/Octave.app/Contents/Resources/bin/mkoctfile"

  echo "makeoctaveapp.sh: Setting variables in Readme file ..."
  sed "s/%VERSION%/${VERSION}/g;s/%ARCH%/${ARCH}/g;s/%DATE%/${DATE}/g" Readme.html.in > Readme.html
  evalfailexit "install -c -S ./Readme.html     ${DMGDIR}/Readme.html"

  echo "makeoctaveapp.sh: Installing the Octave Docs ..."
  evalfailexit "install -d ${DMGDIR}/Doc"
  evalfailexit "cp -R -P -vp ${PDFDOCS} ${DMGDIR}/Doc"

  echo "makeoctaveapp.sh: Installing the Octave Extras ..."
  evalfailexit "install -d ${DMGDIR}/Extras"
  evalfailexit "cp -R -P -vp ${OCEXTRAS} ${DMGDIR}/Extras"

  echo "makeoctaveapp.sh: Installing image files ..."
  # sed 's/_background/.background/g' ./_DS_Store >${DMGDIR}/.DS_STORE
  evalfailexit "install -c -S ./_DS_Store_Main  ${DMGDIR}/.DS_Store"
  evalfailexit "install -c -S ./_DS_Store_Doc   ${DMGDIR}/doc/.DS_Store"
  evalfailexit "install -c -S ./_background.png ${DMGDIR}/.background.png"
  evalfailexit "ln -s /Applications ${DMGDIR}/Applications"
  evalfailexit "rm -rf ${DMGDIR}/.Trashes"

  echo "makeoctaveapp.sh: Checking for an already existing octave-${VERSION}-${ARCH}.dmg ..."
  evalfailexit "rm -rf ./octave-${VERSION}-${ARCH}.dmg" 

  echo "makeoctaveapp.sh: Packing dmg compressed disk ..."
  evalfailexit "hdiutil create -volname octave-${VERSION} -fs HFS+ \
    -srcfolder ${DMGDIR} ./octave-${VERSION}-${ARCH}.dmg"

  # Some references that tell us how to set up the background image for the dmg
  # http://forums.macrumors.com/archive/index.php/t-208278.html
  # http://jwz.livejournal.com/608927.html
  # http://lxr.mozilla.org/seamonkey/source/build/package/mac_osx/
  # hdiutil convert -format UDRW -o conv.dmg octave-2.9.13.dmg
  # hdiutil mount conv.dmg

  echo "makeoctaveapp.sh: Removing temporary directories ..."
  evalfailexit "rm -rf ${TEMPDIR} ${DMGDIR}"

  echo "makeoctaveapp.sh: octave-${VERSION}-${ARCH}.dmg has succesfully been built *FINISHED*"

fi