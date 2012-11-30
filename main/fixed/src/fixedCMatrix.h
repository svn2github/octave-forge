/*

Copyright (C) 2003 Motorola Inc
Copyright (C) 2003 David Bateman

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#if !defined (octave_FixedCMatrix_h)
#define octave_FixedCMatrix_h 1

#include <octave/MArray.h>

#include <octave/mx-defs.h>
#include <octave/mx-op-defs.h>
#include <octave/data-conv.h>
#include <octave/mach-info.h>
#include <octave/boolMatrix.h>
#include <octave/dMatrix.h>
#include <octave/CMatrix.h>

#include "int/fixed.h"
#include "fixedMatrix.h"
#include "fixedComplex.h"

#if !defined(octave_FixedCColVector_h)
class FixedComplexColumnVector;
#endif
#if !defined(octave_FixedCRowVector_h)
class FixedComplexRowVector;
#endif

typedef FixedPointComplex (*fpc_fpc_Mapper)(FixedPointComplex);

class
OCTAVE_FIXED_API
FixedComplexMatrix : public MArray<FixedPointComplex>
{
public:

  FixedComplexMatrix (void) : MArray<FixedPointComplex> () { }

  FixedComplexMatrix (const dim_vector& dv) : MArray<FixedPointComplex> (dv) { }

  FixedComplexMatrix (int r, int c)
    : MArray<FixedPointComplex> (dim_vector (r, c)) { }

  FixedComplexMatrix (int r, int c, const FixedPointComplex val) 
    : MArray<FixedPointComplex> (dim_vector (r, c), val) { }

  FixedComplexMatrix (const MArray<int> &is, const MArray<int> &ds);

  FixedComplexMatrix (const Matrix &is, const Matrix &ds);

  FixedComplexMatrix (const ComplexMatrix &is, const ComplexMatrix &ds);

  FixedComplexMatrix (unsigned int is, unsigned int ds, 
		      const FixedComplexMatrix& a);

  FixedComplexMatrix (Complex is, Complex ds, const FixedComplexMatrix& a);

  FixedComplexMatrix (const MArray<int> &is, const MArray<int> &ds, 
		      const FixedComplexMatrix& a);

  FixedComplexMatrix (const Matrix &is, const Matrix &ds, 
		      const FixedComplexMatrix& a);

  FixedComplexMatrix (const ComplexMatrix &is, const ComplexMatrix &ds, 
		      const FixedComplexMatrix& a);

  FixedComplexMatrix (unsigned int is, unsigned int ds, const FixedMatrix& a);

  FixedComplexMatrix (Complex is, Complex ds, const FixedMatrix& a);

  FixedComplexMatrix (const MArray<int> &is, const MArray<int> &ds, 
		      const FixedMatrix& a);

  FixedComplexMatrix (const Matrix &is, const Matrix &ds, 
		      const FixedMatrix& a);

  FixedComplexMatrix (const ComplexMatrix &is, const ComplexMatrix &ds, 
		      const FixedMatrix& a);

  FixedComplexMatrix (unsigned int is, unsigned int ds, 
		      const ComplexMatrix& a);

  FixedComplexMatrix (Complex is, Complex ds, const ComplexMatrix& a);

  FixedComplexMatrix (const MArray<int> &is, const MArray<int> & ds, 
		      const ComplexMatrix& a);

  FixedComplexMatrix (const Matrix &is, const Matrix & ds, 
		      const ComplexMatrix& a);

  FixedComplexMatrix (const ComplexMatrix &is, const ComplexMatrix & ds, 
		      const ComplexMatrix& a);

  FixedComplexMatrix (unsigned int is, unsigned int ds, const Matrix& a);

  FixedComplexMatrix (Complex is, Complex ds, const Matrix& a);

  FixedComplexMatrix (const MArray<int> &is, const MArray<int> & ds, 
		      const Matrix& a);

  FixedComplexMatrix (const Matrix &is, const Matrix & ds, const Matrix& a);

  FixedComplexMatrix (const ComplexMatrix &is, const ComplexMatrix & ds, 
		      const Matrix& a);

  FixedComplexMatrix (unsigned int is, unsigned int ds,
		      const ComplexMatrix &a, const ComplexMatrix &b);

  FixedComplexMatrix (Complex is, Complex ds, const ComplexMatrix &a, 
		      const ComplexMatrix &b);

  FixedComplexMatrix (const MArray<int> &is, const MArray<int> &ds,
		      const ComplexMatrix &a, const ComplexMatrix &b);

  FixedComplexMatrix (const Matrix &is, const Matrix &ds,
		      const ComplexMatrix &a, const ComplexMatrix &b);

  FixedComplexMatrix (const ComplexMatrix &is, const ComplexMatrix &ds,
		      const ComplexMatrix &a, const ComplexMatrix &b);

  FixedComplexMatrix (const FixedMatrix& a);

  FixedComplexMatrix (const FixedMatrix& a, const FixedMatrix& b);

  FixedComplexMatrix (const FixedComplexMatrix& a) : 
    MArray<FixedPointComplex> (a) { }

  FixedComplexMatrix (const MArray<FixedPointComplex>& a) : 
    MArray<FixedPointComplex> (a) { }

  FixedComplexMatrix (const Array<FixedPointComplex>& a) : 
    MArray<FixedPointComplex> (a) { }

  explicit FixedComplexMatrix (const FixedComplexRowVector& rv);

  FixedComplexMatrix (const FixedRowVector& rv);

  explicit FixedComplexMatrix (const FixedComplexColumnVector& cv);

  FixedComplexMatrix (const FixedColumnVector& cv);

  ComplexMatrix sign (void) const;
  ComplexMatrix getdecsize (void) const;
  ComplexMatrix getintsize (void) const;
  ComplexMatrix getnumber (void) const;
  ComplexMatrix fixedpoint (void) const;
  FixedComplexMatrix chdecsize (const Complex n);
  FixedComplexMatrix chdecsize (const ComplexMatrix &n);
  FixedComplexMatrix chintsize (const Complex n);
  FixedComplexMatrix chintsize (const ComplexMatrix &n);
  FixedComplexMatrix incdecsize (const Complex n);
  FixedComplexMatrix incdecsize (const ComplexMatrix &n);
  FixedComplexMatrix incdecsize ();
  FixedComplexMatrix incintsize (const Complex n);
  FixedComplexMatrix incintsize (const ComplexMatrix &n);
  FixedComplexMatrix incintsize ();

  FixedComplexMatrix& operator = (const FixedComplexMatrix& a)
    {
      MArray<FixedPointComplex>::operator = (a);
      return *this;
    }

  bool operator == (const FixedComplexMatrix& a) const;
  bool operator != (const FixedComplexMatrix& a) const;

  bool is_hermitian (void) const;
  bool is_symmetric (void) const;

  FixedComplexMatrix concat (const FixedComplexMatrix& rb, 
			     const Array<int>& ra_idx);

  FixedComplexMatrix concat (const FixedMatrix& rb, 
			     const Array<int>& ra_idx);

  // destructive insert/delete/reorder operations

  FixedComplexMatrix& insert (const FixedComplexMatrix& a, int r, int c);
  FixedComplexMatrix& insert (const FixedComplexRowVector& a, int r, int c);
  FixedComplexMatrix& insert (const FixedComplexColumnVector& a, int r, int c);

  FixedComplexMatrix& fill (FixedPointComplex val);
  FixedComplexMatrix& fill (FixedPointComplex val, int r1, int c1, int r2, int c2);

  FixedComplexMatrix append (const FixedComplexMatrix& a) const;
  FixedComplexMatrix append (const FixedComplexRowVector& a) const;
  FixedComplexMatrix append (const FixedComplexColumnVector& a) const;

  FixedComplexMatrix stack (const FixedComplexMatrix& a) const;
  FixedComplexMatrix stack (const FixedComplexRowVector& a) const;
  FixedComplexMatrix stack (const FixedComplexColumnVector& a) const;

  FixedComplexMatrix hermitian (void) const;
  FixedComplexMatrix transpose (void) const { return MArray<FixedPointComplex>::transpose (); }

  // resize is the destructive equivalent for this one

  FixedComplexMatrix extract (int r1, int c1, int r2, int c2) const;

  FixedComplexMatrix extract_n (int r1, int c1, int nr, int nc) const;

  // extract row or column i.

  FixedComplexRowVector row (int i) const;
  FixedComplexRowVector row (char *s) const;

  FixedComplexColumnVector column (int i) const;
  FixedComplexColumnVector column (char *s) const;

  // unary operations

  FixedComplexMatrix operator ! (void) const;

  // other operations

  FixedComplexMatrix map (fpc_fpc_Mapper f) const;
  FixedComplexMatrix& apply (fpc_fpc_Mapper f);

  bool all_elements_are_real (void) const;

  boolMatrix all (int dim = -1) const;
  boolMatrix any (int dim = -1) const;

  FixedComplexMatrix cumprod (int dim = -1) const;
  FixedComplexMatrix cumsum (int dim = -1) const;
  FixedComplexMatrix prod (int dim = -1) const;
  FixedComplexMatrix sum (int dim = -1) const;
  FixedComplexMatrix sumsq (int dim = -1) const;
  FixedComplexMatrix abs (void) const;

  FixedComplexColumnVector diag (void) const;
  FixedComplexColumnVector diag (int k) const;

  FixedComplexColumnVector row_min (void) const;
  FixedComplexColumnVector row_max (void) const;

  FixedComplexColumnVector row_min (Array<int>& index) const;
  FixedComplexColumnVector row_max (Array<int>& index) const;

  FixedComplexRowVector column_min (void) const;
  FixedComplexRowVector column_max (void) const;

  FixedComplexRowVector column_min (Array<int>& index) const;
  FixedComplexRowVector column_max (Array<int>& index) const;

  friend OCTAVE_FIXED_API FixedComplexMatrix operator * (const FixedComplexColumnVector& a,
                                        const FixedComplexRowVector& b);
  friend OCTAVE_FIXED_API FixedComplexMatrix operator * (const FixedComplexMatrix& a,
                                        const FixedComplexMatrix& b);

  friend OCTAVE_FIXED_API FixedMatrix real (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedMatrix imag (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedComplexMatrix conj (const FixedComplexMatrix &x);

  friend OCTAVE_FIXED_API FixedMatrix abs (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedMatrix norm (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedMatrix arg (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedComplexMatrix polar (const FixedMatrix &r, const FixedMatrix &p);

  friend OCTAVE_FIXED_API FixedComplexMatrix cos  (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedComplexMatrix cosh  (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedComplexMatrix sin  (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedComplexMatrix sinh  (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedComplexMatrix tan  (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedComplexMatrix tanh  (const FixedComplexMatrix &x);

  friend OCTAVE_FIXED_API FixedComplexMatrix sqrt  (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedComplexMatrix pow  (const FixedComplexMatrix &a, const int b);
  friend OCTAVE_FIXED_API FixedComplexMatrix pow  (const FixedComplexMatrix &a, const double b);
  friend OCTAVE_FIXED_API FixedComplexMatrix pow  (const FixedComplexMatrix &a,
                                  const FixedPointComplex &b);
  friend OCTAVE_FIXED_API FixedComplexMatrix pow  (const FixedComplexMatrix &a,
                                  const FixedComplexMatrix &b);
  friend OCTAVE_FIXED_API FixedComplexMatrix exp  (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedComplexMatrix log  (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedComplexMatrix log10  (const FixedComplexMatrix &x);

  friend OCTAVE_FIXED_API FixedComplexMatrix round (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedComplexMatrix rint (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedComplexMatrix floor (const FixedComplexMatrix &x);
  friend OCTAVE_FIXED_API FixedComplexMatrix ceil (const FixedComplexMatrix &x);

  friend OCTAVE_FIXED_API ComplexMatrix fixedpoint (const FixedComplexMatrix& x);
  friend OCTAVE_FIXED_API ComplexMatrix sign (const FixedComplexMatrix& x);
  friend OCTAVE_FIXED_API ComplexMatrix getintsize (const FixedComplexMatrix& x);
  friend OCTAVE_FIXED_API ComplexMatrix getdecsize (const FixedComplexMatrix& x);
  friend OCTAVE_FIXED_API ComplexMatrix getnumber (const FixedComplexMatrix& x);

  // i/o

  friend OCTAVE_FIXED_API std::ostream& operator << (std::ostream& os,
                                    const FixedComplexMatrix& a);
  friend OCTAVE_FIXED_API std::istream& operator >> (std::istream& is, FixedComplexMatrix& a);


};

OCTAVE_FIXED_API FixedComplexMatrix operator * (const FixedComplexColumnVector& a, 
				const FixedComplexRowVector& b);
OCTAVE_FIXED_API FixedComplexMatrix operator * (const FixedComplexMatrix& a, 
				const FixedComplexMatrix& b);

OCTAVE_FIXED_API FixedMatrix real (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedMatrix imag (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedComplexMatrix conj (const FixedComplexMatrix &x);

OCTAVE_FIXED_API FixedMatrix abs (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedMatrix norm (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedMatrix arg (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedComplexMatrix polar (const FixedMatrix &r, const FixedMatrix &p);

OCTAVE_FIXED_API FixedComplexMatrix cos  (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedComplexMatrix cosh  (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedComplexMatrix sin  (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedComplexMatrix sinh  (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedComplexMatrix tan  (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedComplexMatrix tanh  (const FixedComplexMatrix &x);

OCTAVE_FIXED_API FixedComplexMatrix sqrt  (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedComplexMatrix pow  (const FixedComplexMatrix &a, const int b);
OCTAVE_FIXED_API FixedComplexMatrix pow  (const FixedComplexMatrix &a, const double b);
OCTAVE_FIXED_API FixedComplexMatrix pow  (const FixedComplexMatrix &a, 
				  const FixedPointComplex &b);
OCTAVE_FIXED_API FixedComplexMatrix pow  (const FixedComplexMatrix &a, 
				  const FixedComplexMatrix &b);
OCTAVE_FIXED_API FixedComplexMatrix exp  (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedComplexMatrix log  (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedComplexMatrix log10  (const FixedComplexMatrix &x);

OCTAVE_FIXED_API FixedComplexMatrix round (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedComplexMatrix rint (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedComplexMatrix floor (const FixedComplexMatrix &x);
OCTAVE_FIXED_API FixedComplexMatrix ceil (const FixedComplexMatrix &x);

inline ComplexMatrix fixedpoint (const FixedComplexMatrix& x) 
     { return x.fixedpoint(); }
inline ComplexMatrix sign (const FixedComplexMatrix& x) 
     { return x.sign(); }
inline ComplexMatrix getintsize (const FixedComplexMatrix& x) 
     { return x.getintsize(); }
inline ComplexMatrix getdecsize (const FixedComplexMatrix& x) 
     { return x.getdecsize(); }
inline ComplexMatrix getnumber (const FixedComplexMatrix& x) 
     { return x.getnumber(); }

OCTAVE_FIXED_API std::ostream& operator << (std::ostream& os, 
			    const FixedComplexMatrix& a);
OCTAVE_FIXED_API std::istream& operator >> (std::istream& is, FixedComplexMatrix& a);


OCTAVE_FIXED_API FixedComplexMatrix min (FixedPointComplex d, 
		       const FixedComplexMatrix& m);
OCTAVE_FIXED_API FixedComplexMatrix min (const FixedComplexMatrix& m, 
		       FixedPointComplex d);
OCTAVE_FIXED_API FixedComplexMatrix min (const FixedComplexMatrix& a, 
		       const FixedComplexMatrix& b);

OCTAVE_FIXED_API FixedComplexMatrix max (FixedPointComplex d,
		       const FixedComplexMatrix& m);
OCTAVE_FIXED_API FixedComplexMatrix max (const FixedComplexMatrix& m,
		       FixedPointComplex d);
OCTAVE_FIXED_API FixedComplexMatrix max (const FixedComplexMatrix& a,
		       const FixedComplexMatrix& b);

OCTAVE_FIXED_API FixedComplexMatrix elem_pow (const FixedComplexMatrix &a,
			     const FixedComplexMatrix &b);
OCTAVE_FIXED_API FixedComplexMatrix elem_pow (const FixedComplexMatrix &a,
			     const FixedPointComplex &b);
OCTAVE_FIXED_API FixedComplexMatrix elem_pow (const FixedPointComplex &a,
			     const FixedComplexMatrix &b);


MS_CMP_OP_DECLS (FixedComplexMatrix, FixedPointComplex, )
MS_BOOL_OP_DECLS (FixedComplexMatrix, FixedPointComplex, )

SM_CMP_OP_DECLS (FixedPointComplex, FixedComplexMatrix, )
SM_BOOL_OP_DECLS (FixedPointComplex, FixedComplexMatrix, )

MM_CMP_OP_DECLS (FixedComplexMatrix, FixedComplexMatrix, )
MM_BOOL_OP_DECLS (FixedComplexMatrix, FixedComplexMatrix, )

MARRAY_FORWARD_DEFS (MArray, FixedComplexMatrix, FixedPointComplex)

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
