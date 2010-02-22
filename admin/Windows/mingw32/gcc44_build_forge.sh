#!/usr/bin/sh

source gcc44_common.sh
source gcc44_pkg_version.sh

# == current BUGS ==
#
#  VRML 1.0.11 fails with syntax error

# the packages installed
# in the form <package-name>-<version>
FORGEPACK="\
windows-1.0.8 \
java-1.2.6 \
splines-1.0.7 \
msh-1.0.0 \
fpl-1.0.0 \
actuarial-1.1.0 \
general-1.2.0 \
miscellaneous-1.0.9 \
time-1.0.9 \
specfun-1.0.8 \
optim-1.0.10 \
signal-1.0.10 \
audio-1.1.4 \
benchmark-1.1.1 \
bim-1.0.0 \
bioinfo-0.1.2 \
combinatorics-1.0.9 \
communications-1.0.10 \
control-1.0.11 \
data-smoothing-1.2.0 \
econometrics-1.0.8 \
fenv-0.1.0 \
financial-0.3.2 \
fixed-0.7.10 \
ga-0.9.7 \
generate_html-0.1.2 \
gnuplot-1.0.1 \
gpc-0.1.7 \
gsl-1.0.8 \
ident-1.0.7 \
image-1.0.10 \
informationtheory-0.1.8 \
integration-1.0.7 \
io-1.0.10 \
irsa-1.0.7 \
jhandles-0.3.5 \
linear-algebra-1.0.8 \
mapping-1.0.7 \
missing-functions-1.0.2 \
nlwing2-1.1.1 \
nnet-0.1.10 \
nurbs-1.0.3 \
ocs-0.0.4 \
oct2mat-1.0.7 \
octcdf-1.0.17 \
octgpr-1.1.5 \
odebvp-1.0.6 \
odepkg-0.6.10 \
optiminterp-0.3.2 \
outliers-0.13.9 \
physicalconstants-0.1.7 \
plot-1.0.7 \
quaternion-1.0.0 \
simp-1.1.0 \
sockets-1.0.5 \
special-matrix-1.0.7 \
spline-gcvspl-1.0.8 \
statistics-1.0.9 \
strings-1.0.7 \
struct-1.0.7 \
symband-1.0.10 \
symbolic-1.0.9 \
video-1.0.2 \
zenity-0.5.7 \
"


# OPTIM depends on MISCELLANEOUS
# SIGNAL depends on OPTIM and SPECFUN
# COMMUNICATIONS depends on SIGNAL
# FINANCIAL depends on TIME
# DATA-SMOOTHING depends on OPTIM
# GA depends on COMMUNICATIONS
# IO requires JAVA and WINDOWS
# JHANDLES requires JAVA
# BIM requires FPL and MSH
# MSH depends on SPLINES
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
FORGENAMELISTLOG=forgenamelist.txt

rm -f ${FORGELISTLOG}
rm -f ${FORGENAMELISTLOG}

if [ ! -z "$1" ]; then
   FORGEPACK=$1
fi

echo Installing forge packages for octave ${VER_OCTAVE} > ${FORGELOG}
echo The following packages are installed: >> ${FORGELOG}
for a in ${FORGEPACK}; do
   echo "   $a">>${FORGELOG}
done

for a in $FORGEPACK; do
   # the package under process
   PACK=$a
   PACKNAME=`echo $a | sed -ne "s@^\(.\+\)-\([0-9]\+\.[0-9]\+\.[0-9]\+\)\\$@\1@p"`
   PACKVER=`echo $a | sed -ne "s@^\(.\+\)-\([0-9]\+\.[0-9]\+\.[0-9]\+\)\\$@\2@p"`
   
   if [ -d ${FORGE_M_ROOT}/$PACK -o -d ${FORGE_OCT_ROOT}/$PACK ]; then
      echo Forge Package "${PACK}" is already installed...
      echo Forge Package "${PACK}" is already installed...>>${FORGELOG}
      echo $PACK >> ${FORGELISTLOG}
      echo $PACKNAME >> ${FORGENAMELISTLOG}
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
         if [ -e /tmp/$PACKNAME ]; then rm -rf /tmp/$PACKNAME; fi
         bsdtar x -C /tmp -f ${FORGESRCDIR}/${PACK}.tar.gz
         
         # the patch file to apply 
         PF=`pwd`/${FORGESRCDIR}/${PACK}.patch
         # patch
         if [ -e /tmp/$PACK ]; then
            PACKDIR=$PACK
         else
            if [ -e /tmp/$PACKNAME ]; then
               PACKDIR=$PACKNAME
            else
               echo ERROR The package $PACK unpacks neither into $PACK/ nor $PACKNAME/
               exit 1
            fi
         fi
         
         ( cd /tmp/$PACKDIR && patch -u -p 1 -i $PF )
         
         # call autogen if present (patch might have changed configure.base)
         if [ -e /tmp/$PACKDIR/src/autogen.sh ]; then
            ( cd /tmp/$PACKDIR/src && ./autogen.sh )
         fi
         
         # ... and install from unpacked directory
         ( cd /tmp
           "${PACKAGE_ROOT}/bin/octave.exe" -q -f -H \
           --eval "page_screen_output(0); pkg install -verbose ${AUTO} ${PACKDIR}"
         )
      else
         "${PACKAGE_ROOT}/bin/octave.exe" -q -f -H \
         --eval "page_screen_output(0); pkg install -verbose ${AUTO} ${FORGESRCDIR}\\${PACK}.tar.gz"
      fi
      
      if [ -d ${FORGE_M_ROOT}/$PACK ]; then
         echo Successfully installed $PACK >> ${FORGELOG}
         echo $PACK >> ${FORGELISTLOG}
         echo $PACKNAME >> ${FORGENAMELISTLOG}
      else
         echo ERROR INSTALLING PACKAGE $PACK >> ${FORGELOG}
      fi
      
      if [ -d ${FORGE_OCT_ROOT}/$PACK ]; then
         find ${FORGE_OCT_ROOT}/$PACK -name "*.oct" -exec strip ${STRIP_FLAGS} '{}' \;
      fi
   fi
done
