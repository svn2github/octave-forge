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
along with this program; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#if !defined (octave_FixedCMatrix_h)
#define octave_FixedCMatrix_h 1

#if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#pragma interface
#endif

#include <octave/MArray2.h>

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

typedef FixedPointComplex (*fc_fc_Mapper)(FixedPointComplex);

class
FixedComplexMatrix : public MArray2<FixedPointComplex>
{
public:

  FixedComplexMatrix (void) : MArray2<FixedPointComplex> () { }

  FixedComplexMatrix (int r, int c) : MArray2<FixedPointComplex> (r, c) { }

  FixedComplexMatrix (int r, int c, const FixedPointComplex val) :
    MArray2<FixedPointComplex> (r, c, val) { }

  FixedComplexMatrix (const MArray2<int> &is, const MArray2<int> &ds);

  FixedComplexMatrix (const Matrix &is, const Matrix &ds);

  FixedComplexMatrix (const ComplexMatrix &is, const ComplexMatrix &ds);

  FixedComplexMatrix (unsigned int is, unsigned int ds, 
		      const FixedComplexMatrix& a);

  FixedComplexMatrix (Complex is, Complex ds, const FixedComplexMatrix& a);

  FixedComplexMatrix (const MArray2<int> &is, const MArray2<int> &ds, 
		      const FixedComplexMatrix& a);

  FixedComplexMatrix (const Matrix &is, const Matrix &ds, 
		      const FixedComplexMatrix& a);

  FixedComplexMatrix (const ComplexMatrix &is, const ComplexMatrix &ds, 
		      const FixedComplexMatrix& a);

  FixedComplexMatrix (unsigned int is, unsigned int ds, const FixedMatrix& a);

  FixedComplexMatrix (Complex is, Complex ds, const FixedMatrix& a);

  FixedComplexMatrix (const MArray2<int> &is, const MArray2<int> &ds, 
		      const FixedMatrix& a);

  FixedComplexMatrix (const Matrix &is, const Matrix &ds, 
		      const FixedMatrix& a);

  FixedComplexMatrix (const ComplexMatrix &is, const ComplexMatrix &ds, 
		      const FixedMatrix& a);

  FixedComplexMatrix (unsigned int is, unsigned int ds, 
		      const ComplexMatrix& a);

  FixedComplexMatrix (Complex is, Complex ds, const ComplexMatrix& a);

  FixedComplexMatrix (const MArray2<int> &is, const MArray2<int> & ds, 
		      const ComplexMatrix& a);

  FixedComplexMatrix (const Matrix &is, const Matrix & ds, 
		      const ComplexMatrix& a);

  FixedComplexMatrix (const ComplexMatrix &is, const ComplexMatrix & ds, 
		      const ComplexMatrix& a);

  FixedComplexMatrix (unsigned int is, unsigned int ds, const Matrix& a);

  FixedComplexMatrix (Complex is, Complex ds, const Matrix& a);

  FixedComplexMatrix (const MArray2<int> &is, const MArray2<int> & ds, 
		      const Matrix& a);

  FixedComplexMatrix (const Matrix &is, const Matrix & ds, const Matrix& a);

  FixedComplexMatrix (const ComplexMatrix &is, const ComplexMatrix & ds, 
		      const Matrix& a);

  FixedComplexMatrix (unsigned int is, unsigned int ds,
		      const ComplexMatrix &a, const ComplexMatrix &b);

  FixedComplexMatrix (Complex is, Complex ds, const ComplexMatrix &a, 
		      const ComplexMatrix &b);

  FixedComplexMatrix (const MArray2<int> &is, const MArray2<int> &ds,
		      const ComplexMatrix &a, const ComplexMatrix &b);

  FixedComplexMatrix (const Matrix &is, const Matrix &ds,
		      const ComplexMatrix &a, const ComplexMatrix &b);

  FixedComplexMatrix (const ComplexMatrix &is, const ComplexMatrix &ds,
		      const ComplexMatrix &a, const ComplexMatrix &b);

  FixedComplexMatrix (const FixedMatrix& a);

  FixedComplexMatrix (const FixedMatrix& a, const FixedMatrix& b);

  FixedComplexMatrix (const FixedComplexMatrix& a) : 
    MArray2<FixedPointComplex> (a) { }

  FixedComplexMatrix (const MArray2<FixedPointComplex>& a) : 
    MArray2<FixedPointComplex> (a) { }

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
      MArray2<FixedPointComplex>::operator = (a);
      return *this;
    }

  bool operator == (const FixedComplexMatrix& a) const;
  bool operator != (const FixedComplexMatrix& a) const;

  bool is_hermitian (void) const;
  bool is_symmetric (void) const;

#ifdef HAVE_OLD_OCTAVE_CONCAT
  friend FixedComplexMatrix concat (const FixedComplexMatrix& ra, 
				    const FixedComplexMatrix& rb, 
				    const Array<int>& ra_idx);

  friend FixedComplexMatrix concat (const FixedComplexMatrix& ra, 
				    const FixedMatrix& rb, 
				    const Array<int>& ra_idx);

  friend FixedComplexMatrix concat (const FixedMatrix& ra, 
				    const FixedComplexMatrix& rb, 
				    const Array<int>& ra_idx);
#endif

#ifdef HAVE_OCTAVE_CONCAT
  FixedComplexMatrix concat (const FixedComplexMatrix& rb, 
			     const Array<int>& ra_idx);

  FixedComplexMatrix concat (const FixedMatrix& rb, 
			     const Array<int>& ra_idx);
#endif

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
  FixedComplexMatrix transpose (void) const { return MArray2<FixedPointComplex>::transpose (); }

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

  FixedComplexMatrix map (fc_fc_Mapper f) const;
  FixedComplexMatrix& apply (fc_fc_Mapper f);

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

  friend FixedComplexMatrix operator * (const FixedComplexColumnVector& a,
                                        const FixedComplexRowVector& b);
  friend FixedComplexMatrix operator * (const FixedComplexMatrix& a,
                                        const FixedComplexMatrix& b);

  friend FixedMatrix real (const FixedComplexMatrix &x);
  friend FixedMatrix imag (const FixedComplexMatrix &x);
  friend FixedComplexMatrix conj (const FixedComplexMatrix &x);

  friend FixedMatrix abs (const FixedComplexMatrix &x);
  friend FixedMatrix norm (const FixedComplexMatrix &x);
  friend FixedMatrix arg (const FixedComplexMatrix &x);
  friend FixedComplexMatrix polar (const FixedMatrix &r, const FixedMatrix &p);

  friend FixedComplexMatrix cos  (const FixedComplexMatrix &x);
  friend FixedComplexMatrix cosh  (const FixedComplexMatrix &x);
  friend FixedComplexMatrix sin  (const FixedComplexMatrix &x);
  friend FixedComplexMatrix sinh  (const FixedComplexMatrix &x);
  friend FixedComplexMatrix tan  (const FixedComplexMatrix &x);
  friend FixedComplexMatrix tanh  (const FixedComplexMatrix &x);

  friend FixedComplexMatrix sqrt  (const FixedComplexMatrix &x);
  friend FixedComplexMatrix pow  (const FixedComplexMatrix &a, const int b);
  friend FixedComplexMatrix pow  (const FixedComplexMatrix &a, const double b);
  friend FixedComplexMatrix pow  (const FixedComplexMatrix &a,
                                  const FixedPointComplex &b);
  friend FixedComplexMatrix pow  (const FixedComplexMatrix &a,
                                  const FixedComplexMatrix &b);
  friend FixedComplexMatrix exp  (const FixedComplexMatrix &x);
  friend FixedComplexMatrix log  (const FixedComplexMatrix &x);
  friend FixedComplexMatrix log10  (const FixedComplexMatrix &x);

  friend FixedComplexMatrix round (const FixedComplexMatrix &x);
  friend FixedComplexMatrix rint (const FixedComplexMatrix &x);
  friend FixedComplexMatrix floor (const FixedComplexMatrix &x);
  friend FixedComplexMatrix ceil (const FixedComplexMatrix &x);

  friend ComplexMatrix fixedpoint (const FixedComplexMatrix& x);
  friend ComplexMatrix sign (const FixedComplexMatrix& x);
  friend ComplexMatrix getintsize (const FixedComplexMatrix& x);
  friend ComplexMatrix getdecsize (const FixedComplexMatrix& x);
  friend ComplexMatrix getnumber (const FixedComplexMatrix& x);

  // i/o

  friend std::ostream& operator << (std::ostream& os,
                                    const FixedComplexMatrix& a);
  friend std::istream& operator >> (std::istream& is, FixedComplexMatrix& a);


  static FixedPointComplex resize_fill_value (void) 
      { return FixedPointComplex(); }

private:

  FixedComplexMatrix (FixedPointComplex *d, int r, int c) : 
    MArray2<FixedPointComplex> (d, r, c) { }
};

FixedComplexMatrix operator * (const FixedComplexColumnVector& a, 
				const FixedComplexRowVector& b);
FixedComplexMatrix operator * (const FixedComplexMatrix& a, 
				const FixedComplexMatrix& b);

FixedMatrix real (const FixedComplexMatrix &x);
FixedMatrix imag (const FixedComplexMatrix &x);
FixedComplexMatrix conj (const FixedComplexMatrix &x);

FixedMatrix abs (const FixedComplexMatrix &x);
FixedMatrix norm (const FixedComplexMatrix &x);
FixedMatrix arg (const FixedComplexMatrix &x);
FixedComplexMatrix polar (const FixedMatrix &r, const FixedMatrix &p);

FixedComplexMatrix cos  (const FixedComplexMatrix &x);
FixedComplexMatrix cosh  (const FixedComplexMatrix &x);
FixedComplexMatrix sin  (const FixedComplexMatrix &x);
FixedComplexMatrix sinh  (const FixedComplexMatrix &x);
FixedComplexMatrix tan  (const FixedComplexMatrix &x);
FixedComplexMatrix tanh  (const FixedComplexMatrix &x);

FixedComplexMatrix sqrt  (const FixedComplexMatrix &x);
FixedComplexMatrix pow  (const FixedComplexMatrix &a, const int b);
FixedComplexMatrix pow  (const FixedComplexMatrix &a, const double b);
FixedComplexMatrix pow  (const FixedComplexMatrix &a, 
				  const FixedPointComplex &b);
FixedComplexMatrix pow  (const FixedComplexMatrix &a, 
				  const FixedComplexMatrix &b);
FixedComplexMatrix exp  (const FixedComplexMatrix &x);
FixedComplexMatrix log  (const FixedComplexMatrix &x);
FixedComplexMatrix log10  (const FixedComplexMatrix &x);

FixedComplexMatrix round (const FixedComplexMatrix &x);
FixedComplexMatrix rint (const FixedComplexMatrix &x);
FixedComplexMatrix floor (const FixedComplexMatrix &x);
FixedComplexMatrix ceil (const FixedComplexMatrix &x);

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

std::ostream& operator << (std::ostream& os, 
			    const FixedComplexMatrix& a);
std::istream& operator >> (std::istream& is, FixedComplexMatrix& a);


FixedComplexMatrix min (FixedPointComplex d, 
		       const FixedComplexMatrix& m);
FixedComplexMatrix min (const FixedComplexMatrix& m, 
		       FixedPointComplex d);
FixedComplexMatrix min (const FixedComplexMatrix& a, 
		       const FixedComplexMatrix& b);

FixedComplexMatrix max (FixedPointComplex d,
		       const FixedComplexMatrix& m);
FixedComplexMatrix max (const FixedComplexMatrix& m,
		       FixedPointComplex d);
FixedComplexMatrix max (const FixedComplexMatrix& a,
		       const FixedComplexMatrix& b);

FixedComplexMatrix elem_pow (const FixedComplexMatrix &a,
			     const FixedComplexMatrix &b);
FixedComplexMatrix elem_pow (const FixedComplexMatrix &a,
			     const FixedPointComplex &b);
FixedComplexMatrix elem_pow (const FixedPointComplex &a,
			     const FixedComplexMatrix &b);


MS_CMP_OP_DECLS (FixedComplexMatrix, FixedPointComplex)
MS_BOOL_OP_DECLS (FixedComplexMatrix, FixedPointComplex)

SM_CMP_OP_DECLS (FixedPointComplex, FixedComplexMatrix)
SM_BOOL_OP_DECLS (FixedPointComplex, FixedComplexMatrix)

MM_CMP_OP_DECLS (FixedComplexMatrix, FixedComplexMatrix)
MM_BOOL_OP_DECLS (FixedComplexMatrix, FixedComplexMatrix)

MARRAY_FORWARD_DEFS (MArray2, FixedComplexMatrix, FixedPointComplex)

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
