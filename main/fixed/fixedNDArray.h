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
along with this program; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#if !defined (octave_FixedNDArray_h) && defined (HAVE_ND_ARRAYS)
#define octave_FixedNDArray_h 1

#if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#pragma interface
#endif

#include <octave/MArrayN.h>
#include <octave/dMatrix.h>
#include <octave/dNDArray.h>
#include <octave/boolNDArray.h>

#include <octave/mx-defs.h>
#include <octave/mx-op-defs.h>

#include <octave/data-conv.h>
#include <octave/mach-info.h>

#include "int/fixed.h"
#include "fixedMatrix.h"

class
FixedNDArray : public MArrayN<FixedPoint>
{
public:
  FixedNDArray (void) : MArrayN<FixedPoint> () { }

  FixedNDArray (const dim_vector& dv) : MArrayN<FixedPoint> (dv) { }

  FixedNDArray (const dim_vector& dv, const FixedPoint val) 
    : MArrayN<FixedPoint> (dv, val) { }

  FixedNDArray (const MArrayN<int> &is, const MArrayN<int> &ds);

  FixedNDArray (const NDArray &is, const NDArray &ds);

  FixedNDArray (unsigned int is, unsigned int ds, const FixedNDArray& a);

  FixedNDArray (const MArrayN<int> &is, const MArrayN<int> &ds, 
	       const FixedNDArray& a);

  FixedNDArray (const NDArray &is, const NDArray &ds, const FixedNDArray& a);

  FixedNDArray (unsigned int is, unsigned int ds, const NDArray& a);

  FixedNDArray (const MArrayN<int> &is, const MArrayN<int> &ds, 
	       const NDArray& a);

  FixedNDArray (const NDArray &is, const NDArray &ds, const NDArray& a);

  FixedNDArray (unsigned int is, unsigned int ds, const NDArray& a, 
	       const NDArray& b);

  FixedNDArray (const MArrayN<int> &is, const MArrayN<int> &ds, 
	       const NDArray& a, const NDArray& b);

  FixedNDArray (const NDArray &is, const NDArray &ds, const NDArray& a, 
	       const NDArray& b);

  FixedNDArray (const MArrayN<int> &a);

  FixedNDArray (const NDArray &a);

  FixedNDArray (const FixedNDArray& a) : MArrayN<FixedPoint> (a) { }
  FixedNDArray (const MArrayN<FixedPoint>& a) : MArrayN<FixedPoint> (a) { }
  FixedNDArray (const ArrayN<FixedPoint>& a) : MArrayN<FixedPoint> (a) { }

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
      MArrayN<FixedPoint>::operator = (a);
      return *this;
    }

  bool operator == (const FixedNDArray& a) const;
  bool operator != (const FixedNDArray& a) const;

  FixedNDArray operator ! (void) const;

  boolNDArray all (int dim = -1) const;
  boolNDArray any (int dim = -1) const;

#ifdef HAVE_OCTAVE_CONCAT
  friend FixedNDArray concat (const FixedNDArray& ra, const FixedNDArray& rb, 
			      const Array<int>& ra_idx);

  FixedNDArray& insert (const FixedNDArray& a, const Array<int>& ra_idx);
#endif

  FixedNDArray cumprod (int dim = -1) const;
  FixedNDArray cumsum (int dim = -1) const;
  FixedNDArray prod (int dim = -1) const;
  FixedNDArray sum (int dim = -1) const;  
  FixedNDArray sumsq (int dim = -1) const;

  FixedNDArray max (int dim = 0) const;
  FixedNDArray max (ArrayN<int>& index, int dim = 0) const;
  FixedNDArray min (int dim = 0) const;
  FixedNDArray min (ArrayN<int>& index, int dim = 0) const;
  
  FixedNDArray abs (void) const;
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

    FixedMatrix fixed_matrix_value (void) const;

  FixedNDArray squeeze (void) const { return ArrayN<FixedPoint>::squeeze (); }

  static void increment_index (Array<int>& ra_idx,
			       const dim_vector& dimensions,
			       int start_dimension = 0);

  static int compute_index (Array<int>& ra_idx,
			    const dim_vector& dimensions);

  friend NDArray fixedpoint (const FixedNDArray& x) { return x.fixedpoint(); }
  friend NDArray sign (const FixedNDArray& x) { return x.sign(); }
  friend NDArray signbit (const FixedNDArray& x) { return x.signbit(); }
  friend NDArray getdecsize (const FixedNDArray& x) { return x.getdecsize(); }
  friend NDArray getintsize (const FixedNDArray& x) { return x.getintsize(); }
  friend NDArray getnumber (const FixedNDArray& x) { return x.getnumber(); }

  // i/o

  friend std::ostream& operator << (std::ostream& os, const FixedNDArray& a);
  friend std::istream& operator >> (std::istream& is, FixedNDArray& a);

  static FixedPoint resize_fill_value (void) { return FixedPoint(); }

private:

  FixedNDArray (FixedPoint *d, const dim_vector& dv) : MArrayN<FixedPoint> (d, dv) { }
  
};

extern FixedNDArray min (double d, const FixedNDArray& m);
extern FixedNDArray min (const FixedNDArray& m, double d);
extern FixedNDArray min (const FixedNDArray& a, const FixedNDArray& b);

extern FixedNDArray max (double d, const FixedNDArray& m);
extern FixedNDArray max (const FixedNDArray& m, double d);
extern FixedNDArray max (const FixedNDArray& a, const FixedNDArray& b);

FixedNDArray elem_pow (const FixedNDArray &a, const FixedNDArray &b);
FixedNDArray elem_pow (const FixedNDArray &a, const FixedPoint &b);
FixedNDArray elem_pow (const FixedPoint &a, const FixedNDArray &b);

NDS_CMP_OP_DECLS (FixedNDArray, FixedPoint)
NDS_BOOL_OP_DECLS (FixedNDArray, FixedPoint)

SND_CMP_OP_DECLS (FixedPoint, FixedNDArray)
SND_BOOL_OP_DECLS (FixedPoint, FixedNDArray)

NDND_CMP_OP_DECLS (FixedNDArray, FixedNDArray)
NDND_BOOL_OP_DECLS (FixedNDArray, FixedNDArray)

MARRAY_FORWARD_DEFS (MArrayN, FixedNDArray, FixedPoint)

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
