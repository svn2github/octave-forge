#! /bin/sh

# this script downloads, patches and builds gsl.dll 

# Name of the package we're building
PKG=gsl
# Version of the package
VER=1.9
# Release No
REL=1
# URL to source code
URL=http://gd.tuwien.ac.at/gnu/gnusrc/gsl/gsl-1.9.tar.gz

# ---------------------------
# The directory this script is located
TOPDIR=`pwd`
# Name of the source package
PKGNAME=${PKG}-${VER}
# Full package name including revision
FULLPKG=${PKGNAME}-${REL}
# Name of the source code package
SRCPKG=${PKGNAME}
# Name of the patch file
PATCHFILE=${FULLPKG}.diff
# Name of the source code file
SRCFILE=${PKGNAME}.tar.gz
# Directory where the source code is located
SRCDIR=${TOPDIR}/${PKGNAME}

# The directory we build the source code in
BUILDDIR=${TOPDIR}/.build_mingw32
MKPATCHFLAGS=""
#INSTHEADERS="gsl_math.h gsl_pow_int.h gsl_nan.h gsl_machine.h gsl_mode.h gsl_precision.h gsl_types.h gsl_version.h"
INSTHEADERS="
blas/gsl_blas.h
blas/gsl_blas_types.h
block/gsl_block.h
block/gsl_block_char.h
block/gsl_block_complex_double.h
block/gsl_block_complex_float.h
block/gsl_block_complex_long_double.h
block/gsl_block_double.h
block/gsl_block_float.h
block/gsl_block_int.h
block/gsl_block_long.h
block/gsl_block_long_double.h
block/gsl_block_short.h
block/gsl_block_uchar.h
block/gsl_block_uint.h
block/gsl_block_ulong.h
block/gsl_block_ushort.h
block/gsl_check_range.h
bspline/gsl_bspline.h
cblas/gsl_cblas.h
cdf/gsl_cdf.h
cheb/gsl_chebyshev.h
combination/gsl_combination.h
complex/gsl_complex.h
complex/gsl_complex_math.h
const/gsl_const.h
const/gsl_const_cgs.h
const/gsl_const_cgsm.h
const/gsl_const_mks.h
const/gsl_const_mksa.h
const/gsl_const_num.h
deriv/gsl_deriv.h
dht/gsl_dht.h
diff/gsl_diff.h
eigen/gsl_eigen.h
err/gsl_errno.h
err/gsl_message.h
fft/gsl_dft_complex.h
fft/gsl_dft_complex_float.h
fft/gsl_fft.h
fft/gsl_fft_complex.h
fft/gsl_fft_complex_float.h
fft/gsl_fft_halfcomplex.h
fft/gsl_fft_halfcomplex_float.h
fft/gsl_fft_real.h
fft/gsl_fft_real_float.h
fit/gsl_fit.h
gsl_machine.h
gsl_math.h
gsl_mode.h
gsl_nan.h
gsl_pow_int.h
gsl_precision.h
gsl_types.h
gsl_version.h
histogram/gsl_histogram.h
histogram/gsl_histogram2d.h
ieee-utils/gsl_ieee_utils.h
integration/gsl_integration.h
interpolation/gsl_interp.h
interpolation/gsl_spline.h
linalg/gsl_linalg.h
matrix/gsl_matrix.h
matrix/gsl_matrix_char.h
matrix/gsl_matrix_complex_double.h
matrix/gsl_matrix_complex_float.h
matrix/gsl_matrix_complex_long_double.h
matrix/gsl_matrix_double.h
matrix/gsl_matrix_float.h
matrix/gsl_matrix_int.h
matrix/gsl_matrix_long.h
matrix/gsl_matrix_long_double.h
matrix/gsl_matrix_short.h
matrix/gsl_matrix_uchar.h
matrix/gsl_matrix_uint.h
matrix/gsl_matrix_ulong.h
matrix/gsl_matrix_ushort.h
min/gsl_min.h
monte/gsl_monte.h
monte/gsl_monte_miser.h
monte/gsl_monte_plain.h
monte/gsl_monte_vegas.h
multifit/gsl_multifit.h
multifit/gsl_multifit_nlin.h
multimin/gsl_multimin.h
multiroots/gsl_multiroots.h
ntuple/gsl_ntuple.h
ode-initval/gsl_odeiv.h
permutation/gsl_permutation.h
permutation/gsl_permute.h
permutation/gsl_permute_char.h
permutation/gsl_permute_complex_double.h
permutation/gsl_permute_complex_float.h
permutation/gsl_permute_complex_long_double.h
permutation/gsl_permute_double.h
permutation/gsl_permute_float.h
permutation/gsl_permute_int.h
permutation/gsl_permute_long.h
permutation/gsl_permute_long_double.h
permutation/gsl_permute_short.h
permutation/gsl_permute_uchar.h
permutation/gsl_permute_uint.h
permutation/gsl_permute_ulong.h
permutation/gsl_permute_ushort.h
permutation/gsl_permute_vector.h
permutation/gsl_permute_vector_char.h
permutation/gsl_permute_vector_complex_double.h
permutation/gsl_permute_vector_complex_float.h
permutation/gsl_permute_vector_complex_long_double.h
permutation/gsl_permute_vector_double.h
permutation/gsl_permute_vector_float.h
permutation/gsl_permute_vector_int.h
permutation/gsl_permute_vector_long.h
permutation/gsl_permute_vector_long_double.h
permutation/gsl_permute_vector_short.h
permutation/gsl_permute_vector_uchar.h
permutation/gsl_permute_vector_uint.h
permutation/gsl_permute_vector_ulong.h
permutation/gsl_permute_vector_ushort.h
poly/gsl_poly.h
qrng/gsl_qrng.h
randist/gsl_randist.h
rng/gsl_rng.h
roots/gsl_roots.h
siman/gsl_siman.h
sort/gsl_heapsort.h
sort/gsl_sort.h
sort/gsl_sort_char.h
sort/gsl_sort_double.h
sort/gsl_sort_float.h
sort/gsl_sort_int.h
sort/gsl_sort_long.h
sort/gsl_sort_long_double.h
sort/gsl_sort_short.h
sort/gsl_sort_uchar.h
sort/gsl_sort_uint.h
sort/gsl_sort_ulong.h
sort/gsl_sort_ushort.h
sort/gsl_sort_vector.h
sort/gsl_sort_vector_char.h
sort/gsl_sort_vector_double.h
sort/gsl_sort_vector_float.h
sort/gsl_sort_vector_int.h
sort/gsl_sort_vector_long.h
sort/gsl_sort_vector_long_double.h
sort/gsl_sort_vector_short.h
sort/gsl_sort_vector_uchar.h
sort/gsl_sort_vector_uint.h
sort/gsl_sort_vector_ulong.h
sort/gsl_sort_vector_ushort.h
specfunc/gsl_sf.h
specfunc/gsl_sf_airy.h
specfunc/gsl_sf_bessel.h
specfunc/gsl_sf_clausen.h
specfunc/gsl_sf_coulomb.h
specfunc/gsl_sf_coupling.h
specfunc/gsl_sf_dawson.h
specfunc/gsl_sf_debye.h
specfunc/gsl_sf_dilog.h
specfunc/gsl_sf_elementary.h
specfunc/gsl_sf_ellint.h
specfunc/gsl_sf_elljac.h
specfunc/gsl_sf_erf.h
specfunc/gsl_sf_exp.h
specfunc/gsl_sf_expint.h
specfunc/gsl_sf_fermi_dirac.h
specfunc/gsl_sf_gamma.h
specfunc/gsl_sf_gegenbauer.h
specfunc/gsl_sf_hyperg.h
specfunc/gsl_sf_laguerre.h
specfunc/gsl_sf_lambert.h
specfunc/gsl_sf_legendre.h
specfunc/gsl_sf_log.h
specfunc/gsl_sf_mathieu.h
specfunc/gsl_sf_pow_int.h
specfunc/gsl_sf_psi.h
specfunc/gsl_sf_result.h
specfunc/gsl_sf_synchrotron.h
specfunc/gsl_sf_transport.h
specfunc/gsl_sf_trig.h
specfunc/gsl_sf_zeta.h
specfunc/gsl_specfunc.h
statistics/gsl_statistics.h
statistics/gsl_statistics_char.h
statistics/gsl_statistics_double.h
statistics/gsl_statistics_float.h
statistics/gsl_statistics_int.h
statistics/gsl_statistics_long.h
statistics/gsl_statistics_long_double.h
statistics/gsl_statistics_short.h
statistics/gsl_statistics_uchar.h
statistics/gsl_statistics_uint.h
statistics/gsl_statistics_ulong.h
statistics/gsl_statistics_ushort.h
sum/gsl_sum.h
sys/gsl_sys.h
test/gsl_test.h
vector/gsl_vector.h
vector/gsl_vector_char.h
vector/gsl_vector_complex.h
vector/gsl_vector_complex_double.h
vector/gsl_vector_complex_float.h
vector/gsl_vector_complex_long_double.h
vector/gsl_vector_double.h
vector/gsl_vector_float.h
vector/gsl_vector_int.h
vector/gsl_vector_long.h
vector/gsl_vector_long_double.h
vector/gsl_vector_short.h
vector/gsl_vector_uchar.h
vector/gsl_vector_uint.h
vector/gsl_vector_ulong.h
vector/gsl_vector_ushort.h
wavelet/gsl_wavelet.h
wavelet/gsl_wavelet2d.h
"

INSTALLDIR_INCLUDE=include/gsl

# --- load common functions ---
source ../common.sh

# Locally overridden functions with adaptions to current package
# (Typically when using specific makefiles, and specific install/uninstall instructions)

conf() {
(
   mkdirs;
   cd ${BUILDDIR} && ${SRCDIR}/configure CC=mingw32-gcc CFLAGS=-O3 CPPFLAGS="" --prefix=${PREFIX} --srcdir=${SRCDIR}
)
}

install() {
(
  mkinstalldirs;
  cp ${CP_FLAGS} ${BUILDDIR}/gsl.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/libgsl.dll.a ${INSTALL_LIB}
  cp ${CP_FLAGS} ${BUILDDIR}/gslcblas.dll ${INSTALL_BIN}
  cp ${CP_FLAGS} ${BUILDDIR}/libgslcblas.dll.a ${INSTALL_LIB}
  for a in ${INSTHEADERS}; do cp ${CP_FLAGS} ${SRCDIR}/$a ${INSTALL_INCLUDE}; done
)
}

uninstall() {
( 
  rm ${RM_FLAGS} ${INSTALL_BIN}/gsl.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libgsl.dll.a
  rm ${RM_FLAGS} ${INSTALL_BIN}/gslcblas.dll
  rm ${RM_FLAGS} ${INSTALL_LIB}/libgslcblas.dll.a
  for a in ${INSTHEADERS}; do rm ${RM_FLAGS} ${INSTALL_INLUDE}/$a; done
)
}

all() {
  unpack
  applypatch
  conf
  build
  install
}
main $*
   
