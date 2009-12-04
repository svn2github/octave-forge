#!/usr/bin/sh

source gcc44_common.sh
source gcc44_pkg_version.sh

# == current BUGS ==
#
#  VRML 1.0.11 fails with syntax error

# the packages installed
# in the form <package-name>-<version>
FORGEPACK="\
general-1.1.3 \
miscellaneous-1.0.9 \
time-1.0.9 \
specfun-1.0.8 \
optim-1.0.6 \
signal-1.0.10 \
audio-1.1.4 \
benchmark-1.1.1 \
bioinfo-0.1.2 \
combinatorics-1.0.9 \
communications-1.0.10 \
control-1.0.11 \
data-smoothing-1.2.0 \
econometrics-1.0.8 \
financial-0.3.2 \
fixed-0.7.10 \
ga-0.9.7 \
gsl-1.0.8 \
ident-1.0.7 \
image-1.0.10 \
informationtheory-0.1.8 \
io-1.0.9 \
irsa-1.0.7 \
linear-algebra-1.0.8 \
missing-functions-1.0.2 \
nnet-0.1.10 \
octcdf-1.0.13 \
odebvp-1.0.6 \
odepkg-0.6.7 \
optiminterp-0.3.2 \
outliers-0.13.9 \
physicalconstants-0.1.7 \
plot-1.0.7 \
quaternion-1.0.0 \
sockets-1.0.5 \
special-matrix-1.0.7 \
splines-1.0.7 \
statistics-1.0.9 \
strings-1.0.7 \
struct-1.0.7 \
symbolic-1.0.9 \
zenity-0.5.7 \
integration-1.0.7 \
mapping-1.0.7 \
video-1.0.2 \
windows-1.0.8 \
java-1.2.6 \
jhandles-0.3.5 \
"


# OPTIM depends on MISCELLANEOUS
# SIGNAL depends on OPTIM and SPECFUN
# COMMUNICATIONS depends on SIGNAL
# FINANCIAL depends on TIME
# DATA-SMOOTHING depends on OPTIM
# GA depends on COMMUNICATIONS

# ann parallel ftp database 

# FTP requires ftplib
# DATABASE requires sql
# OCTCDF requires netcdf
# VIDEO requires pkg-config, libavcodec
# SYMBOLIC requires GINAC
# OPTIMINTERP requires the fortran libaries in FLIB  <= **DONE!**

#
# Installation directory of Java SDK
#
JAVA_SDK_ROOT="/c/Programs/java/jdk1.6.0_17"

AUTO="-auto"

# path to forge packages source code
FORGESRCDIR='forge'

# installation root path for m-files
FORGE_M_ROOT=${PACKAGE_ROOT}/share/octave/packages/
# installation root path for .oct files
FORGE_OCT_ROOT=${PACKAGE_ROOT}/libexec/octave/packages/

FORGELOG=forge.log
FORGELISTLOG=forgelist.txt

rm -f ${FORGELISTLOG}

echo Installing forge packages for octave ${VER_OCTAVE} > ${FORGELOG}
echo The following packages are installed: >> ${FORGELOG}
for a in ${FORGEPACK}; do
   echo "   $a">>${FORGELOG}
done

for a in $FORGEPACK; do
   # the package under process
   PACK=$a
   
   if [ -d ${FORGE_M_ROOT}/$PACK -o -d ${FORGE_OCT_ROOT}/$PACK ]; then
      echo Forge Package "${PACK}" is already installed...
      echo Forge Package "${PACK}" is already installed...>>${FORGELOG}
      echo $PACK >> ${FORGELISTLOG}
   else
      echo installing package "${PACK}" ...
      
      # special treatment for individual packages...
      case $PACK in
      java-*|jhandles-*)
         # It is necessary to define JAVA_HOME
         JAVA_HOME=$JAVA_SDK_ROOT
         export JAVA_HOME
         # however it is *not* sufficient to have just JAVA_HOME, because
         # the configure script still does not find java, so add JDK to
         # PATH also.
         # This looks like a bug in msys' posix-win-posix translation, because
         # /c/foo/bar here is translated to c:/foo/bar within octave
         # which in turn is *not* re-translated into /c/foo/bar in the 
         # configure script...
         PATH=$JAVA_SDK_ROOT/bin:$PATH
         ;;
      esac
      
      # check if local patch is available
      if [ -e ${FORGESRCDIR}/${PACK}.patch ]; then
         # extract to temporary directory
         if [ -e /tmp/${PACK} ]; then rm -rf /tmp/${PACK}; fi
         bsdtar x -C /tmp -f ${FORGESRCDIR}/${PACK}.tar.gz
         
         # the patch file to apply 
         PF=`pwd`/${FORGESRCDIR}/${PACK}.patch
         # patch
         ( cd /tmp/${PACK} && patch -u -p 1 -i $PF )
         
         # call autogen if present (patch might have changed configure.base)
         if [ -e /tmp/$PACK/src/autogen.sh ]; then
            ( cd /tmp/$PACK/src && ./autogen.sh )
         fi
         
         # ... and install from unpacked directory
         ( cd /tmp
           "${PACKAGE_ROOT}/bin/octave.exe" -q -f -H \
           --eval "page_screen_output(0); pkg install -verbose ${AUTO} ${PACK}"
         )
      else
         "${PACKAGE_ROOT}/bin/octave.exe" -q -f -H \
         --eval "page_screen_output(0); pkg install -verbose ${AUTO} ${FORGESRCDIR}\\${PACK}.tar.gz"
      fi
      
      if [ -d ${FORGE_M_ROOT}/$PACK ]; then
         echo Successfully installed $PACK >> ${FORGELOG}
         echo $PACK >> ${FORGELISTLOG}
      else
         echo ERROR INSTALLING PACKAGE $PACK >> ${FORGELOG}
      fi
      
      if [ -d ${FORGE_OCT_ROOT}/$PACK ]; then
         find ${FORGE_OCT_ROOT}/$PACK -name "*.oct" -exec strip ${STRIP_FLAGS} '{}' \;
      fi
   fi
done
