/*
** Author: Joerg Specht
**
** This program is granted to the public domain.
**
** THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
** IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
** ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
** FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
** DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
** OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
** HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
** LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
** OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
** SUCH DAMAGE.
*/

// use: mkoctfile gcvspl.cc gcvsplf.f
#define NDEBUG

#include <octave/config.h>
#include <octave/defun-dld.h>
#include <octave/error.h>
#include <octave/help.h>
#include <octave/oct-obj.h>
#include <octave/pager.h>
#include <octave/symtab.h>
#include <octave/variables.h>

extern "C" {
  /* by f2c -A ...: */
  extern int gcvspl_(double *x, double *y, int *ny, 
		     double *wx, double *wy, int *m, int *n,
		     int *k, int *md, double *val, double *c,
		     int *nc, double *wk, int *ier);
  extern double splder_(int *ider, int *m, int *n, double *t, 
			double *x, double *c, int *l, double *q);
}

#ifndef NDEBUG
#ifndef DEBUGLEVEL
#define DEBUGLEVEL	255
#endif
static int do_debug(const char *fmt, ...) {
  va_list args;
  fprintf(stderr, "debug: ");
  va_start(args, fmt);
  vfprintf(stderr, fmt, args);
  va_end(args);
  fprintf(stderr, "\n");
  fflush(NULL);
  return 1;
}
#define DEBUG(level, fmtetc)	((level) & DEBUGLEVEL) && do_debug fmtetc
#else
#define DEBUG(level, fmtetc)
#endif

#define ASSERT(what)					\
	if(!(what)) {					\
		(*current_liboctave_error_handler)(	\
			"gcvspl: assertion failed: "#what);	\
		return retval;				\
	}

DEFUN_DLD(gcvspl, args, nargout,
"[yf,wk]=gcvspl(x(n,1),y(n,k), xf(nf,1)=x, wx(n,1)=[],wy(1,k)=[], m=2,md=2,val=1, ider=[0])\n\
\n\
uses  GCVSPL.FOR, 1986-05-12\n\
from  http://www.netlib.org/gcv/index.html\n\
for   B-spline data smoothing using generalized cross-validation\n\
      and mean squared prediction or explicit user smoothing\n\
by    H.J. Woltring,  University of Nijmegen,\n\
      Philips Medical Systems, Eindhoven (The Netherlands)\n\
\n\
Purpose:\n\
      Natural B-spline data smoothing subroutine, using the Generali-\n\
      zed Cross-Validation and Mean-Squared Prediction Error Criteria\n\
      of Craven & Wahba (1979). Alternatively, the amount of smoothing\n\
      can be given explicitly, or it can be based on the effective\n\
      number of degrees of freedom in the smoothing process as defined\n\
      by Wahba (1980). The model assumes uncorrelated, additive noise\n\
      and essentially smooth, underlying functions. The noise may be\n\
      non-stationary, and the independent co-ordinates may be spaced\n\
      non-equidistantly. Multiple datasets, with common independent\n\
      variables and weight factors are accomodated.\n\
      A full description of the package is provided in:\n\
      H.J. Woltring (1986), A FORTRAN package for generalized,\n\
      cross-validatory spline smoothing and differentiation.\n\
      Advances in Engineering Software 8(2):104-113\n\
\n\
Meaning of parameters:\n\
      X(N,1)  Independent variables: strictly increasing knot\n\
              sequence, with X(I-1).lt.X(I), I=2,...,N.\n\
      Y(N,K)  Input data to be smoothed (or interpolated).\n\
      XF(NF,1)Points where the function should be approximated.\n\
      WX(N,1) Weight factor array; WX(I) corresponds with\n\
              the relative inverse variance of point Y(I,*).\n\
              If no relative weighting information is\n\
              available, the WX(I) should be set to ONE.\n\
              All WX(I).gt.ZERO, I=1,...,N.\n\
      WY(1,K) Weight factor array; WY(J) corresponds with\n\
              the relative inverse variance of point Y(*,J).\n\
              If no relative weighting information is\n\
              available, the WY(J) should be set to ONE.\n\
              All WY(J).gt.ZERO, J=1,...,K.\n\
              NB: The effective weight for point Y(I,J) is\n\
              equal to WX(I)*WY(J).\n\
      M       Half order of the required B-splines (spline\n\
              degree 2*M-1), with M.gt.0. The values M =\n\
              1,2,3,4 correspond to linear, cubic, quintic,\n\
              and heptic splines, respectively. N.ge.2*M.\n\
      MD      Optimization mode switch:\n\
              |MD| = 1: Prior given value for p in VAL\n\
                        (VAL.ge.ZERO). This is the fastest\n\
                        use of GCVSPL, since no iteration\n\
                        is performed in p.\n\
              |MD| = 2: Generalized cross validation.\n\
              |MD| = 3: True predicted mean-squared error,\n\
                        with prior given variance in VAL.\n\
              |MD| = 4: Prior given number of degrees of\n\
                        freedom in VAL (ZERO.le.VAL.le.N-M).\n\
              After return from MD.ne.1, the same number of\n\
              degrees of freedom can be obtained, for identical\n\
              weight factors and knot positions, by selecting\n\
              |MD|=1, and by copying the value of p from WK(4)\n\
              into VAL. In this way, no iterative optimization\n\
              is required when processing other data in Y.\n\
      VAL     Mode value, as described above under MD.\n\
      IDER    Derivative order required, with 0.le.IDER\n\
              and IDER.le.2*M. If IDER.eq.0, the function\n\
              value is returned; otherwise, the IDER-th\n\
              derivative of the spline is returned.\n\
\n\
Return values:\n\
      YF(NF,1)Approximated values at XF.\n\
      WK(IWK) On normal exit, the first 6 values of WK are\n\
              assigned as follows:\n\
              WK(1) = Generalized Cross Validation value\n\
              WK(2) = Mean Squared Residual.\n\
              WK(3) = Estimate of the number of degrees of\n\
                      freedom of the residual sum of squares\n\
                      per dataset, with 0.lt.WK(3).lt.N-M.\n\
              WK(4) = Smoothing parameter p, multiplicative\n\
                      with the splines' derivative constraint.\n\
              WK(5) = Estimate of the true mean squared error\n\
                      (different formula for |MD| = 3).\n\
              WK(6) = Gauss-Markov error variance.\n\
\n\
              If WK(4) -->  0 , WK(3) -->  0 , and an inter-\n\
              polating spline is fitted to the data (p --> 0).\n\
              A very small value > 0 is used for p, in order\n\
              to avoid division by zero in the GCV function.\n\
\n\
              If WK(4) --> inf, WK(3) --> N-M, and a least-\n\
              squares polynomial of order M (degree M-1) is\n\
              fitted to the data (p --> inf). For numerical\n\
              reasons, a very high value is used for p.\n\
\n\
              Upon return, the contents of WK can be used for\n\
              covariance propagation in terms of the matrices\n\
              B and WE: see the source listings. The variance\n\
              estimate for dataset J follows as WK(6)/WY(J).\n\
\n\
Remarks:\n\
      (1) GCVSPL calculates a natural spline of order 2*M (degree\n\
      2*M-1) which smoothes or interpolates a given set of data\n\
      points, using statistical considerations to determine the\n\
      amount of smoothing required (Craven & Wahba, 1979). If the\n\
      error variance is a priori known, it should be supplied to\n\
      the routine in VAL, for |MD|=3. The degree of smoothing is\n\
      then determined to minimize an unbiased estimate of the true\n\
      mean squared error. On the other hand, if the error variance\n\
      is not known, one may select |MD|=2. The routine then deter-\n\
      mines the degree of smoothing to minimize the generalized\n\
      cross validation function. This is asymptotically the same\n\
      as minimizing the true predicted mean squared error (Craven &\n\
      Wahba, 1979). If the estimates from |MD|=2 or 3 do not appear\n\
      suitable to the user (as apparent from the smoothness of the\n\
      M-th derivative or from the effective number of degrees of\n\
      freedom returned in WK(3) ), the user may select an other\n\
      value for the noise variance if |MD|=3, or a reasonably large\n\
      number of degrees of freedom if |MD|=4. If |MD|=1, the proce-\n\
      dure is non-iterative, and returns a spline for the given\n\
      value of the smoothing parameter p as entered in VAL.\n\
\n\
      (2) The number of arithmetic operations and the amount of\n\
      storage required are both proportional to N, so very large\n\
      datasets may be accomodated. The data points do not have\n\
      to be equidistant in the independant variable X or uniformly\n\
      weighted in the dependant variable Y. However, the data\n\
      points in X must be strictly increasing. Multiple dataset\n\
      processing (K.gt.1) is numerically more efficient dan\n\
      separate processing of the individual datasets (K.eq.1).\n\
\n\
      (3) If |MD|=3 (a priori known noise variance), any value of\n\
      N.ge.2*M is acceptable. However, it is advisable for N-2*M\n\
      be rather large (at least 20) if |MD|=2 (GCV).\n\
\n\
      (4) For |MD| > 1, GCVSPL tries to iteratively minimize the\n\
      selected criterion function. This minimum is unique for |MD|\n\
      = 4, but not necessarily for |MD| = 2 or 3. Consequently, \n\
      local optima rather that the global optimum might be found,\n\
      and some actual findings suggest that local optima might\n\
      yield more meaningful results than the global optimum if N\n\
      is small. Therefore, the user has some control over the\n\
      search procedure. If MD > 1, the iterative search starts\n\
      from a value which yields a number of degrees of freedom\n\
      which is approximately equal to N/2, until the first (local)\n\
      minimum is found via a golden section search procedure\n\
      (Utreras, 1980). If MD < -1, the value for p contained in\n\
      WK(4) is used instead. Thus, if MD = 2 or 3 yield too noisy\n\
      an estimate, the user might try |MD| = 1 or 4, for suitably\n\
      selected values for p or for the number of degrees of\n\
      freedom, and then run GCVSPL with MD = -2 or -3. The con-\n\
      tents of N, M, K, X, WX, WY, and WK are assumed unchanged\n\
      if MD < 0.\n\
\n\
      (5) GCVSPL calculates the spline coefficient array C(N,K);\n\
      this array can be used to calculate the spline function\n\
      value and any of its derivatives up to the degree 2*M-1\n\
      at any argument T within the knot range, using subrou-\n\
      tines SPLDER and SEARCH, and the knot array X(N). Since\n\
      the splines are constrained at their Mth derivative, only\n\
      the lower spline derivatives will tend to be reliable\n\
      estimates of the underlying, true signal derivatives.\n\
\n\
      (6) GCVSPL combines elements of subroutine CRVO5 by Utre-\n\
      ras (1980), subroutine SMOOTH by Lyche et al. (1983), and\n\
      subroutine CUBGCV by Hutchinson (1985). The trace of the\n\
      influence matrix is assessed in a similar way as described\n\
      by Hutchinson & de Hoog (1985). The major difference is\n\
      that the present approach utilizes non-symmetrical B-spline\n\
      design matrices as described by Lyche et al. (1983); there-\n\
      fore, the original algorithm by Erisman & Tinney (1975) has\n\
      been used, rather than the symmetrical version adopted by\n\
      Hutchinson & de Hoog.\n\
\n\
References:\n\
      P. Craven & G. Wahba (1979), Smoothing noisy data with\n\
      spline functions. Numerische Mathematik 31, 377-403.\n\
\n\
      A.M. Erisman & W.F. Tinney (1975), On computing certain\n\
      elements of the inverse of a sparse matrix. Communications\n\
      of the ACM 18(3), 177-179.\n\
\n\
      M.F. Hutchinson & F.R. de Hoog (1985), Smoothing noisy data\n\
      with spline functions. Numerische Mathematik 47(1), 99-106.\n\
\n\
      M.F. Hutchinson (1985), Subroutine CUBGCV. CSIRO Division of\n\
      Mathematics and Statistics, P.O. Box 1965, Canberra, ACT 2601,\n\
      Australia.\n\
\n\
      T. Lyche, L.L. Schumaker, & K. Sepehrnoori (1983), Fortran\n\
      subroutines for computing smoothing and interpolating natural\n\
      splines. Advances in Engineering Software 5(1), 2-5.\n\
\n\
      F. Utreras (1980), Un paquete de programas para ajustar curvas\n\
      mediante funciones spline. Informe Tecnico MA-80-B-209, Depar-\n\
      tamento de Matematicas, Faculdad de Ciencias Fisicas y Matema-\n\
      ticas, Universidad de Chile, Santiago.\n\
\n\
      Wahba, G. (1980). Numerical and statistical methods for mildly,\n\
      moderately and severely ill-posed problems with noisy data.\n\
      Technical report nr. 595 (February 1980). Department of Statis-\n\
      tics, University of Madison (WI), U.S.A.\
")
{
  octave_value_list retval;
  DEBUG(1, ("A"));
  int nargs = args.length();
  ASSERT(nargs >= 2 && nargs <= 9);
  Matrix x=args(0).matrix_value();
  Matrix y=args(1).matrix_value();
  Matrix x_target = nargs > 2 ? args(2).matrix_value() : x;
  // int ny=y.rows(); --> ny=n
  ASSERT(!error_state);
  int n=x.rows();
  int k=y.columns();
  Matrix wx = (nargs > 3 && !args(3).is_zero_by_zero())
    ? args(3).matrix_value() : Matrix(n,1,1.0);
  Matrix wy = (nargs > 4 && !args(4).is_zero_by_zero())
    ? args(4).matrix_value() : Matrix(1,k,1.0);
  int m = nargs > 5 ? (int)rint(args(5).double_value()) : 2;
  int md = nargs > 6 ? (int)rint(args(6).double_value()) : 2;
  double val = nargs > 7 ? args(7).double_value() : 1.0;
  Matrix mider = nargs > 8 ? args(8).matrix_value() : Matrix(1,1,0.0);

  // int nc=n;
  double c[n*k];	// Matrix c(n,k);
  double wk[6*(n*m+1)+n];// work array, return status
  int ier;

  DEBUG(1, ("B"));
  ASSERT(!error_state);
  ASSERT(x.columns() == 1);
  ASSERT(y.rows() == n);
  ASSERT(wx.rows() == n && wx.columns() == 1);
  ASSERT(wy.rows() == 1 && wy.columns() == k);
  ASSERT(m > 0);
  ASSERT(n >= 2*m);
  ASSERT(k >= 1);
  ASSERT(md >= 1 && md <= 4);
  ASSERT(val >= 0);
  ASSERT(mider.rows() == 1);
  int nider = mider.columns();
  int ider[nider];
  for(int i=0; i<nider; i++) {
    ider[i] = (int)rint(mider.xelem(0,i));
    ASSERT(0 <= ider[i] && ider[i] <= 2*m);
  }

  DEBUG(2,
	("gcvspl_(x,y,ny=%d,wx,wy,m=%d,n=%d,k=%d,md=%d,val=%g,c,nc=%d,wk,ier)",
	 n, m, n, k, md, val, n));
  double *x_fortran = x.fortran_vec();
  gcvspl_(x_fortran, y.fortran_vec(), &n,
	  wx.fortran_vec(), wy.fortran_vec(), &m, &n, &k,
	  &md, &val, c, &n, wk, &ier);

  if(ier != 0) {
    (*current_liboctave_error_handler)
      (ier==1 ? "M<=0 || N<2*M"
       : ier==2 ? "knots not sorted or negative weight"
       : ier==3 ? "wrong mode parameter or value"
       : "unknown error");
    return retval;
  }

  DEBUG(1, ("D"));
  int l=0;	// index in x, just simplifies search
  double q[2*m];// work array
  int nxt=x_target.rows();
  ASSERT(x_target.columns() == 1);
  Matrix y_target(nxt,k*nider);
  DEBUG(1, ("E"));
  double *xf=x_target.fortran_vec();
  double *yf=y_target.fortran_vec();
  for(int i=0; i<nxt; i++) {		// next point
    double xt=xf[i];
    for(int j=0; j<k; j++)		// next curve
      for(int o=0; o<nider; o++)	// next derivate
	yf[nxt*(nider*j+o)+i] = splder_(&ider[o], &m, &n, &xt, x_fortran, c+n*j, &l, q);
  }

  DEBUG(1, ("F"));
  DEBUG(2, ("nargout=%d", nargout));
  retval(0) = y_target;
  if(nargout > 1) {
    DEBUG(1, ("G"));
    RowVector wkv(6);
    double *wkvf=wkv.fortran_vec();
    for(int i=0; i<6; i++)
      wkvf[i] = wk[i];
    retval(1) = wkv;
  }
  DEBUG(1, ("H"));
  return retval;
}
