#!/usr/bin/sh

#  BUILD DEPENDENCIES FOR OCTAVE 2.9.12/MINGW32
#
#  This script successivly builds the dependencies 
#  required for a Octave 2.9.12 build
#
#  This script requires a working MSYS 1.0.10/MSYSDTK environment
#
#   05-sep-2007 Benjamin Lindner (lindnerb@users.sourceforge.net) - bugfix LESS and SED versions
# v0.2  08-aug-2007 Benjamin Lindner (lindnerb@users.sourceforge.net) - add LESS 403-1 and SED 4.5.1-1
#  v0.1  28-jun-2007 Benjamin Lindner (lindnerb@users.sourceforge.net)

# Version-Release of dependency 
VER_ZLIB=1.2.3-1
VER_BLAS=1
VER_CBLAS=1
VER_LAPACK=3.1.1-1
VER_GLOB=1.0-1
VER_READLINE=5.2-1
VER_REGEX=2.5.1-1
VER_SUITESPARSE=2.4.0-1
VER_PCRE=7.0-1
VER_FFTW3=3.1.2-1
VER_GMP=4.2.1-1
VER_GLPK=4.17-1
VER_GSL=1.9-1
VER_LIBPNG=1.2.18-1
VER_LIBJPEG=6b-1
VER_LIBTIFF=3.8.2-1
VER_HDF5=1.6.5-1
VER_LESS=406-1
VER_SED=4.1.5-1
VER_CURL=7.16.4-1

# Mind the dependency of libraries:
#  CBLAS depends on BLAS
# LAPACK depends on BLAS
# GLPK dependes on GMP
# SUITESPARSE depends on BLAS and LAPACK
# GSL depends on BLAS
# SED depends on REGEX
# LESS depends on PCRE
# many packaes depend on ZLIB

( cd zlib && build-${VER_ZLIB}.sh all );
( cd blas && build-${VER_BLAS}.sh all );
( cd cblas && build-${VER_CBLAS}.sh all );
( cd lapack && build-${VER_LAPACK}.sh all );
( cd glob && build-${VER_GLOB}.sh all );
( cd readline && build-${VER_READLINE}.sh all );
( cd regex && build-${VER_REGEX}.sh all );
( cd suitesparse && build-${VER_SUITESPARSE}.sh all );
( cd pcre && build-${VER_PCRE}.sh all );
( cd fftw3 && build-${VER_FFTW3}.sh all );
( cd gmp && build-${VER_GMP}.sh all );
( cd glpk && build-${VER_GLPK}.sh all );
( cd gsl && build-${VER_GSL}.sh all );
( cd libpng && build-${VER_LIBPNG}.sh all );
( cd libjpeg && build-${VER_LIBJPEG}.sh all );
( cd libtiff && build-${VER_LIBTIFF}.sh all );
( cd hdf5 && build-${VER_HDF5}.sh all );
( cd less && build-${VER_LESS}.sh all );
( cd sed && build-${VER_SED}.sh all );
( cd curl && build-${VER_CURL}.sh all );
