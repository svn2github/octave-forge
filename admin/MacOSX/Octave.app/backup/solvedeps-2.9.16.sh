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
# along with this program; If not, see <http://www.gnu.org/licenses/>.

# You're not free in choosing another compiler than XCode's - so this
# is set up automatically. By default we use f2c that is compiled as
# the first program if used input argument '--all'.
THISSCRIPT=solvedeps-2.9.16.sh

# This is the name of the file that is used for displaying outputs
# while configuring, compiling and installing. Use /dev/stdout to
# display all messages in the running terminal.
MSGFILE=/dev/stdout # /tmp/message.log # /tmp/message.log /dev/stdout

# This is the name of the directory where all dependencies are
# installed. The string "-ppc" or "-i386" is added to the end of the
# given pathname, eg. /tmp/abc becomes /tmp/abc-pcc etc.
INSTDIR=/tmp/dependencies

# You can try to set up gfortran instead of f2c but it is very
# difficult to do that. A good starting point for this would be
# eg. http://gcc.gnu.org/wiki/GFortranBinariesMacOS.
F2CPACK=http://www.llnl.gov/casc/Overture/henshaw/software/f2c.tar.gz
F2CDIFF=./f2c-19991025.diff

#http://ftp.de.debian.org/debian/pool/main/f/f2c/f2c_20050501.orig.tar.gz
#http://ftp.de.debian.org/debian/pool/main/f/f2c/f2c_20050501-1.diff.gz
#http://ftp.de.debian.org/debian/pool/main/libf/libf2c2/libf2c2_20050501.orig.tar.gz
#http://ftp.de.debian.org/debian/pool/main/libf/libf2c2/libf2c2_20050501-2.diff.gz

FORT77PACK=http://ftp.de.debian.org/debian/pool/main/f/fort77/fort77_1.15.orig.tar.gz
FORT77DIFF=http://ftp.de.debian.org/debian/pool/main/f/fort77/fort77_1.15-7.diff.gz

READLINEPACK=http://ftp.gnu.org/pub/gnu/readline/readline-5.2.tar.gz

PCREPACK=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-7.0.tar.gz
#ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-7.4.tar.gz

LIBZPACK=ftp://ftp.hdfgroup.org/lib-external/zlib/1.2/src/zlib-1.2.1.tar.gz

HDF5PACK=http://ftp.debian.org/debian/pool/main/h/hdf5/hdf5_1.6.5.orig.tar.gz
HDF5DIFF=http://ftp.debian.org/debian/pool/main/h/hdf5/hdf5_1.6.5-5.diff.gz

FFTWPACK=http://ftp.debian.org/debian/pool/main/f/fftw3/fftw3_3.1.2.orig.tar.gz
FFTWDIFF=http://ftp.debian.org/debian/pool/main/f/fftw3/fftw3_3.1.2-2.diff.gz

CURLPACK=http://curl.haxx.se/download/curl-7.17.0.tar.gz

GLPKPACK=http://ftp.gnu.org/gnu/glpk/glpk-4.17.tar.gz
#http://ftp.gnu.org/gnu/glpk/glpk-4.22.tar.gz

QHULLPACK=http://www.qhull.org/download/qhull-2003.1.tar.gz

SPARSEPACK=http://www.cise.ufl.edu/research/sparse/SuiteSparse/SuiteSparse-3.0.0.tar.gz
SPARSEDIFF=./SuiteSparse-3.0.0.diff

OCTAVEPACK=ftp://ftp.octave.org/pub/octave/octave-2.9.16.tar.gz
OCTAVEDIFF=./octave-2.9.16.diff

##########################################################################
#####                Don't modify anything downwards here            #####
##########################################################################

# Function:    evalfailexit
# Input args:  ${1} is the string that has to be evaluated
#              ${MSGFILE} is used for the output of messages
# Output args: -
# Description: Evaluates the ${1} string, prints a message and exits on fail
evalfailexit() {
  if ( ! eval "${1} 2>&1 >>${MSGFILE}" ); then
    echo "${THISSCRIPT}: Building Octave.app has failed !!"
    echo "${THISSCRIPT}: The command that failed was: ${1}"
    exit 1
  fi
}

# Function:    getsource
# Input args:  ${1} is the web adress for the file that is downloaded
# Output args: -
# Description: Downloads the source file that is given as ${1}
getsource() {
  # Check if we do already have downloaded the ${1}.* file
  local vfile=${1##*/} # echo ${vfile}
  if [ ! -f ${vfile} ]; then
    echo "${THISSCRIPT}: Downloading \"${vfile}\" ..."
    evalfailexit "/usr/bin/curl -s -S ${1} -o ${vfile}"
  fi
}

# Function:    unpack
# Input args:  ${1} is the name of the file that has to be extracted
# Output args: -
# Description: Extracts the source file that is given as ${1}
unpack () {
  if [ ${1##*.tar.} == "gz" ]; then
    # We really do know that ${1}.tar.gz extracts to ${1}
    vlocal=${1%.tar.gz}
    if [ ! -d ${vlocal} ]; then
      echo "${THISSCRIPT}: Extracting \"${1}\" ..."
      evalfailexit "tar -xzf ${1}"
    fi
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
  evalfailexit "./configure ${2}"
  echo "${THISSCRIPT}: Making \"${1}\" ..."
  evalfailexit "make"
  echo "${THISSCRIPT}: Installing \"${1}\" ..."
  evalfailexit "make install"
}

##########################################################################
#####         Functions for building the Octave dependencies         #####
##########################################################################

create_f2c () {
  local vf2cpack=${F2CPACK##*/}       # echo ${vf2cpack}
  local vf2cfile=${vf2cpack%.tar.gz*} # echo ${vf2cfile}
  local vf2cdiff=${F2CDIFF##*/}       # echo ${vf2cdiff}
  getsource ${F2CPACK}
  unpack ${vf2cpack}

  echo "${THISSCRIPT}: Creating installation directories ..."
  evalfailexit "install -d ${INSTDIR}{,/bin,/lib,/include}"

  echo "${THISSCRIPT}: Applying the patch ${vf2cdiff} ..."
  evalfailexit "patch -p0 < ${vf2cdiff}"

  export CC=${GCC}
  export CFLAGS=${GCCFLAGS}
  export LDFLAGS=${LDFLAGS}
  export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} 

  echo "${THISSCRIPT}: Making ${vf2cfile}/src ..."
  cd ${vf2cfile}/src
  evalfailexit "${MAKE}"
  evalfailexit "mv f2c ${INSTDIR}/bin"

  echo "${THISSCRIPT}: Making ${vf2cfile}/libf2c ..."
  cd ../libf2c
  evalfailexit "${MAKE}"
  evalfailexit "mv f2c.h ${INSTDIR}/include"
  evalfailexit "mv libf2c.a ${INSTDIR}/lib"
}

create_fort77 () {

  local vfort77pack=${FORT77PACK##*/}       # echo ${vfort77pack}
  local vfort77file=${vfort77pack%.tar.gz*} # echo ${vfort77file}
  local vfort77diff=${FORT77DIFF##*/}       # echo ${vfort77diff}
  local vdiffname=${vfort77diff%.gz*}       # echo ${vdiffname}
  local vdirname=`echo ${vfort77file} | sed "s/_/-/g"`

  getsource ${FORT77PACK}
  unpack ${vfort77pack}
  getsource ${FORT77DIFF}
  echo "${THISSCRIPT}: Extracting ${vfort77diff} ..."
  evalfailexit "rm -rf ${vdiffname} && gunzip ${vfort77diff}"
  echo "${THISSCRIPT}: Applying patch ${vdiffname} ..."
  evalfailexit "patch -p0 < ${vdiffname}"

  cd ${vdirname}
  echo "${THISSCRIPT}: Configuring ${vfort77file} ..."
  export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} 
  evalfailexit "./configure"

  echo "${THISSCRIPT}: Removing special strings in ${vfort77file%_*} ..."
  sed -e "s:${INSTDIR}/bin/::g" -i.orig fort77

  echo "${THISSCRIPT}: Installing ${vfort77file%_*} ..."
  evalfailexit "mv fort77 ${INSTDIR}/bin"
}

create_readline () {
  local vreadpack=${READLINEPACK##*/}   # echo ${vreadpack}
  local vreadfile=${vreadpack%.tar.gz*} # echo ${vfilename}

  getsource ${READLINEPACK}
  unpack ${vreadpack}
  cd ${vreadfile}
  export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} 
  confmakeinst "${vreadfile}" "${1}"
}

create_pcre () {
  local vpcrepack=${PCREPACK##*/}       # echo ${vpcrepack}
  local vpcrefile=${vpcrepack%.tar.gz*} # echo ${vpcrefile}

  getsource ${PCREPACK}
  unpack ${vpcrepack}
  cd ${vpcrefile}
  export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} 
  confmakeinst "${vpcrefile}" "${1}"
}

create_libz () {

# The link /Developer/SDKs/MacOSX10.3.9.sdk/usr/lib/libz.dylib has
# to be removed, otherwise the SDK internal libz is found and this
# results in a bug.

  local vlibzpack=${LIBZPACK##*/}       # echo ${vlibzpack}
  local vlibzfile=${vlibzpack%.tar.gz*} # echo ${vlibzfile}

  getsource ${LIBZPACK}
  unpack ${vlibzpack}

  cd ${vlibzfile}
  export CC="${GCC} ${ARCH} ${OPTFLAGS}"
  export CFLAGS=${GCCFLAGS}
  export PREFIX=${INSTDIR}

  echo "${THISSCRIPT}: Configuring \"${vlibzfile}\" ..."
  export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} 
  evalfailexit "./configure --prefix=${INSTDIR}"
  echo "${THISSCRIPT}: Making static \"${vlibzfile}\" ..."
  evalfailexit "make"
#  echo "${THISSCRIPT}: Configuring \"${vlibzfile}\" ..."
#  export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} 
#  evalfailexit "./configure --shared --prefix=${INSTDIR}"
#  echo "${THISSCRIPT}: Making shared \"${vlibzfile}\" ..."
#  evalfailexit "make"

  echo "${THISSCRIPT}: Make extra-install ${vlibzfile} ..."
  evalfailexit "install -c -S libz.a ${INSTDIR}/lib"
#  evalfailexit "install -c -S libz.1.2.1.dylib ${INSTDIR}/lib"
#  evalfailexit "ln -sfv ${INSTDIR}/lib/libz.1.2.1.dylib ${INSTDIR}/lib/libz.1.dylib"
#  evalfailexit "ln -sfv ${INSTDIR}/lib/libz.1.dylib ${INSTDIR}/lib/libz.dylib"
  evalfailexit "install -c -S crc32.h inffast.h inflate.h trees.h zutil.h ${INSTDIR}/include"
  evalfailexit "install -c -S deflate.h inffixed.h inftrees.h zconf.h zlib.h ${INSTDIR}/include"
}

create_hdf5 () {

# CF. http://www.llnl.gov/visit/1.6/BUILD_NOTES_MacOSX about building
# the hdf5 library for MacOSX - it fails but it is already enough when
# compilation fails. Also "make -j 2" may fails with this package if
# cross-compiled.

  local vhdf5pack=${HDF5PACK##*/}            # echo ${vhdf5pack}
  local vhdf5file=${vhdf5pack%.orig.tar.gz*} # echo ${vhdf5file}
  local vhdf5diff=${HDF5DIFF##*/}            # echo ${vhdf5diff}
  local vdiffname=${vhdf5diff%.gz*}          # echo ${vdiffname}
  local vdirname=`echo ${vhdf5file} | sed "s/_/-/g"`

  getsource ${HDF5PACK}
  unpack ${vhdf5pack}
  getsource ${HDF5DIFF}
  echo "${THISSCRIPT}: Extracting ${vhdf5diff} ..."
  evalfailexit "rm -rf ${vdiffname} && gunzip ${vhdf5diff}"
  echo "${THISSCRIPT}: Applying patch ${vdiffname} ..."
  evalfailexit "patch -p0 < ${vdiffname}"

  cd ${vdirname}
  echo "${THISSCRIPT}: Configuring ${vhdf5file} ..."
  evalfailexit "autoreconf"
  export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} 
  confmakeinst "${vhdf5file}" "CFLAGS=\"${ARCH} ${OPTFLAGS} ${GCCFLAGS}\" \
    CPPFLAGS=\"-I${INCPATH}\" --prefix=${INSTDIR} --disable-cxx"
#  confmakeinst "${vhdf5file}" "CFLAGS=\"${OPTFLAGS} ${ARCH} ${GCCFLAGS}\" --prefix=${INSTDIR} --disable-cxx"
#  confmakeinst "${vhdf5file}" "--prefix=${INSTDIR} --disable-cxx"
}

create_fftw () {
  local vfftwpack=${FFTWPACK##*/}            # echo ${vfftwpack}
  local vfftwfile=${vfftwpack%.orig.tar.gz*} # echo ${vfilename}
  local vfftwdiff=${FFTWDIFF##*/}            # echo ${vfftwdiff}
  local vdiffname=${vfftwdiff%.gz*}          # echo ${vdiffname}
  local vdirname=`echo ${vfftwfile} | sed "s/_/-/g"`

  getsource ${FFTWPACK}
  unpack ${vfftwpack}
  getsource ${FFTWDIFF}
  evalfailexit "mv fftw-3.1.2 fftw3-3.1.2"
  echo "${THISSCRIPT}: Extracting ${vfftwdiff} ..."
  evalfailexit "rm -rf ${vdiffname} && gunzip ${vfftwdiff}"
  echo "${THISSCRIPT}: Applying patch ${vdiffname} ..."
  evalfailexit "patch -p0 < ${vdiffname}"

  cd ${vdirname}
  export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} 
  confmakeinst "${vdirname}" "${1} --enable-shared"
  echo "${THISSCRIPT}: Make extra-install ${vfftwfile} ..."
}

create_curl () {
  local vcurlpack=${CURLPACK##*/}       # echo ${vcurlpack}
  local vcurlfile=${vcurlpack%.tar.gz*} # echo ${vcurlfile}

  getsource ${CURLPACK}
  unpack ${vcurlpack}
  cd ${vcurlfile}
  export DYLD_LIBRARY_PATH="${LIBPATH}:${DYLD_LIBRARY_PATH}"
  export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} 
  confmakeinst "${vcurlfile}" "${1}"
}

create_glpk () {
  local vglpkpack=${GLPKPACK##*/}       # echo ${vglpkpack}
  local vglpkfile=${vglpkpack%.tar.gz*} # echo ${vglpkfile}

  getsource ${GLPKPACK}
  unpack ${vglpkpack}
  cd ${vglpkfile}
  export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} 
  confmakeinst "${vglpkfile}" "${1}"
}

create_qhull () {
  local vqhullpack=${QHULLPACK##*/}       # echo ${vqhullpack}
  local vqhullfile=${vqhullpack%.tar.gz*} # echo ${vqhullfile}

  getsource ${QHULLPACK}
  unpack ${vqhullpack}
  cd ${vqhullfile}
  QHCC="${GCC}" # QHCC="gcc ${ARCH}"
#  echo confmakeinst "${vqhullfile}" "CC=\"${QHCC}\" ${1}"
  export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} 
  confmakeinst "${vqhullfile}" "CC=\"${QHCC}\" ${1}"
}

create_sparse() {
  local vsparsepack=${SPARSEPACK##*/}       # echo ${vsparsepack}
  local vsparsefile=${vsparsepack%.tar.gz*} # echo ${vsparsefile}
  local vsparsediff=${SPARSEDIFF##*/}       # echo ${vsparsediff}

  getsource ${SPARSEPACK}
  unpack ${vsparsepack}

  export CC="${GCC}" # OPTFLAGS INCLUDED
  export CFLAGS="${GCCFLAGS} -fno-common -no-cpp-precomp -fexceptions -D_POSIX_C_SOURCE -D__NOEXTENSIONS__ -DNPARTITION"
  export PREFIX=${INSTDIR}
  export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} 

  echo "${THISSCRIPT}: Applying patch ${vsparsediff} ..."
  evalfailexit "patch -p0 < ${vsparsediff}"

  evalfailexit "mv SuiteSparse ${vsparsefile}"
  cd ${vsparsefile}
  evalfailexit "make"
  cd CXSparse
  evalfailexit "make"
  cd ..

  echo "${THISSCRIPT}: Checking for target directories ..."
  evalfailexit "install -d ${INSTDIR}{,/bin,/lib,/include}"
  evalfailexit "install -c -S UFconfig/UFconfig.h ${INSTDIR}/include"
 
  echo "${THISSCRIPT}: Installing UMFPACK files in ${INSTDIR}"
  evalfailexit "install -c -S UMFPACK/Include/*.h ${INSTDIR}/include"
  evalfailexit "install -c -S UMFPACK/Lib/libumfpack.a ${INSTDIR}/lib"
  evalfailexit "ranlib ${INSTDIR}/lib/libumfpack.a"

  echo "${THISSCRIPT}: Installing AMD files in ${INSTDIR}"
  evalfailexit "install -c -S AMD/Include/*.h ${INSTDIR}/include"
  evalfailexit "install -c -S AMD/Lib/libamd.a ${INSTDIR}/lib"
  evalfailexit "ranlib ${INSTDIR}/lib/libamd.a"

  echo "${THISSCRIPT}: Installing CAMD files in ${INSTDIR}"
  evalfailexit "install -c -S CAMD/Include/*.h ${INSTDIR}/include"
  evalfailexit "install -c -S CAMD/Lib/libcamd.a ${INSTDIR}/lib"
  evalfailexit "ranlib ${INSTDIR}/lib/libcamd.a"

  echo "${THISSCRIPT}: Installing COLAMD files in ${INSTDIR}"
  evalfailexit "install -c -S COLAMD/Include/*.h ${INSTDIR}/include"
  evalfailexit "install -c -S COLAMD/Lib/libcolamd.a ${INSTDIR}/lib"
  evalfailexit "ranlib ${INSTDIR}/lib/libcolamd.a"

  echo "${THISSCRIPT}: Installing CCOLAMD files in ${INSTDIR}"
  evalfailexit "install -c -S CCOLAMD/Include/*.h ${INSTDIR}/include"
  evalfailexit "install -c -S CCOLAMD/Lib/libccolamd.a ${INSTDIR}/lib"
  evalfailexit "ranlib ${INSTDIR}/lib/libccolamd.a"

  echo "${THISSCRIPT}: Installing CXSPARSE files in ${INSTDIR}"
  evalfailexit "install -c -S CXSparse/Include/*.h ${INSTDIR}/include"
  evalfailexit "install -c -S CXSparse/Lib/libcxsparse.a ${INSTDIR}/lib"
  evalfailexit "ranlib ${INSTDIR}/lib/libcxsparse.a"

  echo "${THISSCRIPT}: Installing CHOLMOD files in ${INSTDIR}"
  evalfailexit "install -c -S CHOLMOD/Include/*h ${INSTDIR}/include"
  evalfailexit "install -c -S CHOLMOD/Lib/libcholmod.a ${INSTDIR}/lib"
  evalfailexit "ranlib ${INSTDIR}/lib/libcholmod.a"
}

create_octave() {
  local voctavepack=${OCTAVEPACK##*/}       # echo ${voctavepack}
  local voctavefile=${voctavepack%.tar.gz*} # echo ${voctavefile}
  local voctavediff=${OCTAVEDIFF##*/}       # echo ${voctavediff}
  local voctversion=${voctavefile##*-}      # echo ${voctversion}

  getsource ${OCTAVEPACK}
  unpack ${voctavepack}

  echo "${THISSCRIPT}: Applying patch ${voctavediff} ..."
  evalfailexit "patch -p0 < ${voctavediff}"

  echo "${THISSCRIPT}: Calling Octave's autogen.sh ..."
  cd ${voctavefile}
  evalfailexit "./autogen.sh"
  export DYLD_LIBRARY_PATH="${LIBPATH}:${DYLD_LIBRARY_PATH}"
  export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} 
#  evalfailexit "make"
#  evalfailexit "./configure ${1}"
  confmakeinst "${voctavefile}" "${1} --enable-shared"
}

modify_octave() {
  local voctavepack=${OCTAVEPACK##*/}       # echo ${voctavepack}
  local voctavefile=${voctavepack%.tar.gz*} # echo ${voctavefile}
  local voctversion=${voctavefile##*-}      # echo ${voctversion}

  echo "${THISSCRIPT}: Removing special strings in mkoctfile-${voctversion} ..."
  sed -e "s:${GCCFLAGS}::g" -e "s:${CPPFLAGS}::g" -e "s:${CXXFLAGS}::g" \
      -e "s:${LDFLAGS}::g" -e "s:${FLIBS}:-lf2c:g" -e "s:${FFLAGS}::g" \
      -e "s:${ARCH}::g" -e "s:${EXTRACONF}::g" \
      -i.orig ${INSTDIR}/bin/mkoctfile-${voctversion}

  echo "${THISSCRIPT}: Removing special strings in octave-bug-${voctversion} ..."
  sed -e "s:${GCCFLAGS}::g" -e "s:${CPPFLAGS}::g" -e "s:${CXXFLAGS}::g" \
      -e "s:${LDFLAGS}::g" -e "s:${FLIBS}:-lf2c:g" -e "s:${FFLAGS}::g" \
      -e "s:${ARCH}::g" -e "s:${EXTRACONF}::g" \
      -i.orig ${INSTDIR}/bin/octave-bug-${voctversion}
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
      LIBPATH=${INSTDIR}/lib

      ARCH="-arch ppc"
      OPTFLAGS="-O3 -ftree-vectorize -mpowerpc -faltivec -maltivec -mabi=altivec"
#      OPTFLAGS="-O3 -ftree-vectorize"
      export MACOSX_DEPLOYMENT_TARGET=10.3

      GCC="gcc ${ARCH} ${OPTFLAGS}"
      CPP="${GCC} -E"
      CXX="g++ ${ARCH} ${OPTFLAGS}"

      GCCFLAGS="-isysroot /Developer/SDKs/MacOSX10.3.9.sdk -I${INCPATH}"
      CPPFLAGS="${GCCFLAGS}"
      CXXFLAGS="${GCCFLAGS}"
      LDFLAGS="-L${LIBPATH} -Wl,-headerpad_max_install_names -Wl,-syslibroot -Wl,/Developer/SDKs/MacOSX10.3.9.sdk"

      F77="fort77 ${OPTFLAGS}"
      FLIBS="-L${LIBPATH} -lf2c"
      FFLAGS="-Wc,-arch -Wc,ppc -Wc,-isysroot -Wc,/Developer/SDKs/MacOSX10.3.9.sdk ${OPTFLAGS} -I${INCPATH}"

      EXTRACONF="--host=powerpc-apple-darwin7.9.1"
      ;;

    --i386)
      INSTDIR=${INSTDIR}-i386
      INCPATH=${INSTDIR}/include
      LIBPATH=${INSTDIR}/lib

      ARCH="-arch i386"
      OPTFLAGS="-O3 -ftree-vectorize -fforce-addr -march=i686 -mfpmath=sse,387 -mieee-fp -msse3 -msse2 -msse -mmmx"
      export MACOSX_DEPLOYMENT_TARGET=10.4

      GCC="gcc ${ARCH} ${OPTFLAGS}"
      CPP="${GCC} -E"
      CXX="g++ ${ARCH} ${OPTFLAGS}"

      GCCFLAGS="-isysroot /Developer/SDKs/MacOSX10.4u.sdk -I${INCPATH}"
      CPPFLAGS="${GCCFLAGS}"
      CXXFLAGS="${GCCFLAGS}"
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

  CONFFLAGS="CC=\"${GCC}\" CPP=\"${CPP}\" CXX=\"${CXX}\" \
             CFLAGS=\"${GCCFLAGS}\" CPPFLAGS=\"${CPPFLAGS}\" CXXFLAGS=\"${CXXFLAGS}\" \
             LDFLAGS=\"${LDFLAGS}\" --prefix=${INSTDIR} ${EXTRACONF} \
             F77=\"${F77}\" FLIBS=\"${FLIBS}\" FFLAGS=\"${FFLAGS}\""

  MAKE="make"
  export PATH="${INSTDIR}/bin:${PATH}"

  case "${1}" in
    --f2c)
      create_f2c "${CONFFLAGS}"
      ;;

    --fort77)
      create_fort77 "${CONFFLAGS}"
      ;;

    --readline)
      create_readline "${CONFFLAGS}"
      ;;

    --pcre)
      create_pcre "${CONFFLAGS}"
      ;;

    --zlib)
      create_libz "${CONFFLAGS}"
      ;;

    --hdf5)
      create_hdf5 "${CONFFLAGS}"
      ;;

    --fftw)
      create_fftw "${CONFFLAGS}"
      ;;

    --curl)
      create_curl "${CONFFLAGS}"
      ;;

    --glpk)
      create_glpk "${CONFFLAGS}"
      ;;

    --qhull)
      create_qhull "${CONFFLAGS}"
      ;;

    --sparse)
      create_sparse "${CONFFLAGS}"
      ;;

    --octave)
      create_octave "${CONFFLAGS}"
      modify_octave "${CONFFLAGS}"
      ;;

    --all)
      # Calling this script again and again to make sure that all
      # settings have been deleted that were set for the library or
      # the binary that has been compiled before...
      ./${THISSCRIPT} --f2c ${2}
      ./${THISSCRIPT} --fort77 ${2}
      ./${THISSCRIPT} --readline ${2}
      ./${THISSCRIPT} --pcre ${2}
      ./${THISSCRIPT} --zlib ${2}
      ./${THISSCRIPT} --hdf5 ${2}
      ./${THISSCRIPT} --fftw ${2}
      ./${THISSCRIPT} --curl ${2}
      ./${THISSCRIPT} --glpk ${2}
      ./${THISSCRIPT} --qhull ${2}
      ./${THISSCRIPT} --sparse ${2}
      ./${THISSCRIPT} --octave ${2}
      ;;

    *)
      echo "${THISSCRIPT}: Unknown input argument ${1}"
      exit 1
      ;;

  esac
fi
