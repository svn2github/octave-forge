#!/usr/bin/sh

#  BUILD DEPENDENCIES FOR OCTAVE/MINGW32
#  This script successivly builds the dependencies 
#  required for a Octave 3.x build with gcc-4.5.0

if [ -z "$1" ]; then ACTION=all; else ACTION="$*"; fi
echo ACTION = "${ACTION}";

REL=5

VER_ZLIB=1.2.5-$REL

VER_BLAS=$REL
VER_CBLAS=$REL
VER_LAPACK=3.2.1-$REL
VER_ARPACK=96-$REL
VER_QRUPDATE=1.1.1-$REL
VER_SUITESPARSE=3.2.0-$REL

VER_EXPAT=2.0.1-$REL
VER_NCURSES=5.7-$REL
VER_FFTW3=5.7-$REL
VER_PCRE=8.00-$REL

# Mind the dependency of libraries:
# CBLAS depends on BLAS
# LAPACK depends on BLAS
# ARPACK depends on LAPACK and BLAS
# SUITESPARSE depends on BLAS and LAPACK

# GLPK dependes on GMP
# GSL depends on BLAS
# SED depends on REGEX
# LESS depends on PCRE
# READLINE depends on NCURSES
# many packages depend on ZLIB
# LIBFONTCONFIG depends on EXPAT
# LIBGD depends on LIBFREETYPE, LIBFONTCONFIG, LIBJPEG, LIBPNG
# PCRE checks for BZIP2 and READLINE
# WMF depends on FREETYPE and ZLIB
# IMAGEMAGICK depends on BZIP, ZLIB, WMF, JPEG, PNG, FREETYPE
# GINAC depends on CLN and GMP and uses pkg-config


( cd zlib && build-${VER_ZLIB}.sh ${ACTION} );

( cd blas && build-${VER_BLAS}.sh ${ACTION} );
( cd cblas && build-${VER_CBLAS}.sh ${ACTION} );
( cd lapack && build-${VER_LAPACK}.sh ${ACTION} );
( cd arpack && build-${VER_ARPACK}.sh ${ACTION} );
( cd qrupdate && build-${VER_QRUPDATE}.sh ${ACTION} );
( cd suitesparse && build-${VER_SUITESPARSE}.sh ${ACTION} );

( cd expat && build-${VER_EXPAT}.sh ${ACTION} );
( cd ncurses && build-${VER_NCURSES}.sh ${ACTION} );
( cd fftw3 && build-${VER_FFTW3}.sh ${ACTION} );
( cd pcre && build-${VER_PCRE}.sh ${ACTION} );


