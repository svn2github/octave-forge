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

#if !defined (octave_FixedColumnVector_h)
#define octave_FixedColumnVector_h 1

#if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#pragma interface
#endif

#include <octave/MArray.h>
#include <octave/dColVector.h>
#include <octave/mx-defs.h>
#include <octave/mx-op-defs.h>

#include "int/fixed.h"

#if !defined(octave_FixedRowVector_h)
class FixedRowVector;
#endif
#if !defined(octave_FixedMatrix_h)
class FixedMatrix;
#endif

typedef FixedPoint (*f_f_Mapper)(FixedPoint);

class
FixedColumnVector : public MArray<FixedPoint>
{
public:

  FixedColumnVector (void) : MArray<FixedPoint> () { }

  explicit FixedColumnVector (int n) : MArray<FixedPoint> (n) { }

  FixedColumnVector (const MArray<int> &is, const MArray<int> &ds);

  FixedColumnVector (const ColumnVector &is, const ColumnVector &ds);

  FixedColumnVector (unsigned int is, unsigned int ds, 
		     const FixedColumnVector& a);

  FixedColumnVector (const MArray<int> &is, const MArray<int> &ds, 
		     const FixedColumnVector& a);

  FixedColumnVector (const ColumnVector &is, const ColumnVector &ds, 
		     const FixedColumnVector& a);

  FixedColumnVector (unsigned int is, unsigned int ds, const ColumnVector& a);

  FixedColumnVector (const MArray<int> &is, const MArray<int> &ds, 
		     const ColumnVector& a);

  FixedColumnVector (const ColumnVector &is, const ColumnVector &ds, 
		     const ColumnVector& a);

  FixedColumnVector (unsigned int is, unsigned int ds, const ColumnVector& a, 
		  const ColumnVector& b);

  FixedColumnVector (const MArray<int> &is, const MArray<int> &ds, 
		  const ColumnVector& a, const ColumnVector& b);

  FixedColumnVector (const ColumnVector &is, const ColumnVector &ds, 
		  const ColumnVector& a, const ColumnVector& b);

  FixedColumnVector (int n, FixedPoint val) : MArray<FixedPoint> (n, val) { }

  FixedColumnVector (const FixedColumnVector& a) : MArray<FixedPoint> (a) { }

  FixedColumnVector (const MArray<FixedPoint>& a) : MArray<FixedPoint> (a) { }

  ColumnVector sign (void) const;
  ColumnVector signbit (void) const;
  ColumnVector getdecsize (void) const;
  ColumnVector getintsize (void) const;
  ColumnVector getnumber (void) const;
  ColumnVector fixedpoint (void) const;
  FixedColumnVector chdecsize (const double n);
  FixedColumnVector chdecsize (const ColumnVector &n);
  FixedColumnVector chintsize (const double n);
  FixedColumnVector chintsize (const ColumnVector &n);
  FixedColumnVector incdecsize (const double n);
  FixedColumnVector incdecsize (const ColumnVector &n);
  FixedColumnVector incdecsize ();
  FixedColumnVector incintsize (const double n);
  FixedColumnVector incintsize (const ColumnVector &n);
  FixedColumnVector incintsize ();

  FixedColumnVector& operator = (const FixedColumnVector& a)
    {
      MArray<FixedPoint>::operator = (a);
      return *this;
    }

  bool operator == (const FixedColumnVector& a) const;
  bool operator != (const FixedColumnVector& a) const;

  // destructive insert/delete/reorder operations

  FixedColumnVector& insert (const FixedColumnVector& a, int r);

  FixedColumnVector& fill (FixedPoint val);
  FixedColumnVector& fill (FixedPoint val, int r1, int r2);

  FixedColumnVector stack (const FixedColumnVector& a) const;

  FixedRowVector transpose (void) const;

  // resize is the destructive equivalent for this one

  FixedColumnVector extract (int r1, int r2) const;

  FixedColumnVector extract_n (int r1, int n) const;

  // matrix by column vector -> column vector operations

  friend FixedColumnVector operator * (const FixedMatrix& a, const FixedColumnVector& b);

  // other operations

  FixedColumnVector map (f_f_Mapper f) const;

  FixedColumnVector& apply (f_f_Mapper f);

  FixedPoint min (void) const;
  FixedPoint max (void) const;

  friend FixedColumnVector real (const FixedColumnVector &x);
  friend FixedColumnVector imag (const FixedColumnVector &x);
  friend FixedColumnVector conj (const FixedColumnVector &x);

  friend FixedColumnVector abs (const FixedColumnVector &x);

  friend FixedColumnVector cos  (const FixedColumnVector &x);
  friend FixedColumnVector cosh  (const FixedColumnVector &x);
  friend FixedColumnVector sin  (const FixedColumnVector &x);
  friend FixedColumnVector sinh  (const FixedColumnVector &x);
  friend FixedColumnVector tan  (const FixedColumnVector &x);
  friend FixedColumnVector tanh  (const FixedColumnVector &x);

  friend FixedColumnVector sqrt  (const FixedColumnVector &x);
  friend FixedColumnVector exp  (const FixedColumnVector &x);
  friend FixedColumnVector log  (const FixedColumnVector &x);
  friend FixedColumnVector log10  (const FixedColumnVector &x);

  friend FixedColumnVector round (const FixedColumnVector &x);
  friend FixedColumnVector rint (const FixedColumnVector &x);
  friend FixedColumnVector floor (const FixedColumnVector &x);
  friend FixedColumnVector ceil (const FixedColumnVector &x);

  friend ColumnVector fixedpoint (const FixedColumnVector& x) 
	{ return x.fixedpoint(); }
  friend ColumnVector sign (const FixedColumnVector& x) { return x.sign(); }
  friend ColumnVector signbit (const FixedColumnVector& x) 
	{ return x.signbit(); }
  friend ColumnVector getdecsize (const FixedColumnVector& x) 
	{ return x.getdecsize(); }
  friend ColumnVector getintsize (const FixedColumnVector& x) 
	{ return x.getintsize(); }
  friend ColumnVector getnumber (const FixedColumnVector& x) 
	{ return x.getnumber(); }

  // i/o

  friend std::ostream& operator << (std::ostream& os, const FixedColumnVector& a);
  friend std::istream& operator >> (std::istream& is, FixedColumnVector& a);

private:

  FixedColumnVector (FixedPoint *d, int l) : MArray<FixedPoint> (d, l) { }
};

FixedColumnVector elem_pow (const FixedColumnVector &a,
			     const FixedColumnVector &b);
FixedColumnVector elem_pow (const FixedColumnVector &a,
			     const FixedPoint &b);
FixedColumnVector elem_pow (const FixedPoint &a,
			     const FixedColumnVector &b);

MARRAY_FORWARD_DEFS (MArray, FixedColumnVector, FixedPoint)

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
