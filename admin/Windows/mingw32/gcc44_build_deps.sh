#!/usr/bin/sh

#  BUILD DEPENDENCIES FOR OCTAVE/MINGW32
#
#  This script successivly builds the dependencies 
#  required for a Octave 3.x build with gcc-4.4.0
#
#  This script requires a MSYS 1.0.11 environment
#
#  It uses mingw's GCC-4.4.0
#
#  nn-oct-2009 lindnerb@users.sourceforge.net - creation

if [ -z "$1" ]; then ACTION=all; else ACTION="$*"; fi
echo ACTION = "${ACTION}";

REL=4

# Version-Release of dependency 
VER_ZLIB=1.2.3-$REL

VER_BLAS=$REL
VER_CBLAS=$REL
VER_LAPACK=3.1.1-$REL
VER_ARPACK=96-$REL
VER_QRUPDATE=1.0.1-$REL
VER_SUITESPARSE=3.2.0-$REL

VER_BZIP2=1.0.5-$REL
VER_GLOB=1.0-$REL
VER_NCURSES=5.6-$REL
VER_READLINE=5.2-$REL
VER_REGEX=2.5.1-$REL
VER_PCRE=8.0-$REL
VER_FFTW3=3.2.2-$REL
VER_GMP=4.3.2-$REL
VER_GLPK=4.42-$REL
VER_GSL=1.11-$REL
VER_LIBPNG=1.2.40-$REL
VER_LIBJPEG=7-$REL
VER_LIBTIFF=3.9.2-$REL
VER_HDF5=1.6.7-$REL
VER_LESS=436-$REL

# VER_SED=4.1.5-$REL

VER_CURL=7.19.6-$REL
VER_QHULL=2010.1-$REL
VER_EXPAT=2.0.1-$REL
VER_LIBFREETYPE=2.3.11-$REL
VER_LIBFONTCONFIG=2.8.0-$REL
VER_LIBGD=2.0.36RC1-$REL
VER_WMF=0.2.8.4-$REL
VER_GRAPHICSMAGICK=1.3.7-$REL

VER_ICONV=1.13-$REL
VER_GETTEXT=0.17-$REL
VER_GLIB=2.22.3-$REL
VER_PKGCONFIG=0.23-$REL
VER_PIXMAN=0.17.2-$REL
VER_CAIRO=1.8.8-$REL
VER_PANGO=1.26.2-$REL
VER_WXWIDGETS=2.8.10-$REL

VER_TEXINFO=4.13a-$REL

VER_FTGL=2.1.3-rc5-$REL
VER_FLTK=1.1.10-$REL

VER_NETCDF=4.0-$REL
VER_CLN=1.3.1-$REL
VER_GINAC=1.5.5-$REL
VER_FFMPEG=0.5-$REL
VER_JOGL=1.1.1-$REL
VER_XLSODF=1.0-$REL

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

( cd bzip2 && build-${VER_BZIP2}.sh ${ACTION} );

( cd glob && build-${VER_GLOB}.sh ${ACTION} );
( cd libncurses && build-${VER_NCURSES}.sh ${ACTION} );
( cd readline && build-${VER_READLINE}.sh ${ACTION} );
( cd regex && build-${VER_REGEX}.sh ${ACTION} );
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
# ( cd sed && build-${VER_SED}.sh ${ACTION} );
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
( cd wxwidgets && build-${VER_WXWIDGETS}.sh ${ACTION} );

( cd texinfo && build-${VER_TEXINFO}.sh ${ACTION} );

( cd ftgl && build-${VER_FTGL}.sh ${ACTION} );
( cd fltk && build-${VER_FLTK}.sh ${ACTION} );

( cd netcdf && build-${VER_NETCDF}.sh ${ACTION} );
( cd CLN && build-${VER_CLN}.sh ${ACTION} );
( cd ginac && build-${VER_GINAC}.sh ${ACTION} );
( cd ffmpeg && build-${VER_FFMPEG}.sh ${ACTION} );
( cd jogl && build-${VER_JOGL}.sh ${ACTION} );
( cd xlsodf && build-${VER_XLSODF}.sh ${ACTION} );
