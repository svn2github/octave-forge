/*

Copyright (C) 2004 Motorola Inc
Copyright (C) 2004 David Bateman

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

#if !defined (octave_FixedNDArray_h)
#define octave_FixedNDArray_h 1

#include <octave/MArray.h>
#include <octave/dMatrix.h>
#include <octave/dNDArray.h>
#include <octave/boolNDArray.h>

#include <octave/mx-defs.h>
#include <octave/mx-op-defs.h>

#include <octave/data-conv.h>
#include <octave/mach-info.h>

#include "int/fixed.h"
#include "fixedMatrix.h"

class FixedComplexNDArray;

class
FixedNDArray : public MArray<FixedPoint>
{
public:
  FixedNDArray (void) : MArray<FixedPoint> () { }

  FixedNDArray (const dim_vector& dv) : MArray<FixedPoint> (dv) { }

  FixedNDArray (const dim_vector& dv, const FixedPoint val) 
    : MArray<FixedPoint> (dv, val) { }

  FixedNDArray (const MArray<int> &is, const MArray<int> &ds);

  FixedNDArray (const NDArray &is, const NDArray &ds);

  FixedNDArray (unsigned int is, unsigned int ds, const FixedNDArray& a);

  FixedNDArray (const MArray<int> &is, const MArray<int> &ds, 
	       const FixedNDArray& a);

  FixedNDArray (const NDArray &is, const NDArray &ds, const FixedNDArray& a);

  FixedNDArray (unsigned int is, unsigned int ds, const NDArray& a);

  FixedNDArray (const MArray<int> &is, const MArray<int> &ds, 
	       const NDArray& a);

  FixedNDArray (const NDArray &is, const NDArray &ds, const NDArray& a);

  FixedNDArray (unsigned int is, unsigned int ds, const NDArray& a, 
	       const NDArray& b);

  FixedNDArray (const MArray<int> &is, const MArray<int> &ds, 
	       const NDArray& a, const NDArray& b);

  FixedNDArray (const NDArray &is, const NDArray &ds, const NDArray& a, 
	       const NDArray& b);

  FixedNDArray (const MArray<int> &a);

  FixedNDArray (const NDArray &a);

  FixedNDArray (const FixedNDArray& a) : MArray<FixedPoint> (a) { }
  FixedNDArray (const MArray<FixedPoint>& a) : MArray<FixedPoint> (a) { }
  FixedNDArray (const Array<FixedPoint>& a) : MArray<FixedPoint> (a) { }

  NDArray sign (void) const;
  NDArray signbit (void) const;
  NDArray getdecsize (void) const;
  NDArray getintsize (void) const;
  NDArray getnumber (void) const;
  NDArray fixedpoint (void) const;
  FixedNDArray chdecsize (const double n);
  FixedNDArray chdecsize (const NDArray &n);
  FixedNDArray chintsize (const double n);
  FixedNDArray chintsize (const NDArray &n);
  FixedNDArray incdecsize (const double n);
  FixedNDArray incdecsize (const NDArray &n);
  FixedNDArray incdecsize ();
  FixedNDArray incintsize (const double n);
  FixedNDArray incintsize (const NDArray &n);
  FixedNDArray incintsize ();

  FixedNDArray& operator = (const FixedNDArray& a)
    {
      MArray<FixedPoint>::operator = (a);
      return *this;
    }

  bool operator == (const FixedNDArray& a) const;
  bool operator != (const FixedNDArray& a) const;

  FixedNDArray operator ! (void) const;

  boolNDArray all (octave_idx_type dim = -1) const;
  boolNDArray any (octave_idx_type dim = -1) const;

  FixedNDArray concat (const FixedNDArray& rb, const Array<octave_idx_type>& ra_idx);
  FixedComplexNDArray concat (const FixedComplexNDArray& rb, 
			      const Array<octave_idx_type>& ra_idx);

  FixedNDArray& insert (const FixedNDArray& a, const Array<octave_idx_type>& ra_idx);

  FixedNDArray cumprod (octave_idx_type dim = -1) const;
  FixedNDArray cumsum (octave_idx_type dim = -1) const;
  FixedNDArray prod (octave_idx_type dim = -1) const;
  FixedNDArray sum (octave_idx_type dim = -1) const;  
  FixedNDArray sumsq (octave_idx_type dim = -1) const;

  FixedNDArray max (octave_idx_type dim = 0) const;
  FixedNDArray max (Array<octave_idx_type>& index, octave_idx_type dim = 0) const;
  FixedNDArray min (octave_idx_type dim = 0) const;
  FixedNDArray min (Array<octave_idx_type>& index, octave_idx_type dim = 0) const;
  
  FixedNDArray abs (void) const;

  FixedMatrix fixed_matrix_value (void) const;

  FixedNDArray squeeze (void) const { return Array<FixedPoint>::squeeze (); }

  static void increment_index (Array<octave_idx_type>& ra_idx,
			       const dim_vector& dimensions,
			       octave_idx_type start_dimension = 0);

  static octave_idx_type compute_index (Array<octave_idx_type>& ra_idx,
			    const dim_vector& dimensions);

  // friend FixedNDArray abs  (const FixedNDArray &x);
  friend FixedNDArray cos  (const FixedNDArray &x);
  friend FixedNDArray cosh  (const FixedNDArray &x);
  friend FixedNDArray sin  (const FixedNDArray &x);
  friend FixedNDArray sinh  (const FixedNDArray &x);
  friend FixedNDArray tan  (const FixedNDArray &x);
  friend FixedNDArray tanh  (const FixedNDArray &x);

  friend FixedNDArray sqrt  (const FixedNDArray &x);
  friend FixedNDArray exp  (const FixedNDArray &x);
  friend FixedNDArray log  (const FixedNDArray &x);
  friend FixedNDArray log10  (const FixedNDArray &x);

  friend FixedNDArray atan2 (const FixedNDArray &x, const FixedNDArray &y);

  friend FixedNDArray round (const FixedNDArray &x);
  friend FixedNDArray rint (const FixedNDArray &x);
  friend FixedNDArray floor (const FixedNDArray &x);
  friend FixedNDArray ceil (const FixedNDArray &x);

  friend FixedNDArray real (const FixedNDArray& a);
  friend FixedNDArray imag (const FixedNDArray& a);
  friend FixedNDArray conj (const FixedNDArray &x);

  friend NDArray fixedpoint (const FixedNDArray& x);
  friend NDArray sign (const FixedNDArray& x);
  friend NDArray signbit (const FixedNDArray& x);
  friend NDArray getdecsize (const FixedNDArray& x);
  friend NDArray getintsize (const FixedNDArray& x);
  friend NDArray getnumber (const FixedNDArray& x);

  // i/o

  friend std::ostream& operator << (std::ostream& os, const FixedNDArray& a);
  friend std::istream& operator >> (std::istream& is, FixedNDArray& a);

};

// FixedNDArray abs  (const FixedNDArray &x);
FixedNDArray cos  (const FixedNDArray &x);
FixedNDArray cosh  (const FixedNDArray &x);
FixedNDArray sin  (const FixedNDArray &x);
FixedNDArray sinh  (const FixedNDArray &x);
FixedNDArray tan  (const FixedNDArray &x);
FixedNDArray tanh  (const FixedNDArray &x);

FixedNDArray sqrt  (const FixedNDArray &x);
FixedNDArray exp  (const FixedNDArray &x);
FixedNDArray log  (const FixedNDArray &x);
FixedNDArray log10  (const FixedNDArray &x);

FixedNDArray atan2 (const FixedNDArray &x, const FixedNDArray &y);

FixedNDArray round (const FixedNDArray &x);
FixedNDArray rint (const FixedNDArray &x);
FixedNDArray floor (const FixedNDArray &x);
FixedNDArray ceil (const FixedNDArray &x);

FixedNDArray real (const FixedNDArray& a);
FixedNDArray imag (const FixedNDArray& a);
FixedNDArray conj (const FixedNDArray &x);

inline NDArray fixedpoint (const FixedNDArray& x) { return x.fixedpoint(); }
inline NDArray sign (const FixedNDArray& x) { return x.sign(); }
inline NDArray signbit (const FixedNDArray& x) { return x.signbit(); }
inline NDArray getdecsize (const FixedNDArray& x) { return x.getdecsize(); }
inline NDArray getintsize (const FixedNDArray& x) { return x.getintsize(); }
inline NDArray getnumber (const FixedNDArray& x) { return x.getnumber(); }

std::ostream& operator << (std::ostream& os, const FixedNDArray& a);
std::istream& operator >> (std::istream& is, FixedNDArray& a);

FixedNDArray min (double d, const FixedNDArray& m);
FixedNDArray min (const FixedNDArray& m, double d);
FixedNDArray min (const FixedNDArray& a, const FixedNDArray& b);

FixedNDArray max (double d, const FixedNDArray& m);
FixedNDArray max (const FixedNDArray& m, double d);
FixedNDArray max (const FixedNDArray& a, const FixedNDArray& b);

FixedNDArray elem_pow (const FixedNDArray &a, const FixedNDArray &b);
FixedNDArray elem_pow (const FixedNDArray &a, const FixedPoint &b);
FixedNDArray elem_pow (const FixedPoint &a, const FixedNDArray &b);

NDS_CMP_OP_DECLS (FixedNDArray, FixedPoint, )
NDS_BOOL_OP_DECLS (FixedNDArray, FixedPoint, )

SND_CMP_OP_DECLS (FixedPoint, FixedNDArray, )
SND_BOOL_OP_DECLS (FixedPoint, FixedNDArray, )

NDND_CMP_OP_DECLS (FixedNDArray, FixedNDArray, )
NDND_BOOL_OP_DECLS (FixedNDArray, FixedNDArray, )

MARRAY_FORWARD_DEFS (MArray, FixedNDArray, FixedPoint)

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
