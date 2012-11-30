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

#if !defined (octave_FixedRowVector_h)
#define octave_FixedRowVector_h 1

#include <octave/MArray.h>
#include <octave/dRowVector.h>
#include <octave/mx-defs.h>
#include <octave/mx-op-defs.h>

#include "int/fixed.h"

#if !defined(octave_FixedColVector_h)
class FixedColumnVector;
#endif
#if !defined(octave_FixedMatrix_h)
class FixedMatrix;
#endif

typedef FixedPoint (*fp_fp_Mapper)(FixedPoint);

class
OCTAVE_FIXED_API 
FixedRowVector : public MArray<FixedPoint>
{
public:

  FixedRowVector (void) : MArray<FixedPoint> () { }

  explicit FixedRowVector (int n) : MArray<FixedPoint> (dim_vector (1,n)) { }

  FixedRowVector (const MArray<int> &is, const MArray<int> &ds);

  FixedRowVector (const RowVector &is, const RowVector &ds);

  FixedRowVector (unsigned int is, unsigned int ds, const FixedRowVector& a);

  FixedRowVector (const MArray<int> &is, const MArray<int> &ds, 
		  const FixedRowVector& a);

  FixedRowVector (const RowVector &is, const RowVector &ds, 
		  const FixedRowVector& a);

  FixedRowVector (unsigned int is, unsigned int ds, const RowVector& a);

  FixedRowVector (const MArray<int> &is, const MArray<int> &ds, 
		  const RowVector& a);

  FixedRowVector (const RowVector &is, const RowVector &ds, 
		  const RowVector& a);

  FixedRowVector (unsigned int is, unsigned int ds, const RowVector& a, 
		  const RowVector& b);

  FixedRowVector (const MArray<int> &is, const MArray<int> &ds, 
		  const RowVector& a, const RowVector& b);

  FixedRowVector (const RowVector &is, const RowVector &ds, 
		  const RowVector& a, const RowVector& b);

  FixedRowVector (int n, FixedPoint val)
    : MArray<FixedPoint> (dim_vector(1, n), val) { }

  FixedRowVector (const FixedRowVector& a) : MArray<FixedPoint> (a) { }

  FixedRowVector (const MArray<FixedPoint>& a) : MArray<FixedPoint> (a) { }

  RowVector sign (void) const;
  RowVector signbit (void) const;
  RowVector getdecsize (void) const;
  RowVector getintsize (void) const;
  RowVector getnumber (void) const;
  RowVector fixedpoint (void) const;
  FixedRowVector chdecsize (const double n);
  FixedRowVector chdecsize (const RowVector &n);
  FixedRowVector chintsize (const double n);
  FixedRowVector chintsize (const RowVector &n);
  FixedRowVector incdecsize (const double n);
  FixedRowVector incdecsize (const RowVector &n);
  FixedRowVector incdecsize ();
  FixedRowVector incintsize (const double n);
  FixedRowVector incintsize (const RowVector &n);
  FixedRowVector incintsize ();

  FixedRowVector& operator = (const FixedRowVector& a)
    {
      MArray<FixedPoint>::operator = (a);
      return *this;
    }

  bool operator == (const FixedRowVector& a) const;
  bool operator != (const FixedRowVector& a) const;

  // destructive insert/delete/reorder operations

  FixedRowVector& insert (const FixedRowVector& a, int c);

  FixedRowVector& fill (FixedPoint val);
  FixedRowVector& fill (FixedPoint val, int c1, int c2);

  FixedRowVector append (const FixedRowVector& a) const;

  FixedColumnVector transpose (void) const;

  // resize is the destructive equivalent for this one

  FixedRowVector extract (int c1, int c2) const;

  FixedRowVector extract_n (int c1, int n) const;

  // other operations

  FixedRowVector map (fp_fp_Mapper f) const;

  FixedRowVector& apply (fp_fp_Mapper f);

  FixedPoint min (void) const;
  FixedPoint max (void) const;

  friend FixedRowVector operator * (const FixedRowVector& a, const Matrix& b);

  friend FixedRowVector real (const FixedRowVector &x);
  friend FixedRowVector imag (const FixedRowVector &x);
  friend FixedRowVector conj (const FixedRowVector &x);

  friend FixedRowVector abs (const FixedRowVector &x);

  friend FixedRowVector cos  (const FixedRowVector &x);
  friend FixedRowVector cosh  (const FixedRowVector &x);
  friend FixedRowVector sin  (const FixedRowVector &x);
  friend FixedRowVector sinh  (const FixedRowVector &x);
  friend FixedRowVector tan  (const FixedRowVector &x);
  friend FixedRowVector tanh  (const FixedRowVector &x);

  friend FixedRowVector sqrt  (const FixedRowVector &x);
  friend FixedRowVector exp  (const FixedRowVector &x);
  friend FixedRowVector log  (const FixedRowVector &x);
  friend FixedRowVector log10  (const FixedRowVector &x);

  friend FixedRowVector round (const FixedRowVector &x);
  friend FixedRowVector rint (const FixedRowVector &x);
  friend FixedRowVector floor (const FixedRowVector &x);
  friend FixedRowVector ceil (const FixedRowVector &x);

  friend RowVector fixedpoint (const FixedRowVector& x);
  friend RowVector sign (const FixedRowVector& x);
  friend RowVector signbit (const FixedRowVector& x);
  friend RowVector getdecsize (const FixedRowVector& x);
  friend RowVector getintsize (const FixedRowVector& x);
  friend RowVector getnumber (const FixedRowVector& x);

  // i/o

  friend std::ostream& operator << (std::ostream& os, const FixedRowVector& a);
  friend std::istream& operator >> (std::istream& is, FixedRowVector& a);

  void resize (octave_idx_type n,
               const FixedPoint& rfv = FixedPoint ())
  {
    Array<FixedPoint>::resize (dim_vector (1, n), rfv);
  }
};

FixedPoint operator * (const FixedRowVector& a, const FixedColumnVector& b);

FixedRowVector real (const FixedRowVector &x);
FixedRowVector imag (const FixedRowVector &x);
FixedRowVector conj (const FixedRowVector &x);

FixedRowVector abs (const FixedRowVector &x);

FixedRowVector cos  (const FixedRowVector &x);
FixedRowVector cosh  (const FixedRowVector &x);
FixedRowVector sin  (const FixedRowVector &x);
FixedRowVector sinh  (const FixedRowVector &x);
FixedRowVector tan  (const FixedRowVector &x);
FixedRowVector tanh  (const FixedRowVector &x);

FixedRowVector sqrt  (const FixedRowVector &x);
FixedRowVector exp  (const FixedRowVector &x);
FixedRowVector log  (const FixedRowVector &x);
FixedRowVector log10  (const FixedRowVector &x);

FixedRowVector round (const FixedRowVector &x);
FixedRowVector rint (const FixedRowVector &x);
FixedRowVector floor (const FixedRowVector &x);
FixedRowVector ceil (const FixedRowVector &x);

inline RowVector fixedpoint (const FixedRowVector& x) 
	{ return x.fixedpoint(); }
inline RowVector sign (const FixedRowVector& x) 
	{ return x.sign(); }
inline RowVector signbit (const FixedRowVector& x)
	{ return x.signbit(); }
inline RowVector getdecsize (const FixedRowVector& x) 
	{ return x.getdecsize(); }
inline RowVector getintsize (const FixedRowVector& x) 
	{ return x.getintsize(); }
inline RowVector getnumber (const FixedRowVector& x) 
	{ return x.getnumber(); }

std::ostream& operator << (std::ostream& os, const FixedRowVector& a);
std::istream& operator >> (std::istream& is, FixedRowVector& a);

FixedRowVector elem_pow (const FixedRowVector &a,
			     const FixedRowVector &b);
FixedRowVector elem_pow (const FixedRowVector &a,
			     const FixedPoint &b);
FixedRowVector elem_pow (const FixedPoint &a,
			     const FixedRowVector &b);

MARRAY_FORWARD_DEFS (MArray, FixedRowVector, FixedPoint)

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
