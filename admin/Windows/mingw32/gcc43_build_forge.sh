#!/usr/bin/sh

source gcc43_common.sh
source gcc43_pkg_version.sh


# the packages installed
# in the form <package-name>-<version>
FORGEPACK="\
general-1.0.7 \
miscellaneous-1.0.7 \
time-1.0.8 \
optim-1.0.4 \
signal-1.0.8 \
audio-1.1.2 \
benchmark-1.0.0 \
bioinfo-0.1.1 \
combinatorics-1.0.7 \
communications-1.0.8 \
control-1.0.7 \
data-smoothing-1.1.1 \
econometrics-1.0.7 \
financial-0.3.0 \
ga-0.9.4 \
gsl-1.0.7 \
ident-1.0.6 \
image-1.0.8 \
informationtheory-0.1.6 \
io-1.0.7 \
irsa-1.0.6 \
linear-algebra-1.0.6 \
missing-functions-1.0.1 \
nnet-0.1.8 \
odebvp-1.0.5 \
odepkg-0.6.4 \
optiminterp-0.3.1 \
outliers-0.13.8 \
physicalconstants-0.1.6 \
plot-1.0.6 \
sockets-1.0.5 \
specfun-1.0.7 \
special-matrix-1.0.6 \
splines-1.0.6 \
statistics-1.0.7 \
strings-1.0.6 \
struct-1.0.6 \
vrml-1.0.7 \
zenity-0.5.6 \
fixed-0.7.8 \
windows-1.0.6 \
mapping-1.0.6 \
integration-1.0.6
"

# OPTIM depends on MISCELLANEOUS
# SIGNAL depends on OPTIM
# COMMUNICATIONS depends on SIGNAL
# FINANCIAL depends on TIME

# ann fixed parallel symbolic video ftp database octcdf

# FTP requires ftplib
# IMAGE should find imagemagick
# DATABASE requires sql
# OCTCDF requires netcdf
# VIDEO requires pkg-config, libavcodec
# SYMBOLIC requires GINAC
# OPTIMINTERP requires the fortran libaries in FLIB  <= **DONE!**
# DATA-SMOOTHING requires OPTIM

AUTO="-auto"

# path to forge packages source code
FORGESRCDIR='forge'

# installation root path for m-files
FORGE_M_ROOT=${PACKAGE_ROOT}/share/octave/packages/
# installation root path for .oct files
FORGE_OCT_ROOT=${PACKAGE_ROOT}/libexec/octave/packages/

FORGELOG=forge.log

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
   else
      echo installing package "${PACK}" ...
      
      "${PACKAGE_ROOT}/bin/octave.exe" -q -f -H --eval "page_screen_output(0); pkg install -verbose ${AUTO} ${FORGESRCDIR}\\${PACK}.tar.gz"
      
      if [ -d ${FORGE_M_ROOT}/$PACK ]; then
         echo Successfully installed $PACK >> ${FORGELOG}
      else
         echo ERROR INSTALLING PACKAGE $PACK >> ${FORGELOG}
      fi
      
      if [ -d ${FORGE_OCT_ROOT}/$PACK ]; then
         find ${FORGE_OCT_ROOT}/$PACK -name "*.oct" -exec strip ${STRIP_FLAGS} '{}' \;
      fi
   fi
done
