#! /bin/sh

# this script downloads, patches and builds the suitesparse libs

# Name of the package we're building
PKG=SuiteSparse
# Version of the package
VER=2.4.0
# Release No
REL=1
# URL to source code
URL=http://www.cise.ufl.edu/research/sparse/SuiteSparse/SuiteSparse-2.4.0.tar.gz

# ---------------------------
# The directory this script is located
TOPDIR=`pwd`
# Name of the source package
PKGNAME=${PKG}
# Full package name including revision
FULLPKG=${PKG}-${VER}-${REL}
# Name of the source code package
SRCPKG=${PKGNAME}-${VER}
# Name of the patch file
PATCHFILE=${FULLPKG}.diff
# Name of the source code file
SRCFILE=${SRCPKG}.tar.gz
# Directory where the source code is located
SRCDIR=${TOPDIR}/${PKGNAME}

# The directory we build the source code in
BUILDDIR=${SRCDIR}
MKPATCHFLAGS="-x *.out"
INSTALLDIR_INCLUDE=include/suitesparse

CHOLMOD_INCLUDES="cholmod_core.h cholmod_io64.h cholmod.h cholmod_supernodal.h cholmod_partition.h cholmod_modify.h cholmod_matrixops.h cholmod_internal.h cholmod_config.h cholmod_cholesky.h cholmod_check.h cholmod_blas.h cholmod_complexity.h cholmod_template.h"

UMFPACK_INCLUDES="umfpack.h umfpack_get_lunz.h umfpack_numeric.h umfpack_report_perm.h umfpack_save_symbolic.h umfpack_transpose.h umfpack_col_to_triplet.h umfpack_get_numeric.h umfpack_qsymbolic.h umfpack_report_status.h umfpack_scale.h umfpack_triplet_to_col.h umfpack_defaults.h umfpack_get_symbolic.h umfpack_report_control.h umfpack_report_symbolic.h umfpack_solve.h umfpack_wsolve.h umfpack_free_numeric.h umfpack_global.h umfpack_report_info.h umfpack_report_triplet.h umfpack_symbolic.h umfpack_free_symbolic.h umfpack_load_numeric.h umfpack_report_matrix.h umfpack_report_vector.h umfpack_tictoc.h umfpack_get_determinant.h umfpack_load_symbolic.h umfpack_report_numeric.h umfpack_save_numeric.h umfpack_timer.h"

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

build() {
(
    ( cd ${BUILDDIR}/AMD/Source  && make -f GNUmakefile );
	( cd ${BUILDDIR}/CAMD/Source && make -f GNUmakefile );
	( cd ${BUILDDIR}/CCOLAMD     && make );
	( cd ${BUILDDIR}/COLAMD      && make );
	( cd ${BUILDDIR}/CSparse/Source && make );
	( cd ${BUILDDIR}/CXSparse/Source && make );
	( cd ${BUILDDIR}/CHOLMOD/Lib && make );
	( cd ${BUILDDIR}/UMFPACK/Source && make -f GNUmakefile );
)
}

clean() {
(
    ( cd ${BUILDDIR}/AMD/Source      && make -f GNUmakefile clean );
	( cd ${BUILDDIR}/CAMD/Source     && make -f GNUmakefile clean );
	( cd ${BUILDDIR}/CCOLAMD         && make clean );
	( cd ${BUILDDIR}/COLAMD          && make clean );
	( cd ${BUILDDIR}/CSparse/Source  && make clean );
	( cd ${BUILDDIR}/CXSparse/Source && make clean );
	( cd ${BUILDDIR}/CHOLMOD/Lib     && make clean );
	( cd ${BUILDDIR}/UMFPACK/Source  && make -f GNUmakefile clean );
)
}
   
install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/AMD/Lib/amd.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/AMD/Lib/libamd.dll.a ${INSTALL_LIB}

  cp ${CP_FLAGS} ${BUILDDIR}/CAMD/Lib/camd.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/CAMD/Lib/libcamd.dll.a ${INSTALL_LIB}

  cp ${CP_FLAGS} ${BUILDDIR}/CCOLAMD/ccolamd.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/CCOLAMD/libccolamd.dll.a ${INSTALL_LIB}

  cp ${CP_FLAGS} ${BUILDDIR}/COLAMD/colamd.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/COLAMD/libcolamd.dll.a ${INSTALL_LIB}

  cp ${CP_FLAGS} ${BUILDDIR}/CXSparse/Source/cxsparse.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/CXSparse/Source/libcxsparse.dll.a ${INSTALL_LIB}

  cp ${CP_FLAGS} ${BUILDDIR}/CHOLMOD/Lib/cholmod.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/CHOLMOD/Lib/libcholmod.dll.a ${INSTALL_LIB}

  cp ${CP_FLAGS} ${BUILDDIR}/UMFPACK/Lib/umfpack.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/UMFPACK/Lib/libumfpack.dll.a ${INSTALL_LIB}

  cp ${CP_FLAGS} ${BUILDDIR}/UFconfig/UFconfig.h ${INSTALL_INCLUDE}
  cp ${CP_FLAGS} ${BUILDDIR}/AMD/Include/{amd.h,amd_internal.h} ${INSTALL_INCLUDE}
  cp ${CP_FLAGS} ${BUILDDIR}/CAMD/Include/{camd.h,camd_internal.h} ${INSTALL_INCLUDE}
  cp ${CP_FLAGS} ${BUILDDIR}/CCOLAMD/ccolamd.h ${INSTALL_INCLUDE}
  cp ${CP_FLAGS} ${BUILDDIR}/COLAMD/colamd.h ${INSTALL_INCLUDE}
  cp ${CP_FLAGS} ${BUILDDIR}/CXSparse/Source/cs.h ${INSTALL_INCLUDE}
  for a in ${UMFPACK_INCLUDES}; do cp ${CP_FLAGS} ${BUILDDIR}/UMFPACK/Include/${a} ${INSTALL_INCLUDE}; done
  for a in ${CHOLMOD_INCLUDES}; do cp ${CP_FLAGS} ${BUILDDIR}/CHOLMOD/Include/${a} ${INSTALL_INCLUDE}; done
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/amd.dll
  rm ${RM_FLAGS} ${INSTALL_BIN}/camd.dll
  rm ${RM_FLAGS} ${INSTALL_BIN}/ccolamd.dll
  rm ${RM_FLAGS} ${INSTALL_BIN}/colamd.dll
  rm ${RM_FLAGS} ${INSTALL_BIN}/cxsparse.dll
  rm ${RM_FLAGS} ${INSTALL_BIN}/cholmod.dll
  rm ${RM_FLAGS} ${INSTALL_BIN}/umfpack.dll

  rm ${RM_FLAGS} ${INSTALL_LIB}/libamd.dll.a
  rm ${RM_FLAGS} ${INSTALL_LIB}/libcamd.dll.a
  rm ${RM_FLAGS} ${INSTALL_LIB}/libccolamd.dll.a
  rm ${RM_FLAGS} ${INSTALL_LIB}/libcolamd.dll.a
  rm ${RM_FLAGS} ${INSTALL_LIB}/libcxsparse.dll.a
  rm ${RM_FLAGS} ${INSTALL_LIB}/libcholmod.dll.a
  rm ${RM_FLAGS} ${INSTALL_LIB}/libumfpack.dll.a
  
  rm ${RM_FLAGS} ${INSTALL_INCLUDE}/UFconfig.h
  rm ${RM_FLAGS} ${INSTALL_INCLUDE}/{amd.h,amd_internal.h}
  rm ${RM_FLAGS} ${INSTALL_INCLUDE}/{camd.h,camd_internal.h}
  rm ${RM_FLAGS} ${INSTALL_INCLUDE}/ccolamd.h
  rm ${RM_FLAGS} ${INSTALL_INCLUDE}/colamd.h
  rm ${RM_FLAGS} ${INSTALL_INCLUDE}/cs.h
  for a in ${UMFPACK_INCLUDES}; do rm ${RM_FLAGS} ${INSTALL_INCLUDE}/${a}; done
  for a in ${CHOLMOD_INCLUDES}; do rm ${RM_FLAGS} ${INSTALL_INCLUDE}/${a}; done
)
}

all() {
  unpack
  applypatch
  build
  install
}
main $*
   
