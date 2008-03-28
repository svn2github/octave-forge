#!/usr/bin/sh

#  BUILD DEPENDENCIES FOR OCTAVE 3.0.0/MINGW32
#
#  This script successivly builds the dependencies 
#  required for a Octave 3.0.0 build
#
#  This script requires a working MSYS 1.0.10/MSYSDTK environment
#
#  09-dec-2007 Benjamin Lindner (lindnerb@users.sourceforge.net) - creation

if [ -z "$1" ]; then ACTION=all; else ACTION="$*"; fi
echo ACTION = "${ACTION}";

# Version-Release of dependency 
VER_ZLIB=1.2.3-2
VER_BLAS=2
VER_CBLAS=2
VER_LAPACK=3.1.1-2
VER_GLOB=1.0-2
VER_NCURSES=5.6-2
VER_READLINE=5.2-2
VER_REGEX=2.5.1-2
VER_SUITESPARSE=3.0.0-2
VER_PCRE=7.5-2
VER_FFTW3=3.1.2-2
VER_GMP=4.2.1-2
VER_GLPK=4.17-2
VER_GSL=1.10-2
VER_LIBPNG=1.2.24-2
VER_LIBJPEG=6b-2
VER_LIBTIFF=3.8.2-2
VER_HDF5=1.6.5-2
VER_LESS=406-2
VER_SED=4.1.5-2
VER_CURL=7.17.1-2
VER_QHULL=2003.1-2

# Mind the dependency of libraries:
# CBLAS depends on BLAS
# LAPACK depends on BLAS
# GLPK dependes on GMP
# SUITESPARSE depends on BLAS and LAPACK
# GSL depends on BLAS
# SED depends on REGEX
# LESS depends on PCRE
# READLINE depends on NCURSES
# many packages depend on ZLIB

( cd zlib && build-${VER_ZLIB}.sh ${ACTION} );
( cd blas && build-${VER_BLAS}.sh ${ACTION} );
( cd cblas && build-${VER_CBLAS}.sh ${ACTION} );
( cd lapack && build-${VER_LAPACK}.sh ${ACTION} );
( cd glob && build-${VER_GLOB}.sh ${ACTION} );
( cd libncurses && build-${VER_NCURSES}.sh ${ACTION} );
( cd readline && build-${VER_READLINE}.sh ${ACTION} );
( cd regex && build-${VER_REGEX}.sh ${ACTION} );
( cd suitesparse && build-${VER_SUITESPARSE}.sh ${ACTION} );
( cd pcre && build-${VER_PCRE}.sh ${ACTION} );
( cd fftw3 && build-${VER_FFTW3}.sh ${ACTION} );
( cd gmp && build-${VER_GMP}.sh ${ACTION} );
( cd glpk && build-${VER_GLPK}.sh ${ACTION} );
( cd gsl && build-${VER_GSL}.sh ${ACTION} );
( cd libpng && build-${VER_LIBPNG}.sh ${ACTION} );
( cd libjpeg && build-${VER_LIBJPEG}.sh ${ACTION} );
( cd libtiff && build-${VER_LIBTIFF}.sh ${ACTION} );
( cd hdf5 && build-${VER_HDF5}.sh ${ACTION} );
( cd less && build-${VER_LESS}.sh ${ACTION} );
( cd sed && build-${VER_SED}.sh ${ACTION} );
( cd curl && build-${VER_CURL}.sh ${ACTION} );
( cd qhull && build-${VER_QHULL}.sh ${ACTION} );
