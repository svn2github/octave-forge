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

#if !defined (octave_FixedMatrix_h)
#define octave_FixedMatrix_h 1

#include <octave/MArray2.h>

#include <octave/mx-defs.h>
#include <octave/mx-op-defs.h>
#include <octave/data-conv.h>
#include <octave/mach-info.h>
#include <octave/boolMatrix.h>
#include <octave/dMatrix.h>

#include "int/fixed.h"

class FixedComplexMatrix;

#if !defined(octave_FixedColVector_h)
class FixedColumnVector;
#endif
#if !defined(octave_FixedRowVector_h)
class FixedRowVector;
#endif

typedef FixedPoint (*f_f_Mapper)(FixedPoint);

class
FixedMatrix : public MArray2<FixedPoint>
{
public:

  FixedMatrix (void) : MArray2<FixedPoint> () { }

  FixedMatrix (int r, int c) : MArray2<FixedPoint> (r, c) { }

  FixedMatrix (int r, int c, const FixedPoint val) : MArray2<FixedPoint> (r, c, val) { }

  FixedMatrix (const MArray2<int> &is, const MArray2<int> &ds);

  FixedMatrix (const Matrix &is, const Matrix &ds);

  FixedMatrix (unsigned int is, unsigned int ds, const FixedMatrix& a);

  FixedMatrix (const MArray2<int> &is, const MArray2<int> &ds, 
	       const FixedMatrix& a);

  FixedMatrix (const Matrix &is, const Matrix &ds, const FixedMatrix& a);

  FixedMatrix (unsigned int is, unsigned int ds, const Matrix& a);

  FixedMatrix (const MArray2<int> &is, const MArray2<int> &ds, 
	       const Matrix& a);

  FixedMatrix (const Matrix &is, const Matrix &ds, const Matrix& a);

  FixedMatrix (unsigned int is, unsigned int ds, const Matrix& a, 
	       const Matrix& b);

  FixedMatrix (const MArray2<int> &is, const MArray2<int> &ds, 
	       const Matrix& a, const Matrix& b);

  FixedMatrix (const Matrix &is, const Matrix &ds, const Matrix& a, 
	       const Matrix& b);

  FixedMatrix (const MArray2<int> &a);

  FixedMatrix (const Matrix &a);

  FixedMatrix (const FixedMatrix& a) : MArray2<FixedPoint> (a) { }
  FixedMatrix (const MArray2<FixedPoint>& a) : MArray2<FixedPoint> (a) { }

  explicit FixedMatrix (const FixedRowVector& rv);

  explicit FixedMatrix (const FixedColumnVector& cv);

  Matrix sign (void) const;
  Matrix signbit (void) const;
  Matrix getdecsize (void) const;
  Matrix getintsize (void) const;
  Matrix getnumber (void) const;
  Matrix fixedpoint (void) const;
  FixedMatrix chdecsize (const double n);
  FixedMatrix chdecsize (const Matrix &n);
  FixedMatrix chintsize (const double n);
  FixedMatrix chintsize (const Matrix &n);
  FixedMatrix incdecsize (const double n);
  FixedMatrix incdecsize (const Matrix &n);
  FixedMatrix incdecsize ();
  FixedMatrix incintsize (const double n);
  FixedMatrix incintsize (const Matrix &n);
  FixedMatrix incintsize ();

  FixedMatrix& operator = (const FixedMatrix& a)
    {
      MArray2<FixedPoint>::operator = (a);
      return *this;
    }

  bool operator == (const FixedMatrix& a) const;
  bool operator != (const FixedMatrix& a) const;

  bool is_symmetric (void) const;

  FixedMatrix concat (const FixedMatrix& rb, const Array<int>& ra_idx);
  FixedComplexMatrix concat (const FixedComplexMatrix& rb, 
			     const Array<int>& ra_idx);

  // destructive insert/delete/reorder operations

  FixedMatrix& insert (const FixedMatrix& a, int r, int c);
  FixedMatrix& insert (const FixedRowVector& a, int r, int c);
  FixedMatrix& insert (const FixedColumnVector& a, int r, int c);

  FixedMatrix& fill (FixedPoint val);
  FixedMatrix& fill (FixedPoint val, int r1, int c1, int r2, int c2);

  FixedMatrix append (const FixedMatrix& a) const;
  FixedMatrix append (const FixedRowVector& a) const;
  FixedMatrix append (const FixedColumnVector& a) const;

  FixedMatrix stack (const FixedMatrix& a) const;
  FixedMatrix stack (const FixedRowVector& a) const;
  FixedMatrix stack (const FixedColumnVector& a) const;

  FixedMatrix transpose (void) const 
       { return MArray2<FixedPoint>::transpose (); }

  // resize is the destructive equivalent for this one

  FixedMatrix extract (int r1, int c1, int r2, int c2) const;

  FixedMatrix extract_n (int r1, int c1, int nr, int nc) const;

  // extract row or column i.

  FixedRowVector row (int i) const;
  FixedRowVector row (char *s) const;

  FixedColumnVector column (int i) const;
  FixedColumnVector column (char *s) const;

  // unary operations

  FixedMatrix operator ! (void) const;

  // other operations

  FixedMatrix map (f_f_Mapper f) const;
  FixedMatrix& apply (f_f_Mapper f);

  boolMatrix all (int dim = -1) const;
  boolMatrix any (int dim = -1) const;

  FixedMatrix cumprod (int dim = -1) const;
  FixedMatrix cumsum (int dim = -1) const;
  FixedMatrix prod (int dim = -1) const;
  FixedMatrix sum (int dim = -1) const;
  FixedMatrix sumsq (int dim = -1) const;
  FixedMatrix abs (void) const;

  FixedColumnVector diag (void) const;
  FixedColumnVector diag (int k) const;

  FixedColumnVector row_min (void) const;
  FixedColumnVector row_max (void) const;

  FixedColumnVector row_min (Array<int>& index) const;
  FixedColumnVector row_max (Array<int>& index) const;

  FixedRowVector column_min (void) const;
  FixedRowVector column_max (void) const;

  FixedRowVector column_min (Array<int>& index) const;
  FixedRowVector column_max (Array<int>& index) const;

  friend FixedMatrix operator * (const FixedColumnVector& a, const FixedRowVector& b);
  friend FixedMatrix operator * (const FixedMatrix& a, const FixedMatrix& b);

  friend FixedMatrix real (const FixedMatrix &x);
  friend FixedMatrix imag (const FixedMatrix &x);
  friend FixedMatrix conj (const FixedMatrix &x);

  friend FixedMatrix abs (const FixedMatrix &x);
  friend FixedMatrix cos  (const FixedMatrix &x);
  friend FixedMatrix cosh  (const FixedMatrix &x);
  friend FixedMatrix sin  (const FixedMatrix &x);
  friend FixedMatrix sinh  (const FixedMatrix &x);
  friend FixedMatrix tan  (const FixedMatrix &x);
  friend FixedMatrix tanh  (const FixedMatrix &x);

  friend FixedMatrix sqrt  (const FixedMatrix &x);
  friend FixedMatrix pow  (const FixedMatrix &a, const int b);
  friend FixedMatrix pow  (const FixedMatrix &a, const double b);
  friend FixedMatrix pow  (const FixedMatrix &a, const FixedPoint &b);
  friend FixedMatrix pow  (const FixedMatrix &a, const FixedMatrix &b);
  friend FixedMatrix exp  (const FixedMatrix &x);
  friend FixedMatrix log  (const FixedMatrix &x);
  friend FixedMatrix log10  (const FixedMatrix &x);

  friend FixedMatrix atan2 (const FixedMatrix &x, const FixedMatrix &y);

  friend FixedMatrix round (const FixedMatrix &x);
  friend FixedMatrix rint (const FixedMatrix &x);
  friend FixedMatrix floor (const FixedMatrix &x);
  friend FixedMatrix ceil (const FixedMatrix &x);

  friend Matrix fixedpoint (const FixedMatrix& x);
  friend Matrix sign (const FixedMatrix& x);
  friend Matrix signbit (const FixedMatrix& x);
  friend Matrix getdecsize (const FixedMatrix& x);
  friend Matrix getintsize (const FixedMatrix& x);
  friend Matrix getnumber (const FixedMatrix& x);

  // i/o

  friend std::ostream& operator << (std::ostream& os, const FixedMatrix& a);
  friend std::istream& operator >> (std::istream& is, FixedMatrix& a);

  static FixedPoint resize_fill_value (void) { return FixedPoint(); }

private:

  FixedMatrix (FixedPoint *d, int r, int c) : MArray2<FixedPoint> (d, r, c) { }
};

FixedMatrix operator * (const FixedColumnVector& a, const FixedRowVector& b);
FixedMatrix operator * (const FixedMatrix& a, const FixedMatrix& b);

FixedMatrix real (const FixedMatrix &x);
FixedMatrix imag (const FixedMatrix &x);
FixedMatrix conj (const FixedMatrix &x);

FixedMatrix abs (const FixedMatrix &x);
FixedMatrix cos  (const FixedMatrix &x);
FixedMatrix cosh  (const FixedMatrix &x);
FixedMatrix sin  (const FixedMatrix &x);
FixedMatrix sinh  (const FixedMatrix &x);
FixedMatrix tan  (const FixedMatrix &x);
FixedMatrix tanh  (const FixedMatrix &x);

FixedMatrix sqrt  (const FixedMatrix &x);
FixedMatrix pow  (const FixedMatrix &a, const int b);
FixedMatrix pow  (const FixedMatrix &a, const double b);
FixedMatrix pow  (const FixedMatrix &a, const FixedPoint &b);
FixedMatrix pow  (const FixedMatrix &a, const FixedMatrix &b);
FixedMatrix exp  (const FixedMatrix &x);
FixedMatrix log  (const FixedMatrix &x);
FixedMatrix log10  (const FixedMatrix &x);

FixedMatrix atan2 (const FixedMatrix &x, const FixedMatrix &y);

FixedMatrix round (const FixedMatrix &x);
FixedMatrix rint (const FixedMatrix &x);
FixedMatrix floor (const FixedMatrix &x);
FixedMatrix ceil (const FixedMatrix &x);

inline Matrix fixedpoint (const FixedMatrix& x) { return x.fixedpoint(); }
inline Matrix sign (const FixedMatrix& x) { return x.sign(); }
inline Matrix signbit (const FixedMatrix& x) { return x.signbit(); }
inline Matrix getdecsize (const FixedMatrix& x) { return x.getdecsize(); }
inline Matrix getintsize (const FixedMatrix& x) { return x.getintsize(); }
inline Matrix getnumber (const FixedMatrix& x) { return x.getnumber(); }

std::ostream& operator << (std::ostream& os, const FixedMatrix& a);
std::istream& operator >> (std::istream& is, FixedMatrix& a);

FixedMatrix min (FixedPoint d, const FixedMatrix& m);
FixedMatrix min (const FixedMatrix& m, FixedPoint d);
FixedMatrix min (const FixedMatrix& a, const FixedMatrix& b);

FixedMatrix max (FixedPoint d, const FixedMatrix& m);
FixedMatrix max (const FixedMatrix& m, FixedPoint d);
FixedMatrix max (const FixedMatrix& a, const FixedMatrix& b);

FixedMatrix elem_pow (const FixedMatrix &a, const FixedMatrix &b);
FixedMatrix elem_pow (const FixedMatrix &a, const FixedPoint &b);
FixedMatrix elem_pow (const FixedPoint &a, const FixedMatrix &b);


MS_CMP_OP_DECLS (FixedMatrix, FixedPoint)
MS_BOOL_OP_DECLS (FixedMatrix, FixedPoint)

SM_CMP_OP_DECLS (FixedPoint, FixedMatrix)
SM_BOOL_OP_DECLS (FixedPoint, FixedMatrix)

MM_CMP_OP_DECLS (FixedMatrix, FixedMatrix)
MM_BOOL_OP_DECLS (FixedMatrix, FixedMatrix)

MARRAY_FORWARD_DEFS (MArray2, FixedMatrix, FixedPoint)

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
