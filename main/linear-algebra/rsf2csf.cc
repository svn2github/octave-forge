/*
Copyright (C) 2001 Ian Searle

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

2001-03-07 Ross Lippert
  * adapted from rlab, using a slightly different similarity transform
2001-03-18 Paul Kienzle
   * convert to C++
*/

#include <octave/oct.h>

// XXX FIXME XXX 
// This should be a constructor for ComplexSCHUR
//     ComplexSCHUR::ComplexSCHUR(const Matrix& U, const Matrix& T)
// Should also have something like
//     ComplexSCHUR::ComplexSCHUR(const SCHUR& s)
//      { return ComplexSCHUR(s.unitary_mat(), s.schur_mat()); }
// The reason for using it (other than to provide the Octave function
// rsf2csf) is that for real A, ComplexSCHUR(SCHUR(A)) is more than
// twice as fast as ComplexSCHUR(ComplexMatrix(A)).

/* Converts real schur form (all real values, but some non-zero 
 * subdiagonals) to complex schur form (all zeros below the diagonal).
 * Assumes correct input: 
 *    square U and T of the same size, 
 *    U*T*U'=A, U*U'=I, 
 *    no consecutive non-zero entries on the subdiagonal, 
 *    tril(A,-2)==0 everywhere.
 */
void
rsf2csf(const Matrix& U, const Matrix& T, 
	ComplexMatrix& retU, ComplexMatrix& retT)
{
  const int n=U.rows();

  retU = ComplexMatrix(U);
  retT = ComplexMatrix(T);

  // for m = find(diag (T, -1))'
  for (int m = 0; m < n-1; m++)
    {
      // k = m:m+1
      const int m1 = m+1;
      if (T(m1,m) != 0.0)
	{
	  // d = eig(T(k,k))
	  const double b = (T(m,m) + T(m1,m1))/2;
	  const double c = T(m,m)*T(m1,m1) - T(m,m1)*T(m1,m);
	  const Complex d(b, sqrt(c - b*b));
	  
	  // cs = [ T(m+1,m+1)-d(1), -T(m+1,m) ]
	  Complex cs1 = T(m1,m1)-d;
	  double cs2 = -T(m1,m);
	  
	  // cs = cs / norm (cs)
	  const double norm_cs=sqrt(real(cs1*conj(cs1)) + cs2*cs2);
	  cs1 /= norm_cs;
	  cs2 /= norm_cs;
	  
	  // G = [ conj(cs(1)), cs(2); cs(2), -cs(1) ]
	  const Complex G11 = conj(cs1);
	  const Complex G22 = -cs1;
	  const Complex cG11 = cs1;
	  const Complex cG22 = conj(-cs1);
	  
	  // T (k, m:n) = G' * T (k, m:n)
	  for (int i=m; i < n; i++)
	    {
	      const Complex a = retT(m,i)*cG11 + retT(m1,i)*cs2;
	      retT(m1,i) = retT(m,i)*cs2 + retT(m1,i)*cG22; 
	      retT(m,i) = a;
	    }
	  
	  // T (1:m+1, k) = T (1:m+1, k) * G
	  for (int i=0; i <= m+1; i++)
	    {
	      const Complex a = retT(i,m)*G11 + retT(i,m1)*cs2;
	      retT(i,m1) = retT(i,m)*cs2 + retT(i,m1)*G22; 
	      retT(i,m) = a;
	    }
	  
	  // U (:, k) = U (:, k) * G
	  for (int i=0; i < n; i++)
	    {
	      const Complex a = retU(i,m)*G11 + retU(i,m1)*cs2;
	      retU(i,m1) = retU(i,m)*cs2 + retU(i,m1)*G22; 
	      retU(i,m) = a;
	    }
	  
	  // T (m+1,m) = 0
	  retT(m+1,m) = 0.0;
	}
    }
  // endfor
}

DEFUN_DLD(rsf2csf, args, nargout,
	  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{u}, @var{s} =} rsf2csf (@var{u}, @var{s})\n\
Converts real schur form (a quasi-triangular system with all real elements)\n\
into complex schur form (a pure triangular system which may contain complex\n\
elements). The resulting @var{u} and @var{s},  while completely different\n\
from what would be obtained with @var{a} slightly complex, still satisfy\n\
the identities\n\
@iftex\n\
@tex\n\
$S = U^T A U$\n\
@end tex\n\
@end iftex\n\
@ifinfo\n\
@code{s = u' * a * u}\n\
@end ifinfo\n\
and\n\
@iftex \n\
@tex\n\
$I = U U^T$\n\
@end tex\n\
@end iftex\n\
@ifinfo\n\
@code{I = u' * u}\n\
@end ifinfo\n\
@end deftypefn\n\
@seealso{schur}")
{
  octave_value_list retval;

  int nargin = args.length();
  if (nargin != 2 || nargout != 2)
    print_usage("rsf2csf");
  else
    {
      const Matrix U = args(0).matrix_value();
      const Matrix T = args(1).matrix_value();
      if (!error_state)
	{
	  if (U.rows() != U.columns() || T.rows() != T.columns() || 
	      T.rows() != U.rows())
	    error ("rsf2csf: improper U,T");
	  else
	    {
	      const int n = U.rows();
	      bool isreal=true;
	      for (int i = 0; i < n-1; i++)
		if (T(i,i+1) != 0.0) isreal = false;
	      if (isreal)
		{
		  retval(0) = U;
		  retval(1) = T;
		}
	      else
		{
		  ComplexMatrix retU, retT;
		  rsf2csf(U,T,retU,retT);
		  retval(0) = retU;
		  retval(1) = retT;
		}
	    }
	}
    }
    return retval;
}
