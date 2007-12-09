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

source ../common.sh

# Directory the lib is built in
BUILDDIR=".build_mingw32_${VER}-${REL}_gcc${GCC_VER}${GCC_SYS}"

mkdirs_pre() { if [ -e ${BUILDDIR} ]; then rm -rf ${BUILDDIR}; fi; }
mkdirs_post()
{
   mkdir -vp ${BUILDDIR}/AMD/Lib
   mkdir -vp ${BUILDDIR}/CAMD/Lib
   mkdir -vp ${BUILDDIR}/CCOLAMD/Lib
   mkdir -vp ${BUILDDIR}/COLAMD/Lib
   mkdir -vp ${BUILDDIR}/CSparse/Lib
   mkdir -vp ${BUILDDIR}/CXSparse/Lib
   mkdir -vp ${BUILDDIR}/CHOLMOD/Lib
   mkdir -vp ${BUILDDIR}/UMFPACK/Lib
   mkdir -vp ${BUILDDIR}/UFconfig
}

conf()
{
   substvars ${SRCDIR}/UFconfig/UFconfig.mk ${BUILDDIR}/UFconfig/UFconfig.mk
   ${CP} ${CP_FLAGS} ${SRCDIR}/AMD/Lib/GNUmakefile     ${BUILDDIR}/AMD/Lib/GNUmakefile
   ${CP} ${CP_FLAGS} ${SRCDIR}/CAMD/Lib/GNUmakefile    ${BUILDDIR}/CAMD/Lib/GNUmakefile
   ${CP} ${CP_FLAGS} ${SRCDIR}/CCOLAMD/Lib/Makefile    ${BUILDDIR}/CCOLAMD/Lib/Makefile
   ${CP} ${CP_FLAGS} ${SRCDIR}/CHOLMOD/Lib/Makefile    ${BUILDDIR}/CHOLMOD/Lib/Makefile
   ${CP} ${CP_FLAGS} ${SRCDIR}/COLAMD/Lib/Makefile     ${BUILDDIR}/COLAMD/Lib/Makefile
   ${CP} ${CP_FLAGS} ${SRCDIR}/CSparse/Lib/Makefile    ${BUILDDIR}/CSparse/Lib/Makefile
   ${CP} ${CP_FLAGS} ${SRCDIR}/CXSparse/Lib/Makefile   ${BUILDDIR}/CXSparse/Lib/Makefile
   ${CP} ${CP_FLAGS} ${SRCDIR}/UMFPACK/Lib/GNUmakefile ${BUILDDIR}/UMFPACK/Lib/GNUmakefile
}

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
   ${CP} ${CP_FLAGS} ${BUILDDIR}/$1/lib/$1.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/$1/lib/lib$1.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/$1/lib/lib$1.a ${STATICLIBRARY_PATH}
)
}

uninstall_lib_core() {
(
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/$1.dll 
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/lib$1.dll.a 
   ${RM} ${RM_FLAGS} ${STATICLIBRARY_PATH}/lib$1.a 
)
}

install_header_core() {
(
  for a in $2; do ${CP} ${CP_FLAGS} ${SRCDIR}/$1/Include/${a} ${INCLUDE_PATH}; done
)
}

uninstall_header_core() {
(
  for a in $2; do ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/${a}; done
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
   ${CP} ${CP_FLAGS} ${SRCDIR}/UFconfig/UFconfig.h ${INCLUDE_PATH}
   
}

uninstall()
{
   # Install the libs
   uninstall_lib_core amd
   uninstall_lib_core camd
   uninstall_lib_core ccolamd
   uninstall_lib_core colamd
   uninstall_lib_core csparse
   uninstall_lib_core cxsparse
   uninstall_lib_core cholmod
   uninstall_lib_core umfpack
   
   # Install the headers
   uninstall_header_core UMFPACK "${UMFPACK_INCLUDES}"
   uninstall_header_core CHOLMOD "${CHOLMOD_INCLUDES}"
   uninstall_header_core AMD "${AMD_INCLUDES}"
   uninstall_header_core CAMD "${CAMD_INCLUDES}"
   uninstall_header_core COLAMD "${COLAMD_INCLUDES}"
   uninstall_header_core CCOLAMD "${CCOLAMD_INCLUDES}"
   uninstall_header_core CXSPARSE "${CXSPARSE_INCLUDES}"
   ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/UFconfig.h
}

all() {
  download
  unpack
  applypatch
  mkdirs
  conf
  build
  install
}

main $*
