#!/bin/sh
# Copyright (C) 2007, Thomas Treichl and Paul Kienzle
# Copyright (C) 2008, Thomas Treichl
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
# along with this program; If not, see <http://www.gnu.org/licenses/>.

# To identify this script file correctly we once again put it's name
THISSCRIPT=${0##*/}

# You're not free in choosing another compiler than XCode's - so this
# is set up automatically. By default we use f2c that is compiled as
# the first program if used input argument '--all'.

# This is the name of the file that is used for displaying outputs
# while configuring, compiling and installing. Use /dev/stdout to
# display all messages in the running terminal.
MSGFILE=/tmp/message.log # /dev/stdout

# This is the name of the directory where all dependencies are
# installed. The string "-ppc" or "-i386" is added to the end of the
# given pathname, eg. /tmp/abc becomes /tmp/abc-pcc etc.
INSTDIR=/tmp/deps

vdeb="http://ftp.de.debian.org/debian/pool/main/"
vloc="file://`pwd`/patches/"

vf2cX=(f2c-20061008.orig f2c-20061008)
vf2c=(${vdeb}f/f2c/f2c_20061008.orig.tar.gz ee4de307c6e55ddaf752d78c5327f08d
      ${vdeb}f/f2c/f2c_20061008-3.diff.gz   8460217666e4899c3897e002151508c3
      ${vloc}f2c-20061008.macosx.diff.gz    f65653181f0bc2ce7745037df85dd0bd)

vlibf2cX=(libf2c2-20061008.orig libf2c2-20061008)
vlibf2c=(${vdeb}libf/libf2c2/libf2c2_20061008.orig.tar.gz b5b6bc321f37cad4219dfb6156f8fbbd
         ${vdeb}libf/libf2c2/libf2c2_20061008-4.diff.gz   87b7c28bf03a49d43d39ad2fe8b657bf
         ${vloc}libf2c2-20061008.macosx.diff.gz           2bf1cc2ba50c59184d0219f089d1025b)

vfort77X=(fort77-1.15.orig fort77-1.15)
vfort77=(${vdeb}f/fort77/fort77_1.15.orig.tar.gz fd4d3dd29f9099bc37a3da00902399fd
         ${vdeb}f/fort77/fort77_1.15-7.diff.gz   80c99442031ba06f65bf47f4c5c6983f
         ${vloc}fort77-1.15.diff.gz              bbd7748e1237d37039a59126ea4b4c12)

vzlibX=(zlib-1.2.3.3.dfsg zlib-1.2.3.3.dfsg)
vzlib=(${vdeb}z/zlib/zlib_1.2.3.3.dfsg.orig.tar.gz 39ae1c6fbdd3b98d4fa9af25206202c5
       ${vdeb}z/zlib/zlib_1.2.3.3.dfsg-12.diff.gz  21d597eba701cf1beed9c79d8418706f)

vreadlineX=(readline-5.2 readline5-5.2)
vreadline=(${vdeb}r/readline5/readline5_5.2.orig.tar.gz e39331f32ad14009b9ff49cc10c5e751
           ${vdeb}r/readline5/readline5_5.2-3.diff.gz   e4ca68ff10696dfc47ca5a2dfb967648)

vpcreX=(pcre-7.6 pcre3-7.6)
vpcre=(${vdeb}p/pcre3/pcre3_7.6.orig.tar.gz b94cce871f70734c2dfc47b52a3aa670)
# pcre patch doesn't work
#      ${vdeb}p/pcre3/pcre3_7.6-2.1.diff.gz d9161feccec8b87f98ffafa288bb0abf)

vhdf5X=(hdf5-1.6.6 hdf5-1.6.6)
vhdf5=(${vdeb}h/hdf5/hdf5_1.6.6.orig.tar.gz 6c7fcc91f1579555d88bb10c6c9a33a9
       ${vdeb}h/hdf5/hdf5_1.6.6-4.diff.gz   3976fab00d8834ff151da989efeb9821)

vfftwX=(fftw-3.1.2 fftw3-3.1.2)
vfftw=(${vdeb}f/fftw3/fftw3_3.1.2.orig.tar.gz 08f2e21c9fd02f4be2bd53a62592afa4)
# fftw patch doesn't work
#       ${vdeb}f/fftw3/fftw3_3.1.2-3.1.diff.gz 033bacf33ea52af3c944920ff052a745)

vcurlX=(curl-7.18.2 curl-7.18.2)
vcurl=(${vdeb}c/curl/curl_7.18.2.orig.tar.gz 4fe99398a64a34613c9db7bd61bf6e3c
       ${vdeb}c/curl/curl_7.18.2-5.diff.gz   5dcf76cf7facfbc77a1bf6f46d01011e)

vglpkX=(glpk-4.29 glpk-4.29)
vglpk=(${vdeb}g/glpk/glpk_4.29.orig.tar.gz 1e2d341619162499bbdebc96ca1d99a4
       ${vdeb}g/glpk/glpk_4.29-2.diff.gz   224ff1ab063c22e1acacf1748eaa22df)

vqhullX=(qhull-2003.1 qhull-2003.1)
vqhull=(${vdeb}q/qhull/qhull_2003.1.orig.tar.gz     48228e26422bff85ef1f45df5b6e3314
        ${vdeb}q/qhull/qhull_2003.1-9lenny1.diff.gz 9ddfefbbe76fb4a34baeb8825fdf49e2)

vsuitesparseX=(SuiteSparse suitesparse-3.1.0)
vsuitesparse=(${vdeb}s/suitesparse/suitesparse_3.1.0.orig.tar.gz 58d90444feef92fc7c265cbd11a757c6
              ${vdeb}s/suitesparse/suitesparse_3.1.0-3.diff.gz   6ccae86d981248560d26e3a72de3eea4
              ${vloc}suitesparse-3.1.0.macosx.diff.gz            10d6fb418965cfa8d7021d929925ece8)

vfreetypeX=(freetype-2.3.7 freetype-2.3.7)
vfreetype=(${vdeb}f/freetype/freetype_2.3.7.orig.tar.gz c1a9f44fde316470176fd6d66af3a0e8
           ${vdeb}f/freetype/freetype_2.3.7-2.diff.gz   37ad0b2481156f7caf841549d7e96819)

vfltkX=(fltk-1.1.9 fltk1.1-1.1.9)
vfltk=(${vdeb}f/fltk1.1/fltk1.1_1.1.9.orig.tar.gz d3c76db1b6cebce7a009429bbd125470)
# fltk patch doesn't work, Debian includes libintl.h which is not part of OSX
#      ${vdeb}f/fltk1.1/fltk1.1_1.1.9-5.diff.gz   6edb67b11746d1646ade6b5ef7f2af63)

vftglX=(ftgl-2.1.3~rc5 ftgl-2.1.3~rc5)
vftgl=(${vdeb}f/ftgl/ftgl_2.1.3~rc5.orig.tar.gz fcf4d0567b7de9875d4e99a9f7423633
       ${vdeb}f/ftgl/ftgl_2.1.3~rc5-2.diff.gz   0274aa71338574c116153ded0e5e8b5d)

vpngX=(libpng-1.2.29 libpng-1.2.29)
vpng=(http://switch.dl.sourceforge.net/sourceforge/libpng/libpng-1.2.29.tar.gz
      a388004b7d7492660c19a2d611a8ca62)
#vpngX=(libpng-1.2.27 libpng-1.2.27)
#vpng=(${vdeb}libp/libpng/libpng_1.2.27.orig.tar.gz 13a0de401db1972a8e68f47d5bdadd13)
#      ${vdeb}libp/libpng/libpng_1.2.27-1.diff.gz   fb5a30d4e95ad1a64c6cc5b23fee756b)

vjpegX=(jpeg-6b libjpeg6b-6b.orig)
vjpeg=(${vdeb}libj/libjpeg6b/libjpeg6b_6b.orig.tar.gz dbd5f3b47ed13132f04c685d608a7547
       ${vdeb}libj/libjpeg6b/libjpeg6b_6b-14.diff.gz  97b7880b526145e6b8146de625bca32b)

vtiffX=(tiff-3.8.2 tiff-3.8.2)
vtiff=(${vdeb}t/tiff/tiff_3.8.2.orig.tar.gz e6ec4ab957ef49d5aabc38b7a376910b
       ${vdeb}t/tiff/tiff_3.8.2-11.diff.gz  902f023cfc231455100b7a0a9b8af44b)

#http://www.graphicsmagick.org/www/README.html
#DYLD_LIBRARY_PATH=/Applications/Octave.app/Contents/Resources/lib /Applications/Octave.app/Contents/Resources/bin/gm convert -list format
vgraphicsmagickX=(GraphicsMagick-1.1.11 graphicsmagick-1.1.11)
vgraphicsmagick=(${vdeb}g/graphicsmagick/graphicsmagick_1.1.11.orig.tar.gz
                 16a032350a153d822ac07cae01961a91
                 ${vdeb}g/graphicsmagick/graphicsmagick_1.1.11-3.2.diff.gz
                 bbfaf89d0be45f14c550794db84cd6ae)

voctaveX=(octave-3.1.51 octave-3.1.51)
voctave=(ftp://ftp.octave.org/pub/octave/bleeding-edge/octave-3.1.51.tar.gz
         4d339148860fe12fc27fa4b5a32c6d21
         ${vloc}octave-3.1.51.diff.gz d6f2da788e3b7bd7696d1a77dbdbf79f)

##########################################################################
#####                Don't modify anything downwards here            #####
##########################################################################

# Function:    evalfailexit
# Input args:  ${1} is the string that has to be evaluated
#              ${MSGFILE} is used for the output of messages
# Output args: -
# Description: Evaluates the ${1} string, prints a message and exits on fail
evalfailexit() {
  if ( ! eval "${1} >> ${MSGFILE} 2>&1" ); then
    echo "${THISSCRIPT}: Building Octave.app has failed !!"
    echo "${THISSCRIPT}: The command that failed was: ${1}"
    exit 1
  fi
}

# Function:    file_download
# Input args:  ${1} the full web adress of the file
#              ${2} the md5 checksum of that file
# Output args: 
file_download() {
  local vfile=${1##*/} 
  if [ ! -f ${vfile} ]; then
    echo "${THISSCRIPT}: Downloading \"${vfile}\" ..."
    evalfailexit "/usr/bin/curl -s -S ${1} -o ${vfile}"
  fi
  if [ `md5 -q ${vfile}` != ${2} ]; then
    echo "${THISSCRIPT}: md5 checksum error in \"${vfile}\" ..."
    echo "${THISSCRIPT}: The command that failed was: `md5 -q ${vfile}` == ${2}"
    exit 1
  fi
}

file_movedebian() {
  evalfailexit "rm -rf ${2}"
  evalfailexit "mv ${1} ${2}"
}

# Function:    file_unpack
# Input args:  ${1} is the name of the file that has to be unpacked
# Output args: 
file_unpack () {
  if [ ${1##*.tar.} == "gz" ]; then
    local vtmp=${1%.tar.gz}
    if [ -a ${vtmp} ]; then
      evalfailexit "rm -rf ${vtmp}"
    fi
    echo "${THISSCRIPT}: Extracting \"${1}\" ..."
    evalfailexit "tar -xzf ${1}"
  else
    echo "${THISSCRIPT}: Missing implementation"
    exit 1
  fi
}

# Function:    confmakeinst
# Input args:  ${1} is the directory name for the sources
#              ${2} is the extra flags for configuration
# Output args: -
# Description: Configures, compiles and installs a source package
confmakeinst() {
  echo "${THISSCRIPT}: Configuring \"${1}\" ..."
  evalfailexit "${2} ./configure ${3}"
  echo "${THISSCRIPT}: Making \"${1}\" ..."
  evalfailexit "${2} make"
  echo "${THISSCRIPT}: Installing \"${1}\" ..."
  evalfailexit "${2} make install"
}

##########################################################################
#####         Functions for building the Octave dependencies         #####
##########################################################################

build_f2c () {
  ## Download and unpack the main package
  file_download ${vf2c[0]} ${vf2c[1]}
  file_unpack ${vf2c[0]##*/}
  file_movedebian ${vf2cX[0]} ${vf2cX[1]}

  ## ${#1[*]} is the number of elements in the array ${1}
  ## Download the patches available and apply them
  for (( vct1 = 2; vct1 < ${#vf2c[*]}; vct1 = vct1 + 2 )); do
    file_download ${vf2c[vct1]} ${vf2c[vct1+1]}
    evalfailexit "gunzip -c ${vf2c[vct1]##*/} | patch -p0"
  done

  cd ${vf2cX[1]}/src
  echo "${THISSCRIPT}: Making \"${vf2cX[1]}\" ..."
  evalfailexit "${VARIABLES} CC=\"${GCC}\" CFLAGS=\"${CFLAGS}\" \
    LDFLAGS=\"${LDFLAGS}\" PREFIX=${INSTDIR} make install -f makefile.u"
}

build_libf2c () {
  file_download ${vlibf2c[0]} ${vlibf2c[1]}
  file_unpack ${vlibf2c[0]##*/}
  file_movedebian ${vlibf2cX[0]} ${vlibf2cX[1]}

  for (( vct1 = 2; vct1 < ${#vlibf2c[*]}; vct1 = vct1 + 2 )); do
    file_download ${vlibf2c[vct1]} ${vlibf2c[vct1+1]}
    evalfailexit "gunzip -c ${vlibf2c[vct1]##*/} | patch -p0"
  done

  cd ${vlibf2cX[1]}
  echo "${THISSCRIPT}: Making \"${vlibf2cX[1]}\" ..."
  evalfailexit "${VARIABLES} CC=\"${GCC}\" CFLAGS=\"${CFLAGS}\" \
    LDFLAGS=\"${LDFLAGS}\" PREFIX=${INSTDIR} make install -f makefile.u"
}

build_fort77 () {
  file_download ${vfort77[0]} ${vfort77[1]}
  file_unpack ${vfort77[0]##*/}
  file_movedebian ${vfort77X[0]} ${vfort77X[1]}

  for (( vct1 = 2; vct1 < ${#vfort77[*]}; vct1 = vct1 + 2 )); do
    file_download ${vfort77[vct1]} ${vfort77[vct1+1]}
    evalfailexit "gunzip -c ${vfort77[vct1]##*/} | patch -p0"
  done

  cd ${vfort77X[1]}
  echo "${THISSCRIPT}: Making \"${vfort77X[1]}\" ..."
  evalfailexit "./configure >> ${MSGFILE}"
  evalfailexit "cp fort77 ${INSTDIR}/bin"
}

# The link /Developer/SDKs/MacOSX10.3.9.sdk/usr/lib/libz.dylib has
# to be removed, otherwise the SDK internal libz is found and this
# results in a bug
build_zlib () {
  file_download ${vzlib[0]} ${vzlib[1]}
  file_unpack ${vzlib[0]##*/}
  # file_movedebian ${vzlibX[0]} ${vzlibX[1]}

  for (( vct1 = 2; vct1 < ${#vzlib[*]}; vct1 = vct1 + 2 )); do
    file_download ${vzlib[vct1]} ${vzlib[vct1+1]}
    evalfailexit "gunzip -c ${vzlib[vct1]##*/} | patch -p0"
  done

  cd ${vzlibX[1]}
  local VARIABLES="MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} \
             CC=\"${GCC} ${ARCH} ${OPTFLAGS}\" CFLAGS=\"${CFLAGS}\" \
             PREFIX=${INSTDIR}"
  evalfailexit "${VARIABLES} ./configure --prefix=${INSTDIR} --shared >> ${MSGFILE}"
  evalfailexit "make && make check && make install >> ${MSGFILE}"
### FIXME !!! ###
evalfailexit "rm -rf ${INSTDIR}/lib/libz.a"
#################
}

build_readline () {
  file_download ${vreadline[0]} ${vreadline[1]}
  file_unpack ${vreadline[0]##*/}
  file_movedebian ${vreadlineX[0]} ${vreadlineX[1]}

  for (( vct1 = 2; vct1 < ${#vreadline[*]}; vct1 = vct1 + 2 )); do
    file_download ${vreadline[vct1]} ${vreadline[vct1+1]}
    evalfailexit "gunzip -c ${vreadline[vct1]##*/} | patch -p0"
  done

  cd ${vreadlineX[1]}
  confmakeinst ${vreadlineX[1]} "${VARIABLES}" "${1} --disable-static"
}

build_curl () { 
  file_download ${vcurl[0]} ${vcurl[1]}
  file_unpack ${vcurl[0]##*/}
  # file_movedebian ${vcurlX[0]} ${vcurlX[1]}

  for (( vct1 = 2; vct1 < ${#vcurl[*]}; vct1 = vct1 + 2 )); do
    file_download ${vcurl[vct1]} ${vcurl[vct1+1]}
    evalfailexit "gunzip -c ${vcurl[vct1]##*/} | patch -p0"
  done

  cd ${vcurlX[1]}
  confmakeinst ${vcurlX[1]} "${VARIABLES}" "${1} --disable-static"
}

build_pcre () {
  file_download ${vpcre[0]} ${vpcre[1]}
  file_unpack ${vpcre[0]##*/}
  file_movedebian ${vpcreX[0]} ${vpcreX[1]}

  for (( vct1 = 2; vct1 < ${#vpcre[*]}; vct1 = vct1 + 2 )); do
    file_download ${vpcre[vct1]} ${vpcre[vct1+1]}
    evalfailexit "gunzip -c ${vpcre[vct1]##*/} | patch -p0"
  done

  cd ${vpcreX[1]}
  confmakeinst ${vpcreX[1]} "${VARIABLES}" "${1} --disable-static"
}

# CF. http://www.llnl.gov/visit/1.6/BUILD_NOTES_MacOSX about building
# the hdf5 library for MacOSX - it fails but it is already enough when
# compilation fails. Also "make -j 2" may fails with this package if
# cross-compiled.
build_hdf5 () { 
  file_download ${vhdf5[0]} ${vhdf5[1]}
  file_unpack ${vhdf5[0]##*/}
  # file_movedebian ${vhdf5X[0]} ${vhdf5X[1]}

  for (( vct1 = 2; vct1 < ${#vhdf5[*]}; vct1 = vct1 + 2 )); do
    file_download ${vhdf5[vct1]} ${vhdf5[vct1+1]}
    evalfailexit "gunzip -c ${vhdf5[vct1]##*/} | patch -p0"
  done

  cd ${vhdf5X[1]}
  # evalfailexit "autoreconf"
  local CONFIGURE="CFLAGS=\"${OPTFLAGS} ${ARCH} ${CFLAGS} -I${INCPATH}\" \
             CPPFLAGS=\"-I${INCPATH}\" --prefix=${INSTDIR} --disable-cxx \
             --disable-static"
  confmakeinst ${vhdf5X[1]} "${VARIABLES}" "${CONFIGURE}"
}

build_fftw () { 
  file_download ${vfftw[0]} ${vfftw[1]}
  file_unpack ${vfftw[0]##*/}
  file_movedebian ${vfftwX[0]} ${vfftwX[1]}

  for (( vct1 = 2; vct1 < ${#vfftw[*]}; vct1 = vct1 + 2 )); do
    file_download ${vfftw[vct1]} ${vfftw[vct1+1]}
    evalfailexit "gunzip -c ${vfftw[vct1]##*/} | patch -p0"
  done

  cd ${vfftwX[1]}
  confmakeinst ${vfftwX[1]} "${VARIABLES}" "${1} --enable-shared --disable-static"
  confmakeinst ${vfftwX[1]} "${VARIABLES}" "${1} --enable-float --enable-shared --disable-static"
}

build_glpk () { 
  file_download ${vglpk[0]} ${vglpk[1]}
  file_unpack ${vglpk[0]##*/}
  # file_movedebian ${vglpkX[0]} ${vglpkX[1]}

  for (( vct1 = 2; vct1 < ${#vglpk[*]}; vct1 = vct1 + 2 )); do
    file_download ${vglpk[vct1]} ${vglpk[vct1+1]}
    evalfailexit "gunzip -c ${vglpk[vct1]##*/} | patch -p0"
  done

  cd ${vglpkX[1]}
  confmakeinst ${vglpkX[1]} "${VARIABLES}" "${1} --disable-static"
}

build_qhull () { 
  file_download ${vqhull[0]} ${vqhull[1]}
  file_unpack ${vqhull[0]##*/}
  # file_movedebian ${vqhullX[0]} ${vqhullX[1]}

  for (( vct1 = 2; vct1 < ${#vqhull[*]}; vct1 = vct1 + 2 )); do
    file_download ${vqhull[vct1]} ${vqhull[vct1+1]}
    evalfailexit "gunzip -c ${vqhull[vct1]##*/} | patch -p0"
  done

  cd ${vqhullX[1]}
  confmakeinst ${vqhullX[1]} "${VARIABLES}" "${1} --disable-static"
}

build_suitesparse () { 
  file_download ${vsuitesparse[0]} ${vsuitesparse[1]}
  file_unpack ${vsuitesparse[0]##*/}
  file_movedebian ${vsuitesparseX[0]} ${vsuitesparseX[1]}

  for (( vct1 = 2; vct1 < ${#vsuitesparse[*]}; vct1 = vct1 + 2 )); do
    file_download ${vsuitesparse[vct1]} ${vsuitesparse[vct1+1]}
    evalfailexit "gunzip -c ${vsuitesparse[vct1]##*/} | patch -p0"
  done

  cd ${vsuitesparseX[1]}
  evalfailexit "${VARIABLES} CC=\"${GCC}\" CFLAGS=\"${CFLAGS} -fno-common \
-no-cpp-precomp -fexceptions -D_POSIX_C_SOURCE -D__NOEXTENSIONS__ -DNPARTITION\" \
PREFIX=${INSTDIR} make"
  evalfailexit "${VARIABLES} CC=\"${GCC}\" CFLAGS=\"${CFLAGS} -fno-common \
-no-cpp-precomp -fexceptions -D_POSIX_C_SOURCE -D__NOEXTENSIONS__ -DNPARTITION\" \
PREFIX=${INSTDIR} make install"
}

build_freetype () { 
  file_download ${vfreetype[0]} ${vfreetype[1]}
  file_unpack ${vfreetype[0]##*/}
### FIXME !!! ###
evalfailexit "tar -xjf freetype-2.3.7/freetype-2.3.7.tar.bz2"
#################

  for (( vct1 = 2; vct1 < ${#vfreetype[*]}; vct1 = vct1 + 2 )); do
    file_download ${vfreetype[vct1]} ${vfreetype[vct1+1]}
    evalfailexit "gunzip -c ${vfreetype[vct1]##*/} | patch -p0"
  done

  cd ${vfreetypeX[1]}
  confmakeinst ${vfreetypeX[1]} "${VARIABLES}" "${1} --disable-static"

### FIXME !!! ###
evalfailexit "rm -rf ${INSTDIR}/include/freetype"
evalfailexit "cp -r  ${INSTDIR}/include/freetype2/freetype ${INSTDIR}/include"
evalfailexit "rm -rf ${INSTDIR}/include/freetype2"
#################
}

build_fltk () { 
  file_download ${vfltk[0]} ${vfltk[1]}
  file_unpack ${vfltk[0]##*/}
  file_movedebian ${vfltkX[0]} ${vfltkX[1]}

  for (( vct1 = 2; vct1 < ${#vfltk[*]}; vct1 = vct1 + 2 )); do
    file_download ${vfltk[vct1]} ${vfltk[vct1+1]}
    evalfailexit "gunzip -c ${vfltk[vct1]##*/} | patch -p0"
  done

  cd ${vfltkX[1]}
  confmakeinst ${vfltkX[1]} "${VARIABLES}" "${1} --enable-shared \
    --enable-quartz --enable-gl"
### FIXME !!! ###
evalfailexit "rm -rf ${INSTDIR}/lib/libfltk*.a"
#################
}

build_ftgl () { 
  file_download ${vftgl[0]} ${vftgl[1]}
  file_unpack ${vftgl[0]##*/}
  # file_movedebian ${vftglX[0]} ${vftglX[1]}

  for (( vct1 = 2; vct1 < ${#vftgl[*]}; vct1 = vct1 + 2 )); do
    file_download ${vftgl[vct1]} ${vftgl[vct1+1]}
    evalfailexit "gunzip -c ${vftgl[vct1]##*/} | patch -p0"
  done

  cd ${vftglX[1]}
  confmakeinst ${vftglX[1]} "${VARIABLES}" "${1} --disable-static"
}

build_png () { 
  file_download ${vpng[0]} ${vpng[1]}
  file_unpack ${vpng[0]##*/}

  for (( vct1 = 2; vct1 < ${#vpng[*]}; vct1 = vct1 + 2 )); do
    file_download ${vpng[vct1]} ${vpng[vct1+1]}
    evalfailexit "gunzip -c ${vpng[vct1]##*/} | patch -p0"
  done

  cd ${vpngX[1]}
# confmakeinst ${vpngX[1]} "${VARIABLES}" "${1} --disable-static --with-binconfigs"
  confmakeinst ${vpngX[1]} "${VARIABLES}" "${1} --enable-static --disable-shared --with-binconfigs"
}

build_jpeg () { 
  file_download ${vjpeg[0]} ${vjpeg[1]}
  file_unpack ${vjpeg[0]##*/}
  file_movedebian ${vjpegX[0]} ${vjpegX[1]}

  for (( vct1 = 2; vct1 < ${#vjpeg[*]}; vct1 = vct1 + 2 )); do
    file_download ${vjpeg[vct1]} ${vjpeg[vct1+1]}
    evalfailexit "gunzip -c ${vjpeg[vct1]##*/} | patch -p0"
  done

  cd ${vjpegX[1]}
### FIXME !!! ###
evalfailexit "cp ../${vglpkX[1]}/libtool ."
#################
  evalfailexit "${VARIABLES} ./configure ${1} --disable-shared"
  evalfailexit "${VARIABLES} make"
  evalfailexit "${VARIABLES} make install-lib"
}

build_tiff () { 
  file_download ${vtiff[0]} ${vtiff[1]}
  file_unpack ${vtiff[0]##*/}
  file_unpack ${vtiffX[1]}/${vtiffX[1]}.tar.gz

  for (( vct1 = 2; vct1 < ${#vtiff[*]}; vct1 = vct1 + 2 )); do
    file_download ${vtiff[vct1]} ${vtiff[vct1+1]}
    evalfailexit "gunzip -c ${vtiff[vct1]##*/} | patch -p0"
  done

  cd ${vtiffX[1]}
# confmakeinst ${vtiffX[1]} "${VARIABLES}" "${1} --disable-static"
  confmakeinst ${vtiffX[1]} "${VARIABLES}" "${1} --disable-shared"
}

build_graphicsmagick () { 
  file_download ${vgraphicsmagick[0]} ${vgraphicsmagick[1]}
  file_unpack ${vgraphicsmagick[0]##*/}

  for (( vct1 = 2; vct1 < ${#vgraphicsmagick[*]}; vct1 = vct1 + 2 )); do
    file_download ${vgraphicsmagick[vct1]} ${vgraphicsmagick[vct1+1]}
    evalfailexit "gunzip -c ${vgraphicsmagick[vct1]##*/} | patch -p0"
  done

  cd ${vgraphicsmagickX[1]}
  confmakeinst ${vgraphicsmagickX[1]} "${VARIABLES}" "${1} --enable-shared=yes \
    --enable-static=no --with-perl=no --with-gslib=no --disable-installed"
}

build_octave () { 
  file_download ${voctave[0]} ${voctave[1]}
  file_unpack ${voctave[0]##*/}

  for (( vct1 = 2; vct1 < ${#voctave[*]}; vct1 = vct1 + 2 )); do
    file_download ${voctave[vct1]} ${voctave[vct1+1]}
    evalfailexit "gunzip -c ${voctave[vct1]##*/} | patch -p0"
  done

  cd ${voctaveX[1]}
  confmakeinst ${voctaveX[1]} "${VARIABLES}" "${1} --enable-shared"
}

modify_octave() {
  local voctversion=${voctaveX[1]##*-} # echo ${voctversion}

  echo "${THISSCRIPT}: Removing special strings in mkoctfile-${voctversion} ..."
  sed -e "s:${CFLAGS}::g" -e "s:${CPPFLAGS}::g" -e "s:${CXXFLAGS}::g" \
      -e "s:${LDFLAGS}::g" -e "s:${FLIBS}:-lf2c:g" -e "s:${FFLAGS}::g" \
      -e "s:${ARCH}::g" -e "s:${EXTRACONF}::g" \
      -i.orig ${INSTDIR}/bin/mkoctfile-${voctversion}

  echo "${THISSCRIPT}: Removing special strings in octave-bug-${voctversion} ..."
  sed -e "s:${CFLAGS}::g" -e "s:${CPPFLAGS}::g" -e "s:${CXXFLAGS}::g" \
      -e "s:${LDFLAGS}::g" -e "s:${FLIBS}:-lf2c:g" -e "s:${FFLAGS}::g" \
      -e "s:${ARCH}::g" -e "s:${EXTRACONF}::g" \
      -i.orig ${INSTDIR}/bin/octave-bug-${voctversion}

  echo "--- BUILDING LIBRARIES HAS FINISHED ---"
  echo "(1) Check output on screen for \"The command that failed\""
  echo "(2) Check \"otool -L ${INSTDIR}/lib/*.dylib\""
}

# This is the main bash routine
if [ $# -ne 2 ]; then
    echo "Usage: ${THISSCRIPT} LIBRARY ARCHITECTURE"
    exit 1
else
  case "${2}" in
    --ppc)
      INSTDIR=${INSTDIR}-ppc
      INCPATH=${INSTDIR}/include
      X11PATH=/usr/X11R6/include
      LIBPATH=${INSTDIR}/lib
      BINPATH=${INSTDIR}/bin:${PATH}

      ARCH="-arch ppc"
      OPTFLAGS="-O3 -mpowerpc -faltivec -maltivec -mabi=altivec"
      export MACOSX_DEPLOYMENT_TARGET=10.4

      GCC="gcc ${ARCH} ${OPTFLAGS}"
      CPP="${GCC} -E"
      CXX="g++ ${ARCH} ${OPTFLAGS}"

      CFLAGS="-isysroot /Developer/SDKs/MacOSX10.4u.sdk -I${INCPATH} -I${X11PATH}"
      CPPFLAGS="${CFLAGS}"
      CXXFLAGS="${CFLAGS}"
      LDFLAGS="-L${LIBPATH} -Wl,-headerpad_max_install_names -Wl,-syslibroot -Wl,/Developer/SDKs/MacOSX10.4u.sdk"

      F77="fort77 ${OPTFLAGS} -Xlinker,-arch -Xlinker,ppc"
      FLIBS="-L${LIBPATH} -lf2c"
      FFLAGS="-Wc,-arch -Wc,ppc -Wc,-isysroot -Wc,/Developer/SDKs/MacOSX10.4u.sdk ${OPTFLAGS} -I${INCPATH}"

      EXTRACONF="--host=powerpc-apple-darwin7.9.0"
      ;;

    --i386)
      INSTDIR=${INSTDIR}-i386
      INCPATH=${INSTDIR}/include
      X11PATH=/usr/X11R6/include
      LIBPATH=${INSTDIR}/lib
      BINPATH=${INSTDIR}/bin:${PATH}

      ARCH="-arch i386"
      OPTFLAGS="-O3 -fforce-addr -march=i686 -mfpmath=sse,387 -mieee-fp -msse3 -msse2 -msse -mmmx"
      export MACOSX_DEPLOYMENT_TARGET=10.4

      GCC="gcc ${ARCH} ${OPTFLAGS}"
      CPP="${GCC} -E"
      CXX="g++ ${ARCH} ${OPTFLAGS}"

      CFLAGS="-isysroot /Developer/SDKs/MacOSX10.4u.sdk -I${INCPATH} -I${X11PATH}"
      CPPFLAGS="${CFLAGS}"
      CXXFLAGS="${CFLAGS}"
      LDFLAGS="-L${LIBPATH} -Wl,-headerpad_max_install_names -Wl,-syslibroot -Wl,/Developer/SDKs/MacOSX10.4u.sdk"

      F77="fort77 ${OPTFLAGS}"
      FLIBS="-L${LIBPATH} -lf2c"
      FFLAGS="-Wc,-arch -Wc,i386 -Wc,-isysroot -Wc,/Developer/SDKs/MacOSX10.4u.sdk ${OPTFLAGS} -I${INCPATH}"

      EXTRACONF="--host=i386-apple-darwin8.9.1"
      ;;

    *)
      echo "${THISSCRIPT}: Unknown input argument ${2}"
      echo "${THISSCRIPT}: Second input argument must either be --ppc or --i386"
      exit 1
      ;;

  esac
  
  VARIABLES="MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} \
             DYLD_LIBRARY_PATH=${INSTDIR}/lib:${DYLD_LIBRARY_PATH} \
             DYLD_FALLBACK_LIBRARY_PATH=${INSTDIR}/lib:${DYLD_FALLBACK_LIBRARY_PATH} \
             PATH=${INSTDIR}/bin:${PATH}"

  CONFFLAGS="CC=\"${GCC}\" CPP=\"${CPP}\" CXX=\"${CXX}\" \
             CFLAGS=\"${CFLAGS}\" CPPFLAGS=\"${CPPFLAGS}\" CXXFLAGS=\"${CXXFLAGS}\" \
             LDFLAGS=\"${LDFLAGS}\" --prefix=${INSTDIR} ${EXTRACONF} \
             F77=\"${F77}\" FLIBS=\"${FLIBS}\" FFLAGS=\"${FFLAGS}\""

  MAKE="make"
  export PATH="${INSTDIR}/bin:${PATH}"

  case "${1}" in
    --f2c)            build_f2c    "${CONFFLAGS}" ;;
    --libf2c)         build_libf2c "${CONFFLAGS}" ;;
    --fort77)         build_fort77 "${CONFFLAGS}" ;;

    --zlib)           build_zlib   "${CONFFLAGS}" ;;
    --readline)       build_readline "${CONFFLAGS}" ;;
    --pcre)           build_pcre "${CONFFLAGS}" ;;
    --hdf5)           build_hdf5 "${CONFFLAGS}" ;;
    --fftw)           build_fftw "${CONFFLAGS}" ;;
    --curl)           build_curl "${CONFFLAGS}" ;;
    --glpk)           build_glpk "${CONFFLAGS}" ;;
    --qhull)          build_qhull "${CONFFLAGS}" ;;
    --suitesparse)    build_suitesparse "${CONFFLAGS}" ;;

    --freetype)       build_freetype "${CONFFLAGS}" ;;
    --fltk)           build_fltk "${CONFFLAGS}" ;;
    --ftgl)           build_ftgl "${CONFFLAGS}" ;;

    --png)            build_png "${CONFFLAGS}"  ;;
    --jpeg)           build_jpeg "${CONFFLAGS}" ;;
    --tiff)           build_tiff "${CONFFLAGS}" ;;
    --graphicsmagick) build_graphicsmagick "${CONFFLAGS}" ;;

    --octave)         build_octave "${CONFFLAGS}" ;;
    --modify_octave)  modify_octave ;;

    --bundle-fortran) 
      evalfailexit "./${THISSCRIPT} --f2c    ${2}"
      evalfailexit "./${THISSCRIPT} --libf2c ${2}"
      evalfailexit "./${THISSCRIPT} --fort77 ${2}"
      ;;

    --bundle-libs)
      evalfailexit "./${THISSCRIPT} --zlib        ${2}"
      evalfailexit "./${THISSCRIPT} --readline    ${2}"
      evalfailexit "./${THISSCRIPT} --pcre        ${2}"
      evalfailexit "./${THISSCRIPT} --hdf5        ${2}"
      evalfailexit "./${THISSCRIPT} --fftw        ${2}"
      evalfailexit "./${THISSCRIPT} --curl        ${2}"
      evalfailexit "./${THISSCRIPT} --glpk        ${2}"
      evalfailexit "./${THISSCRIPT} --qhull       ${2}"
      evalfailexit "./${THISSCRIPT} --suitesparse ${2}"
      ;;

    --bundle-drawing)
      evalfailexit "./${THISSCRIPT} --freetype ${2}"
      evalfailexit "./${THISSCRIPT} --fltk     ${2}"
      evalfailexit "./${THISSCRIPT} --ftgl     ${2}"
      ;;

    --bundle-graphics)
      evalfailexit "./${THISSCRIPT} --png            ${2}"
      evalfailexit "./${THISSCRIPT} --jpeg           ${2}"
      evalfailexit "./${THISSCRIPT} --tiff           ${2}"
      evalfailexit "./${THISSCRIPT} --graphicsmagick ${2}"
      ;;

    --bundle-octave)
      evalfailexit "./${THISSCRIPT} --octave        ${2}"
      evalfailexit "./${THISSCRIPT} --modify_octave ${2}"
      ;;

    --all)
      evalfailexit "./${THISSCRIPT} --bundle-fortran  ${2}"
      evalfailexit "./${THISSCRIPT} --bundle-libs     ${2}"
      evalfailexit "./${THISSCRIPT} --bundle-drawing  ${2}"
      evalfailexit "./${THISSCRIPT} --bundle-graphics ${2}"
      evalfailexit "./${THISSCRIPT} --bundle-octave   ${2}"
      ;;

    *)
      echo "${THISSCRIPT}: Unknown input argument ${1}"
      exit 1
      ;;
  esac
fi
