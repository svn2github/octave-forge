#!/bin/bash

dir="`pwd`"
ver=${dir##*/}

test "${dir#*/src/cygwin/octave-}" = "$dir" && echo "Expected to be in src/cygwin/octave-2.1.xx instead of $dir" && exit

# May need to hack configure replacing sgemm with dgemm and
# cheev with zheev, so that only need double precision lapack.
# May need to hack libcruft/ranlib/setgmn.f, renaming it to setgmn.f-orig 
# to remove the only single-precision requirement in octave.

base_m='$(prefix)/base/m'
site_m='$(prefix)/site/m'
base_oct='$(prefix)/base/oct'
site_oct='$(prefix)/site/oct'
base_exec='$(prefix)/base/exec'
site_exec='$(prefix)/site/exec'
base_image='$(prefix)/base/imagelib'
site_image='$(prefix)/site/imagelib'
export fcnfiledir="$base_m"
export localapifcnfiledir="$site_m"
export localfcnfiledir="$site_m"
export localverfcnfiledir="$site_m"
export localfcnfilepath="$site_m//"
export octlibdir="$base_exec"
export archlibdir="$base_exec"
export localarchlibdir="$site_exec"
export localverarchlibdir="$site_exec"
export octfiledir="$base_oct"
export localoctfiledir="$site_oct"
export localapioctfiledir="$site_oct"
export localveroctfiledir="$site_oct"
export localoctfilepath="$site_oct//"
export imagedir="$base_image"
export PATH=/opt/$ver/bin:$PATH
export LDFLAGS=-L/opt/$ver/lib 
export CPPFLAGS=-I/opt/$ver/include
export CFLAGS=-O2 
export CXXFLAGS=-O2
$1/configure --enable-shared --disable-static \
    --prefix=/opt/$ver --with-blas=lapack

# correct misconfigurations:
#   it doesn't seem to be detecting multiplot correctly
