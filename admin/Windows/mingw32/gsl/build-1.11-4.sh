#! /usr/bin/sh

# Name of package
PKG=gsl
# Version of Package
VER=1.11
# Release of (this patched) package
REL=4
# Name&Version of Package
PKGVER=${PKG}-${VER}
# Full name of this patched Package
FULLPKG=${PKGVER}-${REL}

# Name of source file(s)
SRCFILE=${PKGVER}.tar.gz
# Name of Patch file
PATCHFILE=${FULLPKG}.patch

# URL(s) of source code file(s)
URL="http://gd.tuwien.ac.at/gnu/gnusrc/gsl/gsl-1.11.tar.gz"

# Top dir of this building process (i.e. where the patch file and source file(s) reside)
TOPDIR=`pwd`
# Directory source code is extraced to (relative to TOPDIR)
SRCDIR=${PKGVER}
# Directory original source code is extracted to (for generating diffs) (relative to TOPDIR)
SRCDIR_ORIG=${SRCDIR}-orig

# Make file to use (optional)
MAKEFILE=
# Any extra flags to pass make to
MAKE_XTRA=

# subdirectory to install heraders to (empty for default)
INCLUDE_DIR=include/gsl

# Herader files to install
HEADERS_INSTALL="gsl_blas.h
gsl_blas_types.h
gsl_block.h
gsl_block_char.h
gsl_block_complex_double.h
gsl_block_complex_float.h
gsl_block_complex_long_double.h
gsl_block_double.h
gsl_block_float.h
gsl_block_int.h
gsl_block_long.h
gsl_block_long_double.h
gsl_block_short.h
gsl_block_uchar.h
gsl_block_uint.h
gsl_block_ulong.h
gsl_block_ushort.h
gsl_bspline.h
gsl_cblas.h
gsl_cdf.h
gsl_chebyshev.h
gsl_check_range.h
gsl_combination.h
gsl_complex.h
gsl_complex_math.h
gsl_const.h
gsl_const_cgs.h
gsl_const_cgsm.h
gsl_const_mks.h
gsl_const_mksa.h
gsl_const_num.h
gsl_deriv.h
gsl_dft_complex.h
gsl_dft_complex_float.h
gsl_dht.h
gsl_diff.h
gsl_eigen.h
gsl_errno.h
gsl_fft.h
gsl_fft_complex.h
gsl_fft_complex_float.h
gsl_fft_halfcomplex.h
gsl_fft_halfcomplex_float.h
gsl_fft_real.h
gsl_fft_real_float.h
gsl_fit.h
gsl_heapsort.h
gsl_histogram.h
gsl_histogram2d.h
gsl_ieee_utils.h
gsl_integration.h
gsl_interp.h
gsl_linalg.h
gsl_machine.h
gsl_math.h
gsl_matrix.h
gsl_matrix_char.h
gsl_matrix_complex_double.h
gsl_matrix_complex_float.h
gsl_matrix_complex_long_double.h
gsl_matrix_double.h
gsl_matrix_float.h
gsl_matrix_int.h
gsl_matrix_long.h
gsl_matrix_long_double.h
gsl_matrix_short.h
gsl_matrix_uchar.h
gsl_matrix_uint.h
gsl_matrix_ulong.h
gsl_matrix_ushort.h
gsl_message.h
gsl_min.h
gsl_mode.h
gsl_monte.h
gsl_monte_miser.h
gsl_monte_plain.h
gsl_monte_vegas.h
gsl_multifit.h
gsl_multifit_nlin.h
gsl_multimin.h
gsl_multiroots.h
gsl_nan.h
gsl_ntuple.h
gsl_odeiv.h
gsl_permutation.h
gsl_permute.h
gsl_permute_char.h
gsl_permute_complex_double.h
gsl_permute_complex_float.h
gsl_permute_complex_long_double.h
gsl_permute_double.h
gsl_permute_float.h
gsl_permute_int.h
gsl_permute_long.h
gsl_permute_long_double.h
gsl_permute_short.h
gsl_permute_uchar.h
gsl_permute_uint.h
gsl_permute_ulong.h
gsl_permute_ushort.h
gsl_permute_vector.h
gsl_permute_vector_char.h
gsl_permute_vector_complex_double.h
gsl_permute_vector_complex_float.h
gsl_permute_vector_complex_long_double.h
gsl_permute_vector_double.h
gsl_permute_vector_float.h
gsl_permute_vector_int.h
gsl_permute_vector_long.h
gsl_permute_vector_long_double.h
gsl_permute_vector_short.h
gsl_permute_vector_uchar.h
gsl_permute_vector_uint.h
gsl_permute_vector_ulong.h
gsl_permute_vector_ushort.h
gsl_poly.h
gsl_pow_int.h
gsl_precision.h
gsl_qrng.h
gsl_randist.h
gsl_rng.h
gsl_roots.h
gsl_sf.h
gsl_sf_airy.h
gsl_sf_bessel.h
gsl_sf_clausen.h
gsl_sf_coulomb.h
gsl_sf_coupling.h
gsl_sf_dawson.h
gsl_sf_debye.h
gsl_sf_dilog.h
gsl_sf_elementary.h
gsl_sf_ellint.h
gsl_sf_elljac.h
gsl_sf_erf.h
gsl_sf_exp.h
gsl_sf_expint.h
gsl_sf_fermi_dirac.h
gsl_sf_gamma.h
gsl_sf_gegenbauer.h
gsl_sf_hyperg.h
gsl_sf_laguerre.h
gsl_sf_lambert.h
gsl_sf_legendre.h
gsl_sf_log.h
gsl_sf_mathieu.h
gsl_sf_pow_int.h
gsl_sf_psi.h
gsl_sf_result.h
gsl_sf_synchrotron.h
gsl_sf_transport.h
gsl_sf_trig.h
gsl_sf_zeta.h
gsl_siman.h
gsl_sort.h
gsl_sort_char.h
gsl_sort_double.h
gsl_sort_float.h
gsl_sort_int.h
gsl_sort_long.h
gsl_sort_long_double.h
gsl_sort_short.h
gsl_sort_uchar.h
gsl_sort_uint.h
gsl_sort_ulong.h
gsl_sort_ushort.h
gsl_sort_vector.h
gsl_sort_vector_char.h
gsl_sort_vector_double.h
gsl_sort_vector_float.h
gsl_sort_vector_int.h
gsl_sort_vector_long.h
gsl_sort_vector_long_double.h
gsl_sort_vector_short.h
gsl_sort_vector_uchar.h
gsl_sort_vector_uint.h
gsl_sort_vector_ulong.h
gsl_sort_vector_ushort.h
gsl_specfunc.h
gsl_spline.h
gsl_statistics.h
gsl_statistics_char.h
gsl_statistics_double.h
gsl_statistics_float.h
gsl_statistics_int.h
gsl_statistics_long.h
gsl_statistics_long_double.h
gsl_statistics_short.h
gsl_statistics_uchar.h
gsl_statistics_uint.h
gsl_statistics_ulong.h
gsl_statistics_ushort.h
gsl_sum.h
gsl_sys.h
gsl_test.h
gsl_types.h
gsl_vector.h
gsl_vector_char.h
gsl_vector_complex.h
gsl_vector_complex_double.h
gsl_vector_complex_float.h
gsl_vector_complex_long_double.h
gsl_vector_double.h
gsl_vector_float.h
gsl_vector_int.h
gsl_vector_long.h
gsl_vector_long_double.h
gsl_vector_short.h
gsl_vector_uchar.h
gsl_vector_uint.h
gsl_vector_ulong.h
gsl_vector_ushort.h
gsl_version.h
gsl_wavelet.h
gsl_wavelet2d.h
"

# pkg-config .pc files to install
PKG_CONFIG_INSTALL="gsl.pc"

# Additional DIFF Flags for generating diff file
DIFF_FLAGS=

# load common functions
source ../gcc44_common.sh

# Directory the lib is built in (set this *after* loading gcc44_common.sh)
BUILDDIR=".build_${BUILD_TARGET}_${FULLPKG}_gcc${GCC_VERSION}${GCC_SYSTEM}"

# == override resp. specify build actions ==

conf()
{
   conf_pre;
   ( cd ${BUILDDIR} && ${TOPDIR}/${SRCDIR}/configure \
     --srcdir=${TOPDIR}/${SRCDIR} \
     CC="${CC} $LIBGCCLDFLAGS" \
     CXX="${CXX} $LIBGCCLDFLAGS" \
     F77="${F77} $LIBGCCLDFLAGS" \
     CPP=$CPP \
     AR=$AR \
     RANLIB=$RANLIB \
     RC=$RC \
     STRIP=$STRIP \
     LD=$LD \
     CFLAGS="$CFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CXXFLAGS="$CXXFLAGS ${GCC_ARCH_FLAGS} ${GCC_OPT_FLAGS} -Wall" \
     CPPFLAGS="$CPPFLAGS" \
     LDFLAGS="${LDFLAGS}" \
     CXXLIBS="${CXXLIBS}" \
     --prefix=${PREFIX}
   )
   touch ${BUILDDIR}/have_configure
   modify_libtool_all ${BUILDDIR}/libtool
   conf_post;
}

install()
{
   install_pre;
   
   # Install library, import library and static library
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/gsl.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libgsl.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/.libs/libgsl.a ${STATICLIB_PATH}
   
   ${CP} ${CP_FLAGS} ${BUILDDIR}/cblas/.libs/gslcblas.dll ${SHAREDLIB_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/cblas/.libs/libgslcblas.dll.a ${LIBRARY_PATH}
   ${CP} ${CP_FLAGS} ${BUILDDIR}/cblas/.libs/libgslcblas.a ${STATICLIB_PATH}
   
   # Install pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/$a ${PKGCONFIGDATA_PATH}
   done
   
   # Install headers
   for a in $HEADERS_INSTALL; do
      ${CP} ${CP_FLAGS} ${BUILDDIR}/gsl/$a ${INCLUDE_PATH}
   done
   
   # Install license file
   ${CP} ${CP_FLAGS} ${SRCDIR}/COPYING ${LICENSE_PATH}/${PKG}
   
   install_post;
}

uninstall()
{
   uninstall_pre;
   
   # Install library, import library and static library
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/gsl.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libgsl.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libgsl.a
   
   ${RM} ${RM_FLAGS} ${SHAREDLIB_PATH}/gslcblas.dll
   ${RM} ${RM_FLAGS} ${LIBRARY_PATH}/libgslcblas.dll.a
   ${RM} ${RM_FLAGS} ${STATICLIB_PATH}/libgslcblas.a
   
   # Uninstall headers
   for a in $HEADERS_INSTALL; do
      ${RM} ${RM_FLAGS} ${INCLUDE_PATH}/$a
   done
   
   # Uninstall pkg-config .pc files
   for a in $PKG_CONFIG_INSTALL; do
      ${RM} ${RM_FLAGS} ${PKGCONFIGDATA_PATH}/$a
   done
   
   # Uninstall license file
   ${RM} ${RM_FLAGS} ${LICENSE_PATH}/${PKG}/COPYING
   
   uninstall_post;
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
