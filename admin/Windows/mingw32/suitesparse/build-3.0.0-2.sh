#! /usr/bin/sh

# Name of package
PKG=suitesparse
# Version of Package
VER=3.0.0
# Release of (this patched) package
REL=1
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file
SRCFILE=${PKGVER}.tar.gz
TAR_TYPE=z
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL of source code file
URL="http://www.cise.ufl.edu/research/sparse/SuiteSparse/SuiteSparse-3.0.0.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory Source code is extracted to (relative to TOPDIR)
SRCDIR=${PKG}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig
# Directory the lib is built in
BUILDDIR=${SRCDIR}

# Make file to use
MAKEFILE=""

# Additional DIFF Flags for generating diff file
DIFF_FLAGS="-x *.def"

# Directory to put include files into
INCLUDE_DIR=include/suitesparse

CHOLMOD_INCLUDES="cholmod_core.h cholmod_io64.h cholmod.h cholmod_supernodal.h cholmod_partition.h cholmod_modify.h cholmod_matrixops.h cholmod_internal.h cholmod_config.h cholmod_cholesky.h cholmod_check.h cholmod_blas.h cholmod_complexity.h cholmod_template.h"
UMFPACK_INCLUDES="umfpack.h umfpack_get_lunz.h umfpack_numeric.h umfpack_report_perm.h umfpack_save_symbolic.h umfpack_transpose.h umfpack_col_to_triplet.h umfpack_get_numeric.h umfpack_qsymbolic.h umfpack_report_status.h umfpack_scale.h umfpack_triplet_to_col.h umfpack_defaults.h umfpack_get_symbolic.h umfpack_report_control.h umfpack_report_symbolic.h umfpack_solve.h umfpack_wsolve.h umfpack_free_numeric.h umfpack_global.h umfpack_report_info.h umfpack_report_triplet.h umfpack_symbolic.h umfpack_free_symbolic.h umfpack_load_numeric.h umfpack_report_matrix.h umfpack_report_vector.h umfpack_tictoc.h umfpack_get_determinant.h umfpack_load_symbolic.h umfpack_report_numeric.h umfpack_save_numeric.h umfpack_timer.h"
AMD_INCLUDES="amd.h amd_internal.h"
CAMD_INCLUDES="camd.h camd_internal.h"
COLAMD_INCLUDES="colamd.h"
CCOLAMD_INCLUDES="ccolamd.h"
CXSPARSE_INCLUDES="cs.h"

source ../gcc42_common.sh

build() {
(
  ( cd ${BUILDDIR}/AMD/Lib      && make -f GNUmakefile );
  ( cd ${BUILDDIR}/CAMD/Lib     && make -f GNUmakefile );
  ( cd ${BUILDDIR}/CCOLAMD/Lib  && make );
  ( cd ${BUILDDIR}/COLAMD/Lib   && make );
  ( cd ${BUILDDIR}/CSparse/Lib  && make );
  ( cd ${BUILDDIR}/CXSparse/Lib && make );
  ( cd ${BUILDDIR}/CHOLMOD/Lib  && make );
  ( cd ${BUILDDIR}/UMFPACK/Lib  && make -f GNUmakefile );
)
}

clean() {
(
  ( cd ${BUILDDIR}/AMD/Lib      && make -f GNUmakefile clean );
  ( cd ${BUILDDIR}/CAMD/Lib     && make -f GNUmakefile clean );
  ( cd ${BUILDDIR}/CCOLAMD/Lib  && make clean );
  ( cd ${BUILDDIR}/COLAMD/Lib   && make clean );
  ( cd ${BUILDDIR}/CSparse/Lib  && make clean );
  ( cd ${BUILDDIR}/CXSparse/Lib && make clean );
  ( cd ${BUILDDIR}/CHOLMOD/Lib  && make clean );
  ( cd ${BUILDDIR}/UMFPACK/Lib  && make -f GNUmakefile clean );
)
}

install_lib_core() {
(
   ${CP} ${CP_FLAGS} ${BUILDDIR}/$1/lib/$1.dll ${BINARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/$1/lib/lib$1.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/$1/lib/lib$1.a ${STATICLIBRARY_PATH}
)
}

install_header_core() {
(
  for a in $2; do ${CP} ${CP_FLAGS} ${BUILDDIR}/$1/Include/${a} ${INCLUDE_PATH}; done
)
}

install_pre() { if [ ! -e ${INCLUDE_PATH} ]; then mkdir -p ${INCLUDE_PATH}; fi; }

install()
{
   install_pre
   
   # Install the libs
   install_lib_core amd
   install_lib_core camd
   install_lib_core ccolamd
   install_lib_core colamd
   install_lib_core csparse
   install_lib_core cxsparse
   install_lib_core cholmod
   install_lib_core umfpack
   
   # Install the headers
   install_header_core UMFPACK "${UMFPACK_INCLUDES}"
   install_header_core CHOLMOD "${CHOLMOD_INCLUDES}"
   install_header_core AMD "${AMD_INCLUDES}"
   install_header_core CAMD "${CAMD_INCLUDES}"
   install_header_core COLAMD "${COLAMD_INCLUDES}"
   install_header_core CCOLAMD "${CCOLAMD_INCLUDES}"
   install_header_core CXSPARSE "${CXSPARSE_INCLUDES}"
   ${CP} ${CP_FLAGS} ${BUILDDIR}/UFconfig/UFconfig.h ${INCLUDE_PATH}
   
}

uninstall()
{
   ${RM} ${RM_FLAGS} ${BINARY_PATH}/lapack.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/liblapack.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/liblapack.a
}

all() {
  download
  unpack
  applypatch
  build
  install
}

main $*
