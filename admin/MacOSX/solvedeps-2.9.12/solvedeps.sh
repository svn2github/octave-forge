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

# You're not free in choosing another compiler than XCode's - so this
# is set up automatically. By default we use f2c that is compiled as
# the first program if used input argument '--all'.

# This is the name of the file that is used for displaying outputs
# while configuring, compiling and installing. Use /dev/stdout to
# display all messages in the running terminal.
MSGFILE=/dev/stdout #/tmp/message.log # /dev/stdout

# This is the name of the directory where all dependencies are
# installed. The string "-ppc" or "-i386" is added to the end of the
# given pathname, eg. /tmp/abc becomes /tmp/abc-pcc etc.
INSTDIR=/tmp/dependencies

F2CPACK=http://www.llnl.gov/casc/Overture/henshaw/software/f2c.tar.gz
F2CDIFF=./f2c.diff
# You can try to set up gfortran instead of f2c but it is very
# difficult to do that. A good starting point for this would be
# eg. http://gcc.gnu.org/wiki/GFortranBinariesMacOS.

READLINEPACK=http://ftp.gnu.org/pub/gnu/readline/readline-5.2.tar.gz

PCREPACK=ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-7.0.tar.gz

LIBZPACK=ftp://ftp.hdfgroup.org/lib-external/zlib/1.2/src/zlib-1.2.1.tar.gz

HDF5PACK=http://ftp.debian.org/debian/pool/main/h/hdf5/hdf5_1.6.5.orig.tar.gz
HDF5DIFF=http://ftp.debian.org/debian/pool/main/h/hdf5/hdf5_1.6.5-5.diff.gz

FFTWPACK=http://ftp.debian.org/debian/pool/main/f/fftw3/fftw3_3.1.2.orig.tar.gz
FFTWDIFF=http://ftp.debian.org/debian/pool/main/f/fftw3/fftw3_3.1.2-2.diff.gz

CURLPACK=http://curl.haxx.se/download/curl-7.16.2.tar.gz

GLPKPACK=http://ftp.gnu.org/gnu/glpk/glpk-4.17.tar.gz

SPARSEPACK=http://www.cise.ufl.edu/research/sparse/SuiteSparse/SuiteSparse-3.0.0.tar.gz
SPARSEDIFF=./SuiteSparse.diff

OCTAVEPACK=ftp://ftp.octave.org/pub/octave/bleeding-edge/octave-2.9.12.tar.gz
OCTAVEDIFF=./octave-2.9.12.diff

##########################################################################
#####                Don't modify anything downwards here            #####
##########################################################################

# Function:    evalfailexit
# Input args:  ${1} is the string that has to be evaluated
#              ${MSGFILE} is used for output of messages
# Output args: -
# Description: Evaluates the ${1} string, prints a message and exits on fail
evalfailexit() {
  if ( ! eval "${1} 2>&1 >${MSGFILE}" ); then
    echo "buildoctave.sh: Building octave.app has failed"
    echo "The command that failed was"
    echo "  ${1}"
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
        echo "solvedeps.sh: Downloading \"${vfile}\" ..."
        evalfailexit "curl -s -S ${1} -o ${vfile}"
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
            echo "solvedeps.sh: Extracting \"${1}\" ..."
            evalfailexit "tar -xzf ${1}"
        fi
    elif [ ${1##*.} == "dmg" ]; then
        echo "solvedeps.sh: No implementation for \".dmg\" at the moment"
        exit 1
    fi
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

  echo "solvedeps.sh: Creating installation directories ..."
  evalfailexit "install -d ${INSTDIR}{,/bin,/lib,/include}"

  echo "solvedeps.sh: Applying the patch ${vf2cdiff} ..."
  evalfailexit "patch -p0 < ${vf2cdiff}"

  echo "solvedeps.sh: Making ${vf2cfile}/src ..."
  export CC=${CC}; export CFLAGS=${CFLAGS}; export LDFLAGS=${LDFLAGS}

  cd ${vf2cfile}/src
  evalfailexit "${MAKE}"
  evalfailexit "mv f2c ${INSTDIR}/bin"

  echo "solvedeps.sh: Making ${vf2cfile}/libf2c ..."
  cd ../libf2c
  evalfailexit "${MAKE}"
  evalfailexit "mv f2c.h ${INSTDIR}/include"
  evalfailexit "mv libf2c.a ${INSTDIR}/lib"
}

create_readline () {
  local vreadpack=${READLINEPACK##*/}   # echo ${vreadpack}
  local vreadfile=${vreadpack%.tar.gz*} # echo ${vfilename}

  getsource ${READLINEPACK}
  unpack ${vreadpack}
  cd ${vreadfile}
  echo "solvedeps.sh: Configuring ${vreadfile} ..."
  evalfailexit "./configure ${1}"
  echo "solvedeps.sh: Making ${vreadfile} ..."
  evalfailexit "${MAKE}"
  echo "solvedeps.sh: Make install ${vreadfile} ..."
  evalfailexit "make install"
}

create_pcre () {
  local vpcrepack=${PCREPACK##*/}       # echo ${vpcrepack}
  local vpcrefile=${vpcrepack%.tar.gz*} # echo ${vpcrefile}

  getsource ${PCREPACK}
  unpack ${vpcrepack}
  cd ${vpcrefile}
  echo "solvedeps.sh: Configuring ${vpcrefile} ..."
  evalfailexit "./configure ${1}"
  echo "solvedeps.sh: Making ${vpcrefile} ..."
  evalfailexit "${MAKE}"
  echo "solvedeps.sh: Make install ${vpcrefile} ..."
  evalfailexit "make install"
}

create_libz () {
# The link /Developer/SDKs/MacOSX10.3.9.sdk/usr/lib/libz.dylib has
# to be removed, otherwise the SDK internal libz is found and this
# is a bug.
  local vlibzpack=${LIBZPACK##*/}       # echo ${vlibzpack}
  local vlibzfile=${vlibzpack%.tar.gz*} # echo ${vlibzfile}

  getsource ${LIBZPACK}
  unpack ${vlibzpack}

  echo "solvedeps.sh: Configuring ${vlibzfile} ..."
  cd ${vlibzfile}
  export CC=${CC}
  export CFLAGS=${CFLAGS}
  export PREFIX=${INSTDIR}
  evalfailexit "./configure --shared --prefix=${INSTDIR}"
  echo "solvedeps.sh: Making ${vlibzfile} ..."
  evalfailexit "${MAKE}"
  evalfailexit "make install"
  echo "solvedeps.sh: Make install ${vlibzfile} ..."
  evalfailexit "install -c -S libz.a ${INSTDIR}/lib"
  evalfailexit "install -c -S crc32.h inffast.h inflate.h trees.h zutil.h ${INSTDIR}/include"
  evalfailexit "install -c -S deflate.h inffixed.h inftrees.h zconf.h zlib.h ${INSTDIR}/include"
}

create_hdf5 () {
# CF. http://www.llnl.gov/visit/1.6/BUILD_NOTES_MacOSX about building
# the hdf5 library for MacOSX - it fails but it is already enough when
# compilation fails. Also "make -j 2" may fail with this package if
# cross-compiled.
  local vhdf5pack=${HDF5PACK##*/}            # echo ${vhdf5pack}
  local vhdf5file=${vhdf5pack%.orig.tar.gz*} # echo ${vhdf5file}
  local vhdf5diff=${HDF5DIFF##*/}            # echo ${vhdf5diff}
  local vdiffname=${vhdf5diff%.gz*}          # echo ${vdiffname}

  getsource ${HDF5PACK}
  unpack ${vhdf5pack}
  getsource ${HDF5DIFF}
  evalfailexit "gunzip ${vhdf5diff}"
  evalfailexit "patch -p0 < ${vdiffname}"

  cd `echo ${vhdf5file} | sed "s/_/-/g"`
  echo "solvedependencies.sh: Configuring ${vhdf5file} ..."
  export MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} 
  evalfailexit "./configure CFLAGS=\"${CFLAGS}\" --prefix=${INSTDIR} --disable-cxx"
  echo "solvedependencies.sh: Making ${vhdf5file} ..."
  evalfailexit "make"
  echo "solvedependencies.sh: Make install ${vhdf5file} ..."
  evalfailexit "make install"
}

create_fftw () {
  local vfftwpack=${FFTWPACK##*/}            # echo ${vfftwpack}
  local vfftwfile=${vfftwpack%.orig.tar.gz*} # echo ${vfilename}
  local vfftwdiff=${FFTWDIFF##*/}            # echo ${vfftwdiff}
  local vdiffname=${vfftwdiff%.gz*}          # echo ${vdiffname}

  getsource ${FFTWPACK}
  unpack ${vfftwpack}
  getsource ${FFTWDIFF}
  evalfailexit "mv fftw-3.1.2 fftw3-3.1.2"
  evalfailexit "gunzip ${vfftwdiff}"
  evalfailexit "patch -p0 < ${vdiffname}"

  cd `echo ${vfftwfile} | sed "s/_/-/g"`
  echo "solvedeps.sh: Configuring ${vfilename} ..."
  evalfailexit "./configure ${1} --enable-shared"
  echo "solvedeps.sh: Making ${vfilename} ..."
  evalfailexit "${MAKE}"
  echo "solvedeps.sh: Make install ${vfilename} ..."
  evalfailexit "make install"
  cd ..
}

create_curl () {
  local vcurlpack=${CURLPACK##*/}       # echo ${vcurlpack}
  local vcurlfile=${vcurlpack%.tar.gz*} # echo ${vcurlfile}

  getsource ${CURLPACK}
  unpack ${vcurlpack}
  cd ${vcurlfile}
  echo "solvedeps.sh: Configuring ${vcurlfile} ..."
  evalfailexit "./configure ${1}"
  echo "solvedeps.sh: Making ${vcurlfile} ..."
  evalfailexit "${MAKE}"
  echo "solvedeps.sh: Make install ${vcurlfile} ..."
  evalfailexit "make install"
}

create_glpk () {
  local vglpkpack=${GLPKPACK##*/}       # echo ${vglpkpack}
  local vglpkfile=${vglpkpack%.tar.gz*} # echo ${vglpkfile}

  getsource ${GLPKPACK}
  unpack ${vglpkpack}
  cd ${vglpkfile}
  echo "solvedeps.sh: Configuring ${vglpkfile} ..."
  evalfailexit "./configure ${1}"
  echo "solvedeps.sh: Making ${vglpkfile} ..."
  evalfailexit "${MAKE}"
  echo "solvedeps.sh: Make install ${vglpkfile} ..."
  evalfailexit "make install"
}

create_sparse() {
  local vsparsepack=${SPARSEPACK##*/}       # echo ${vsparsepack}
  local vsparsefile=${vsparsepack%.tar.gz*} # echo ${vsparsefile}
  local vsparsediff=${SPARSEDIFF##*/}       # echo ${vsparsediff}

  getsource ${SPARSEPACK}
  unpack ${vsparsepack}

  export CC="${CC}"
  export CFLAGS="${CFLAGS} -O3 -fno-common -no-cpp-precomp -fexceptions -D_POSIX_C_SOURCE -D__NOEXTENSIONS__ -DNPARTITION"
  export PREFIX=${INSTDIR}

  echo "solvedeps.sh: Applying patch ${vsparsediff} ..."
  evalfailexit "patch -p0 < SuiteSparse.diff"

  evalfailexit "mv SuiteSparse ${vsparsefile}"
  cd ${vsparsefile}
  evalfailexit "make"
  cd CXSparse
  evalfailexit "make"
  cd ..

  echo "solvedeps.sh: Checking for target directories ..."
  evalfailexit "install -d ${INSTDIR}{,/bin,/lib,/include}"
  evalfailexit "install -c -S UFconfig/UFconfig.h ${INSTDIR}/include"
 
  echo "solvedeps.sh: Installing UMFPACK files in ${INSTDIR}"
  evalfailexit "install -c -S UMFPACK/Include/*.h ${INSTDIR}/include"
  evalfailexit "install -c -S UMFPACK/Lib/libumfpack.a ${INSTDIR}/lib"
  evalfailexit "ranlib ${INSTDIR}/lib/libumfpack.a"

  echo "solvedeps.sh: Installing AMD files in ${INSTDIR}"
  evalfailexit "install -c -S AMD/Include/*.h ${INSTDIR}/include"
  evalfailexit "install -c -S AMD/Lib/libamd.a ${INSTDIR}/lib"
  evalfailexit "ranlib ${INSTDIR}/lib/libamd.a"

  echo "solvedeps.sh: Installing CAMD files in ${INSTDIR}"
  evalfailexit "install -c -S CAMD/Include/*.h ${INSTDIR}/include"
  evalfailexit "install -c -S CAMD/Lib/libcamd.a ${INSTDIR}/lib"
  evalfailexit "ranlib ${INSTDIR}/lib/libcamd.a"

  echo "solvedeps.sh: Installing COLAMD files in ${INSTDIR}"
  evalfailexit "install -c -S COLAMD/Include/*.h ${INSTDIR}/include"
  evalfailexit "install -c -S COLAMD/Lib/libcolamd.a ${INSTDIR}/lib"
  evalfailexit "ranlib ${INSTDIR}/lib/libcolamd.a"

  echo "solvedeps.sh: Installing CCOLAMD files in ${INSTDIR}"
  evalfailexit "install -c -S CCOLAMD/Include/*.h ${INSTDIR}/include"
  evalfailexit "install -c -S CCOLAMD/Lib/libccolamd.a ${INSTDIR}/lib"
  evalfailexit "ranlib ${INSTDIR}/lib/libccolamd.a"

  echo "solvedeps.sh: Installing CXSPARSE files in ${INSTDIR}"
  evalfailexit "install -c -S CXSparse/Include/*.h ${INSTDIR}/include"
  evalfailexit "install -c -S CXSparse/Lib/libcxsparse.a ${INSTDIR}/lib"
  evalfailexit "ranlib ${INSTDIR}/lib/libcxsparse.a"

  echo "solvedeps.sh: Installing CHOLMOD files in ${INSTDIR}"
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

  echo "solvedeps.sh: Applying patch ${voctavediff} ..."
  evalfailexit "patch -p0 < ${voctavediff}"

  echo "solvedeps.sh: Calling Octave's autogen.sh ..."
  cd ${voctavefile}
  evalfailexit "./autogen.sh"

  echo "solvedeps.sh: Configuring ${voctavefile} ..."
  evalfailexit "./configure ${1} --enable-shared --with-f2c"
  echo "solvedeps.sh: Making ${voctavefile} ..."
  evalfailexit "${MAKE}"
  echo "solvedeps.sh: Make install ${voctavefile} ..."
  evalfailexit "make install"

  echo "solvedeps.sh: Removing special strings in mkoctfile-${voctversion} ..."
  sed "s:${CFLAGS}::g;s:${LDFLAGS}::g;s:${ARCH}::g" \
    < ${INSTDIR}/bin/mkoctfile-${voctversion} > /tmp/mkoctfile-${voctversion}
  evalfailexit "install -c -S /tmp/mkoctfile-${voctversion} ${INSTDIR}/bin/mkoctfile-${voctversion}"
  evalfailexit "rm -f /tmp/mkoctfile-${voctversion}"

  echo "solvedeps.sh: Removing special strings in octave-bug-${voctversion} ..."
  sed "s:${CFLAGS}::g;s:${LDFLAGS}::g;s:${ARCH}::g" \
    < ${INSTDIR}/bin/octave-bug-${voctversion} > /tmp/octave-bug-${voctversion}
  evalfailexit "install -c -S /tmp/octave-bug-${voctversion} ${INSTDIR}/bin/octave-bug-${voctversion}"
  evalfailexit "rm -f /tmp/octave-bug-${voctversion}"
}

# This is the main bash routine
if [ $# -ne 2 ]; then
    echo "Usage: solvedeps.sh LIBRARY ARCHITECTURE"
    exit 1
else
  case "${2}" in
    --ppc)
      INSTDIR=${INSTDIR}-ppc
      ARCH="-arch ppc"
      BUILDARCH="--host=powerpc-apple-darwin7.9.1"
      MACOSX_DEPLOYMENT_TARGET=10.3

      CC="MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} gcc"
      CXX="MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} g++"
      CPP="MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} cpp"

      CFLAGS="${ARCH} -isysroot /Developer/SDKs/MacOSX10.3.9.sdk -I${INSTDIR}/include"
      CXXFLAGS="${ARCH} -isysroot /Developer/SDKs/MacOSX10.3.9.sdk -I${INSTDIR}/include"
      CPPFLAGS="${ARCH} -isysroot /Developer/SDKs/MacOSX10.3.9.sdk -I${INSTDIR}/include"
      LDFLAGS="${ARCH} -Wl,-headerpad_max_install_names,-syslibroot,/Developer/SDKs/MacOSX10.3.9.sdk -L${INSTDIR}/lib"
      ;;

    --i386)
      INSTDIR=${INSTDIR}-i386
      ARCH="-arch i386"
      BUILDARCH=""
      MACOSX_DEPLOYMENT_TARGET=10.4

      CC="MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} gcc"
      CXX="MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} g++"
      CPP="MACOSX_DEPLOYMENT_TARGET=${MACOSX_DEPLOYMENT_TARGET} cpp"

      CFLAGS="${ARCH} -I${INSTDIR}/include"
      CXXFLAGS="${ARCH} -I${INSTDIR}/include"
      CPPFLAGS="${ARCH} -I${INSTDIR}/include"
      LDFLAGS="${ARCH} -L${INSTDIR}/lib"
      ;;

    *)
      echo "solvedeps.sh: Unknown input argument ${2}"
      exit 1
      ;;

  esac

  # CONFFLAGS="CC=\"${CC}\" CXX=\"${CXX}\" CPP=\"${CPP}\""
  CONFFLAGS="CFLAGS=\"${CFLAGS}\" CPPFLAGS=\"${CPPFLAGS}\""
  CONFFLAGS="${CONFFLAGS} CXXFLAGS=\"${CXXFLAGS}\" LDFLAGS=\"${LDFLAGS}\""
  CONFFLAGS="${CONFFLAGS} --prefix=${INSTDIR} ${BUILDARCH}"

  MAKE="make"
  export PATH="${INSTDIR}/bin:${PATH}"

  case "${1}" in
    --f2c)
      create_f2c "${CONFFLAGS}"
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

    --sparse)
      create_sparse "${CONFFLAGS}"
      ;;

    --octave)
      create_octave "${CONFFLAGS}"
      ;;

    --all)
      # Calling this script again and again to make sure that all
      # settings have been deleted that were set for the library or
      # the binary that has been compiled before...
      ./solvedeps.sh --f2c ${2}
      ./solvedeps.sh --readline ${2}
      ./solvedeps.sh --pcre ${2}
      ./solvedeps.sh --zlib ${2}
      ./solvedeps.sh --hdf5 ${2}
      ./solvedeps.sh --fftw ${2}
      ./solvedeps.sh --curl ${2}
      ./solvedeps.sh --glpk ${2}
      ./solvedeps.sh --sparse ${2}
      ./solvedeps.sh --octave ${2}
      ;;

    *)
      echo "solvedeps.sh: Unknown input argument ${1}"
      exit 1
      ;;

  esac
fi
