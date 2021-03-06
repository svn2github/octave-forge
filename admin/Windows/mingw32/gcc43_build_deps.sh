#!/usr/bin/sh

#  BUILD DEPENDENCIES FOR OCTAVE/MINGW32
#
#  This script successivly builds the dependencies 
#  required for a Octave 3.2.x build
#
#  This script requires a MSYS 1.0.11 environment
#
#  It uses TDM's mingw/GCC port, using GCC-TDM-4.3.0-2
#  see http://www.tdragon.net/recentgcc
#
#  04-jun-2009 lindnerb@users.sourceforge.net - add dependencies for octave 3.2
#  08-aug-2008 lindnerb@users.sourceforge.net - creation

if [ -z "$1" ]; then ACTION=all; else ACTION="$*"; fi
echo ACTION = "${ACTION}";

# Version-Release of dependency 
VER_ZLIB=1.2.3-3
VER_BZIP2=1.0.5-3
VER_BLAS=3
VER_CBLAS=3
VER_LAPACK=3.1.1-3
VER_ARPACK=96-3
VER_GLOB=1.0-3
VER_NCURSES=5.6-3
VER_READLINE=5.2-3
VER_REGEX=2.5.1-3
VER_SUITESPARSE=3.2.0-3
VER_QRUPDATE=1.0-3
VER_PCRE=7.8-3
VER_FFTW3=3.2-3
VER_GMP=4.3.1-3
VER_GLPK=4.38-3
VER_GSL=1.11-3
VER_LIBPNG=1.2.32-3
VER_LIBJPEG=6b-3
VER_LIBTIFF=3.8.2-3
VER_HDF5=1.6.7-3
VER_LESS=418-3
VER_SED=4.1.5-3
VER_CURL=7.19.0-3
VER_QHULL=2003.1-3
VER_EXPAT=2.0.1-3
VER_LIBFREETYPE=2.3.7-3
VER_LIBFONTCONFIG=2.6.0-3
VER_LIBGD=2.0.35-3
VER_WMF=0.2.8.4-3
VER_GRAPHICSMAGICK=1.3.5-3

VER_ICONV=1.12-3
VER_GETTEXT=0.17-3
VER_GLIB=2.18.2-3
VER_PKGCONFIG=0.23-3
VER_PIXMAN=0.12.0-3
VER_CAIRO=1.8.2-3
VER_PANGO=1.22.2-3

VER_TEXINFO=4.13a-3

VER_FTGL=2.1.3-rc5-3
VER_FLTK=1.1.9-3

VER_NETCDF=4.0-3
VER_CLN=1.2.2-3
VER_GINAC=1.5.1-3

# Mind the dependency of libraries:
# CBLAS depends on BLAS
# LAPACK depends on BLAS
# ARPACK depends on LAPACK and BLAS
# GLPK dependes on GMP
# SUITESPARSE depends on BLAS and LAPACK
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
( cd bzip2 && build-${VER_BZIP2}.sh ${ACTION} );
( cd blas && build-${VER_BLAS}.sh ${ACTION} );
( cd cblas && build-${VER_CBLAS}.sh ${ACTION} );
( cd lapack && build-${VER_LAPACK}.sh ${ACTION} );
( cd arpack && build-${VER_ARPACK}.sh ${ACTION} );
( cd glob && build-${VER_GLOB}.sh ${ACTION} );
( cd libncurses && build-${VER_NCURSES}.sh ${ACTION} );
( cd readline && build-${VER_READLINE}.sh ${ACTION} );
( cd regex && build-${VER_REGEX}.sh ${ACTION} );
( cd suitesparse && build-${VER_SUITESPARSE}.sh ${ACTION} );
( cd qrupdate && build-${VER_QRUPDATE}.sh ${ACTION} );
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
( cd expat && build-${VER_EXPAT}.sh ${ACTION} );
( cd libfreetype && build-${VER_LIBFREETYPE}.sh ${ACTION} );
( cd libfontconfig && build-${VER_LIBFONTCONFIG}.sh ${ACTION} );
( cd libgd && build-${VER_LIBGD}.sh ${ACTION} );
( cd wmf && build-${VER_WMF}.sh ${ACTION} );
( cd graphicsmagick && build-${VER_GRAPHICSMAGICK}.sh ${ACTION} );

( cd iconv && build-${VER_ICONV}.sh ${ACTION} );
( cd gettext && build-${VER_GETTEXT}.sh ${ACTION} );
( cd glib && build-${VER_GLIB}.sh ${ACTION} );
( cd pkg-config && build-${VER_PKGCONFIG}.sh ${ACTION} );
( cd pixman && build-${VER_PIXMAN}.sh ${ACTION} );
( cd cairo && build-${VER_CAIRO}.sh ${ACTION} );
( cd pango && build-${VER_PANGO}.sh ${ACTION} );

( cd texinfo && build-${VER_TEXINFO}.sh ${ACTION} );

( cd ftgl && build-${VER_FTGL}.sh ${ACTION} );
( cd fltk && build-${VER_FLTK}.sh ${ACTION} );

( cd netcdf && build-${VER_NETCDF}.sh ${ACTION} );
( cd CLN && build-${VER_CLN}.sh ${ACTION} );
( cd ginac && build-${VER_GINAC}.sh ${ACTION} );
