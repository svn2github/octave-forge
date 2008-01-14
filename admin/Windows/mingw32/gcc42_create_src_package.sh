#! /usr/bin/sh

TAR=tar
TARFLAGS=-cvjf
EXT=.tar.bz2

source gcc42_pkg_version.sh

# Version an release of TAG
VER=${PKG_VER}
REL=${PKG_REL}

SRCPKGDIR=srcpkg/${VER}-${REL}

packit()
{
(
   if [ -z $1 ]; then return; else PKG=$1; fi
   if [ -z $2 ]; then VER=""; else VER="-$2"; fi
   if [ -z $3 ]; then REL=""; else REL="-$3"; fi
   shift; shift; shift
   
   D=${PKG}${VER}${REL}.patch
   if [ -n -e ${D} ]; then DF=""; else DF=$D; fi
   
   T=${PKG}${VER}${REL}-src${EXT}
   
   ( cd ${PKG} && ${TAR} ${TARFLAGS} ${T}  build${VER}${REL}.sh ${DF} $* && mv ${T} ../${SRCPKGDIR} )
)
}

mkdir -p ${SRCPKGDIR}

# The common building scripts...
BUILD_SCRIPTS="\
	gcc42_build_deps.sh \
	gcc42_build_octave.sh \
	gcc42_build_tools.sh \
	gcc42_common.sh \
	gcc42_create_package.sh \
	gcc42_install_deps.sh \
	gcc42_install_octave.sh \
	gcc42_install_tools.sh \
	gcc42_create_src_packages.sh \
	gcc42_pkg_version.sh \
	copy-if-changed.sh"

${TAR} ${TARFLAGS} ${SRCPKGDIR}/build-scripts-${VER}-${REL}${EXT} ${BUILD_SCRIPTS}

# The dependency libraries
#
#  PACKIT <DIR> <VERSION> <RELEASE> <SRC-FILE-NAME>
#
packit	"blas"	""	2	"blas.tgz"
packit	"cblas"	""	2	"cblas.tgz"
packit	"fftw3"	3.1.2	2	"fftw-3.1.2.tar.gz"
packit	"glob"	1.0	2	"glob-1.0.tar.bz2"
packit	"glpk"	4.17	2	"glpk-4.17.tar.gz"
packit	"gmp"	4.2.1	2	"gmp-4.2.1.tar.bz2"
packit	"gsl"	1.9	2	"gsl-1.9.tar.gz"
packit	"hdf5"	1.6.5	2	"hdf5-1.6.5.tar.gz"
packit	"lapack"	3.1.1	2	"lapack-lite-3.1.1.tgz"
packit	"libjpeg"	6b	2	"jpegsrc.v6b.tar.gz" "jpeg-6b-2.patch"
packit	"libpng"	1.2.18	2	"libpng-1.2.18.tar.bz2"
packit	"libtiff"	3.8.2	2	"tiff-3.8.2.tar.gz" "tiff-3.8.2-2.patch"
packit	"pcre"	7.2	1	"pcre-7.2.tar.bz2"
packit	"readline"	5.2	2	"readline-5.2.tar.gz"
packit	"regex"	2.5.1	2	"mingw-libgnurx-2.5.1-src.tar.gz"
packit	"suitesparse"	3.0.0	2	"SuiteSparse-3.0.0.tar.gz"
packit	"zlib"	1.2.3	2	"zlib-1.2.3.tar.bz2"
packit	"curl"	7.17.1	2	"curl-7.17.1.tar.bz2"
packit	"qhull"	2003.1	2	"qhull-2003.1-src.tgz"

# Octave itself
packit	"octave"	2.9.17	2	"octave-2.9.17.tar.bz2"

# Additional Tools 
packit	"sed"	4.1.5	2	"sed-4.1.5.tar.gz"
packit	"less"	406	2	"less-406.tar.gz"
