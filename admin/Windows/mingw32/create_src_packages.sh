#! /usr/bin/sh

TAR=tar
TARFLAGS=-cvjf
EXT=.tar.bz2

source pkg_version.sh

# Version an release of TAG
VER=${PKG_VER}
REL=${PKG_REL}

packit()
{
(
   if [ -z $1 ]; then return; else PKG=$1; fi
   if [ -z $2 ]; then VER=""; else VER="-$2"; fi
   if [ -z $3 ]; then REL=""; else REL="-$3"; fi
   shift; shift; shift
   
   D=${PKG}${VER}${REL}.diff
   if [ -n -e ${T} ]; then DF=""; else DF=$D; fi
   
   T=${PKG}${VER}${REL}-src${EXT}
   
   ( cd ${PKG} && ${TAR} ${TARFLAGS} ${T}  build${VER}${REL}.sh ${DF} $* && mv ${T} .. )
)
}


# The common building scripts...
BUILD_SCRIPTS="\
	build_deps.sh \
	build_octave.sh \
	build_tools.sh \
	common.sh \
	create_package.sh \
	install_deps.sh \
	install_octave.sh \
	install_tools.sh \
	create_src_packages.sh \
	pkg_version.sh"

${TAR} ${TARFLAGS} build-scripts-${VER}-${REL}${EXT} ${BUILD_SCRIPTS}

# The dependency libraries
#
#  PACKIT <DIR> <VERSION> <RELEASE> <SRC-FILE-NAME>
#
packit	"blas"	""	1	"blas.tgz"
packit	"cblas"	""	1	"cblas.tgz"
packit	"fftw3"	3.1.2	1	"fftw-3.1.2.tar.gz"
packit	"glob"	1.0	1	"glob-1.0.tar.bz2"
packit	"glpk"	4.17	1	"glpk-4.17.tar.gz"
packit	"gmp"	4.2.1	1	"gmp-4.2.1.tar.bz2"
packit	"gsl"	1.9	1	"gsl-1.9.tar.gz"
packit	"hdf5"	1.6.5	1	"hdf5-1.6.5.tar.gz"
packit	"lapack"	3.1.1	1	"lapack-lite-3.1.1.tgz"
packit	"libjpeg"	6b	1	"jpegsrc.v6b.tar.gz" "jpeg-6b-1.diff"
packit	"libpng"	1.2.18	1	"libpng-1.2.18.tar.bz2"
packit	"libtiff"	3.8.2	1	"tiff-3.8.2.tar.gz" "tiff-3.8.2-1.diff"
packit	"pcre"	7.0	1	"pcre-7.0.tar.bz2"
packit	"readline"	5.2	1	"readline-5.2.tar.gz"
packit	"regex"	2.5.1	1	"mingw-libgnurx-2.5.1-src.tar.gz"
packit	"suitesparse"	2.4.0	1	"SuiteSparse-2.4.0.tar.gz"
packit	"zlib"	1.2.3	1	"zlib-1.2.3.tar.bz2"
packit	"curl"	7.16.4	1	"curl-7.16.4.tar.bz2"

# Octave itself
packit	"octave"	2.9.12	2	"octave-2.9.12.tar.bz2"

# Additional Tools 
packit	"sed"	4.1.5	1	"sed-4.1.5.tar.gz"
packit	"less"	406	1	"less-406.tar.gz"
