/*

Copyright (C) 1996, 1997 John W. Eaton
Copyright (C) 2006 Pascal Dupuis
This file is part of Octave.

Octave is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

Octave is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, write to the Free
Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
02110-1301, USA.

*/

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

#include <iostream>

#include "CmplxGSVD.h"
#include "f77-fcn.h"
#include "lo-error.h"

extern "C"
{
  F77_RET_T
  F77_FUNC (zggsvd, ZGGSVD)  
   (
     F77_CONST_CHAR_ARG_DECL, 	// JOBU    (input) CHARACTER*1
     F77_CONST_CHAR_ARG_DECL, 	// JOBV    (input) CHARACTER*1
     F77_CONST_CHAR_ARG_DECL, 	// JOBQ    (input) CHARACTER*1
     const octave_idx_type&,	// M       (input) INTEGER
     const octave_idx_type&,	// N       (input) INTEGER
     const octave_idx_type&,	// P       (input) INTEGER
     octave_idx_type &, 	// K       (output) INTEGER
     octave_idx_type &,		// L       (output) INTEGER
     Complex*,			// A       (input/output) COMPLEX*16 array, dimension (LDA,N)
     const octave_idx_type&, 	// LDA     (input) INTEGER
     Complex*, 			// B       (input/output) COMPLEX*16 array, dimension (LDB,N)
     const octave_idx_type&, 	// LDB     (input) INTEGER
     double*, 			// ALPHA   (output) DOUBLE PRECISION array, dimension (N)
     double*, 			// BETA    (output) DOUBLE PRECISION array, dimension (N)
     Complex*,			// U       (output) COMPLEX*16 array, dimension (LDU,M)
     const octave_idx_type&,	// LDU     (input) INTEGER 
     Complex*, 			// V       (output) COMPLEX*16 array, dimension (LDV,P)
     const octave_idx_type&,	// LDV     (input) INTEGER
     Complex*,			// Q       (output) COMPLEX*16 array, dimension (LDQ,N) 
     const octave_idx_type&,	// LDQ     (input) INTEGER
     Complex*, 			// WORK    (workspace) COMPLEX*16 array
     double*,			// RWORK   (workspace) DOUBLE PRECISION array
     int*,	 		// IWORK   (workspace/output) INTEGER array, dimension (N)
     octave_idx_type&		// INFO    (output)INTEGER
     F77_CHAR_ARG_LEN_DECL
     F77_CHAR_ARG_LEN_DECL
     F77_CHAR_ARG_LEN_DECL
     );
}

ComplexMatrix
ComplexGSVD::left_singular_matrix_A (void) const
{
  if (type_computed == GSVD::sigma_only)
    {
      (*current_liboctave_error_handler)
	("dbleGSVD: U not computed because type == GSVD::sigma_only");
      return ComplexMatrix ();
    }
  else
    return left_smA;
}

ComplexMatrix
ComplexGSVD::left_singular_matrix_B (void) const
{
  if (type_computed == GSVD::sigma_only)
    {
      (*current_liboctave_error_handler)
	("dbleGSVD: V not computed because type == GSVD::sigma_only");
      return ComplexMatrix ();
    }
  else
    return left_smB;
}

ComplexMatrix
ComplexGSVD::right_singular_matrix (void) const
{
  if (type_computed == GSVD::sigma_only)
    {
      (*current_liboctave_error_handler)
	("dbleSVD: X not computed because type == GSVD::sigma_only");
      return ComplexMatrix ();
    }
  else
    return right_sm;
}

ComplexMatrix
ComplexGSVD::R_matrix (void) const
{
  if (type_computed == GSVD::sigma_only)
    {
      (*current_liboctave_error_handler)
	("dbleSVD: R not computed because type == GSVD::sigma_only");
      return ComplexMatrix ();
    }
  else
    return R;
}

octave_idx_type
ComplexGSVD::init (const ComplexMatrix& a, const ComplexMatrix& b, 
		   GSVD::type gsvd_type)
{
  octave_idx_type info;

  octave_idx_type m = a.rows ();
  octave_idx_type n = a.cols ();
  octave_idx_type p = b.rows ();
  
  R = a;
  Complex *tmp_dataA = R.fortran_vec ();
  
  ComplexMatrix btmp = b;
  Complex *tmp_dataB = btmp.fortran_vec ();

  // octave_idx_type min_mn = m < n ? m : n;

  char jobu = 'U';
  char jobv = 'V';
  char jobq = 'Q';

  octave_idx_type nrow_u = m;
  octave_idx_type nrow_v = p;
  octave_idx_type nrow_q = n;

  octave_idx_type k, l;

  switch (gsvd_type)
    {

    case GSVD::sigma_only:

      // Note:  for this case, both jobu and jobv should be 'N', but
      // there seems to be a bug in dgesvd from Lapack V2.0.  To
      // demonstrate the bug, set both jobu and jobv to 'N' and find
      // the singular values of [eye(3), eye(3)].  The result is
      // [-sqrt(2), -sqrt(2), -sqrt(2)].
      //
      // For Lapack 3.0, this problem seems to be fixed.

      jobu = 'N';
      jobv = 'N';
      jobq = 'N';
      nrow_u = nrow_v = nrow_q = 1;
      break;

    default:
      break;
    }

  type_computed = gsvd_type;

  if (! (jobu == 'N' || jobu == 'O')) {
    left_smA.resize (nrow_u, m);
  }
  
  Complex *u = left_smA.fortran_vec ();

  if (! (jobv == 'N' || jobv == 'O')) {
    left_smB.resize (nrow_v, p);
  }

  Complex *v = left_smB.fortran_vec ();

  sigmaA.resize (n, n);
  // double *c_vec  = sigmaA.fortran_vec ();

  sigmaB.resize (n, n);
  // double *s_vec  = sigmaB.fortran_vec ();

  if (! (jobq == 'N' || jobq == 'O')) {
    right_sm.resize (nrow_q, n);
  }
  Complex *q = right_sm.fortran_vec ();  
  
  octave_idx_type lwork = 3*n;
  lwork = lwork > m ? lwork : m;
  lwork = (lwork > p ? lwork : p) + n;

  Array<Complex>  work (lwork);
  Array<double>   alpha (n);
  Array<double>   beta (n);
  Array<double>   rwork(2*n);
  Array<int>      iwork (n);

  F77_XFCN (zggsvd, ZGGSVD, (F77_CONST_CHAR_ARG2 (&jobu, 1),
			     F77_CONST_CHAR_ARG2 (&jobv, 1),
			     F77_CONST_CHAR_ARG2 (&jobq, 1),
			     m, n, p, k, l, tmp_dataA, m, 
			     tmp_dataB, p, alpha.fortran_vec (),
			     beta.fortran_vec (), u, nrow_u, 
			     v, nrow_v, q, nrow_q, work.fortran_vec (), 
			     rwork.fortran_vec (), iwork.fortran_vec (), 
			     info
			     F77_CHAR_ARG_LEN (1)
			     F77_CHAR_ARG_LEN (1)
			     F77_CHAR_ARG_LEN (1)));
  
  if (f77_exception_encountered)
    (*current_liboctave_error_handler) ("unrecoverable error in zggsvd");

  if (info < 0) {
    (*current_liboctave_error_handler) ("zggsvd.f: argument %d illegal", -info);
  }  else { 
    if (info > 0) {
      (*current_liboctave_error_handler) ("zggsvd.f: Jacobi-type procedure failed to converge."); 
    } else {
      octave_idx_type i;
      for (i = 0; i < k; i++) {
	sigmaA.xelem(i, i) = 1.0;
	sigmaB.xelem(i, i) = 0.0;
      }
      if (m-k-l >= 0) { 
	for (i = k; i < l; i++) {
	  sigmaA.xelem(i, i) = alpha.elem(i);
	  sigmaB.xelem(i, i) = beta.elem(i);
	} 
      } else {
	for (i = k; i < m; i++) {
	  sigmaA.xelem(i, i) = alpha.elem(i);
	  sigmaB.xelem(i, i) = beta.elem(i);
	}
	for (i = k; i < m; i++) {
          sigmaA.xelem(i, i) = alpha.elem(i);
          sigmaB.xelem(i, i) = beta.elem(i);
        }
	for (i = m; i < k+l; i++) {
          sigmaA.xelem(i, i) = 0.0;
          sigmaB.xelem(i, i) = 1.0;;
        }
      }
    }
  }
  return info;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
