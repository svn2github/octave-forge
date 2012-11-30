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

#if !defined (octave_FixedCNDArray_h)
#define octave_FixedCNDArray_h 1

#include <octave/MArray.h>
#include <octave/dMatrix.h>

#include <octave/dNDArray.h>
#include <octave/CNDArray.h>
#include <octave/boolNDArray.h>

#include <octave/mx-defs.h>
#include <octave/mx-op-defs.h>

#include <octave/data-conv.h>
#include <octave/mach-info.h>

#include "int/fixed.h"
#include "fixedCMatrix.h"
#include "fixedComplex.h"
#include "fixedNDArray.h"

class
FixedComplexNDArray : public MArray<FixedPointComplex>
{
public:

  FixedComplexNDArray (void) : MArray<FixedPointComplex> () { }

  FixedComplexNDArray (const dim_vector& dv) 
    : MArray<FixedPointComplex> (dv) { }

  FixedComplexNDArray (const dim_vector& dv, const FixedPointComplex val) :
    MArray<FixedPointComplex> (dv, val) { }

  FixedComplexNDArray (const MArray<int> &is, const MArray<int> &ds);

  FixedComplexNDArray (const NDArray &is, const NDArray &ds);

  FixedComplexNDArray (const ComplexNDArray &is, const ComplexNDArray &ds);

  FixedComplexNDArray (unsigned int is, unsigned int ds, 
		      const FixedComplexNDArray& a);

  FixedComplexNDArray (Complex is, Complex ds, 
		       const FixedComplexNDArray& a);

  FixedComplexNDArray (const MArray<int> &is, const MArray<int> &ds, 
		      const FixedComplexNDArray& a);

  FixedComplexNDArray (const NDArray &is, const NDArray &ds, 
		      const FixedComplexNDArray& a);

  FixedComplexNDArray (const ComplexNDArray &is, const ComplexNDArray &ds, 
		      const FixedComplexNDArray& a);

  FixedComplexNDArray (unsigned int is, unsigned int ds, 
		       const FixedNDArray& a);

  FixedComplexNDArray (Complex is, Complex ds, const FixedNDArray& a);

  FixedComplexNDArray (const MArray<int> &is, const MArray<int> &ds, 
		       const FixedNDArray& a);

  FixedComplexNDArray (const NDArray &is, const NDArray &ds, 
		       const FixedNDArray& a);

  FixedComplexNDArray (const ComplexNDArray &is, const ComplexNDArray &ds, 
		       const FixedNDArray& a);

  FixedComplexNDArray (unsigned int is, unsigned int ds, 
		       const ComplexNDArray& a);

  FixedComplexNDArray (Complex is, Complex ds, const ComplexNDArray& a);

  FixedComplexNDArray (const MArray<int> &is, const MArray<int> & ds, 
		       const ComplexNDArray& a);

  FixedComplexNDArray (const NDArray &is, const NDArray & ds, 
		       const ComplexNDArray& a);

  FixedComplexNDArray (const ComplexNDArray &is, 
		       const ComplexNDArray & ds, 
		       const ComplexNDArray& a);

  FixedComplexNDArray (unsigned int is, unsigned int ds, const NDArray& a);

  FixedComplexNDArray (Complex is, Complex ds, const NDArray& a);

  FixedComplexNDArray (const MArray<int> &is, const MArray<int> & ds, 
		       const NDArray& a);

  FixedComplexNDArray (const NDArray &is, const NDArray & ds, 
		       const NDArray& a);

  FixedComplexNDArray (const ComplexNDArray &is, 
		       const ComplexNDArray & ds, const NDArray& a);

  FixedComplexNDArray (unsigned int is, unsigned int ds,
		       const ComplexNDArray &a, const ComplexNDArray &b);

  FixedComplexNDArray (Complex is, Complex ds, const ComplexNDArray &a, 
		       const ComplexNDArray &b);

  FixedComplexNDArray (const MArray<int> &is, const MArray<int> &ds,
		       const ComplexNDArray &a, const ComplexNDArray &b);

  FixedComplexNDArray (const NDArray &is, const NDArray &ds,
		       const ComplexNDArray &a, const ComplexNDArray &b);

  FixedComplexNDArray (const ComplexNDArray &is, const ComplexNDArray &ds,
		       const ComplexNDArray &a, const ComplexNDArray &b);

  FixedComplexNDArray (const FixedNDArray& a);

  FixedComplexNDArray (const FixedNDArray& a, const FixedNDArray& b);

  FixedComplexNDArray (const FixedComplexNDArray& a)
    : MArray<FixedPointComplex> (a) { }

  FixedComplexNDArray (const MArray<FixedPointComplex>& a)
    : MArray<FixedPointComplex> (a) { }

  FixedComplexNDArray (const Array<FixedPointComplex>& a)
    : MArray<FixedPointComplex> (a) { }

  ComplexNDArray sign (void) const;
  ComplexNDArray getdecsize (void) const;
  ComplexNDArray getintsize (void) const;
  ComplexNDArray getnumber (void) const;
  ComplexNDArray fixedpoint (void) const;
  FixedComplexNDArray chdecsize (const Complex n);
  FixedComplexNDArray chdecsize (const ComplexNDArray &n);
  FixedComplexNDArray chintsize (const Complex n);
  FixedComplexNDArray chintsize (const ComplexNDArray &n);
  FixedComplexNDArray incdecsize (const Complex n);
  FixedComplexNDArray incdecsize (const ComplexNDArray &n);
  FixedComplexNDArray incdecsize ();
  FixedComplexNDArray incintsize (const Complex n);
  FixedComplexNDArray incintsize (const ComplexNDArray &n);
  FixedComplexNDArray incintsize ();

  FixedComplexNDArray& operator = (const FixedComplexNDArray& a)
    {
      MArray<FixedPointComplex>::operator = (a);
      return *this;
    }

  bool operator == (const FixedComplexNDArray& a) const;
  bool operator != (const FixedComplexNDArray& a) const;

  FixedComplexNDArray operator ! (void) const;

  boolNDArray all (octave_idx_type dim = -1) const;
  boolNDArray any (octave_idx_type dim = -1) const;

  FixedComplexNDArray concat (const FixedComplexNDArray& rb, 
			      const Array<octave_idx_type>& ra_idx);

  FixedComplexNDArray concat (const FixedNDArray& rb, 
			      const Array<octave_idx_type>& ra_idx);

  FixedComplexNDArray& insert (const FixedComplexNDArray& a, 
			       const Array<octave_idx_type>& ra_idx);

  FixedComplexNDArray cumprod (octave_idx_type dim = -1) const;
  FixedComplexNDArray cumsum (octave_idx_type dim = -1) const;
  FixedComplexNDArray prod (octave_idx_type dim = -1) const;
  FixedComplexNDArray sum (octave_idx_type dim = -1) const;
  FixedComplexNDArray sumsq (octave_idx_type dim = -1) const;

  FixedComplexNDArray max (octave_idx_type dim = 0) const;
  FixedComplexNDArray max (Array<octave_idx_type>& index, octave_idx_type dim = 0) const;
  FixedComplexNDArray min (octave_idx_type dim = 0) const;
  FixedComplexNDArray min (Array<octave_idx_type>& index, octave_idx_type dim = 0) const;

  FixedNDArray abs (void) const;

  FixedComplexMatrix fixed_complex_matrix_value (void) const;

  FixedComplexNDArray squeeze (void) const 
    { return Array<FixedPointComplex>::squeeze (); }

  static void increment_index (Array<octave_idx_type>& ra_idx,
			       const dim_vector& dimensions,
			       octave_idx_type start_dimension = 0);

  static octave_idx_type compute_index (Array<octave_idx_type>& ra_idx,
			    const dim_vector& dimensions);

  friend FixedNDArray real (const FixedComplexNDArray &x);
  friend FixedNDArray imag (const FixedComplexNDArray &x);
  friend FixedComplexNDArray conj (const FixedComplexNDArray &x);

  friend FixedNDArray abs (const FixedComplexNDArray &x);
  friend FixedNDArray norm (const FixedComplexNDArray &x);
  friend FixedNDArray arg (const FixedComplexNDArray &x);
  friend FixedComplexNDArray polar (const FixedNDArray &r, const FixedNDArray &p);

  friend FixedComplexNDArray cos  (const FixedComplexNDArray &x);
  friend FixedComplexNDArray cosh  (const FixedComplexNDArray &x);
  friend FixedComplexNDArray sin  (const FixedComplexNDArray &x);
  friend FixedComplexNDArray sinh  (const FixedComplexNDArray &x);
  friend FixedComplexNDArray tan  (const FixedComplexNDArray &x);
  friend FixedComplexNDArray tanh  (const FixedComplexNDArray &x);

  friend FixedComplexNDArray sqrt  (const FixedComplexNDArray &x);
  friend FixedComplexNDArray exp  (const FixedComplexNDArray &x);
  friend FixedComplexNDArray log  (const FixedComplexNDArray &x);
  friend FixedComplexNDArray log10  (const FixedComplexNDArray &x);

  friend FixedComplexNDArray round (const FixedComplexNDArray &x);
  friend FixedComplexNDArray rint (const FixedComplexNDArray &x);
  friend FixedComplexNDArray floor (const FixedComplexNDArray &x);
  friend FixedComplexNDArray ceil (const FixedComplexNDArray &x);

  friend ComplexNDArray fixedpoint (const FixedComplexNDArray& x);
  friend ComplexNDArray sign (const FixedComplexNDArray& x);
  friend ComplexNDArray getintsize (const FixedComplexNDArray& x);
  friend ComplexNDArray getdecsize (const FixedComplexNDArray& x);
  friend ComplexNDArray getnumber (const FixedComplexNDArray& x);
  // i/o

  friend std::ostream& operator << (std::ostream& os, 
				    const FixedComplexNDArray& a);
  friend std::istream& operator >> (std::istream& is, FixedComplexNDArray& a);

};


FixedNDArray real (const FixedComplexNDArray &x);
FixedNDArray imag (const FixedComplexNDArray &x);
FixedComplexNDArray conj (const FixedComplexNDArray &x);

FixedNDArray abs (const FixedComplexNDArray &x);
FixedNDArray norm (const FixedComplexNDArray &x);
FixedNDArray arg (const FixedComplexNDArray &x);
FixedComplexNDArray polar (const FixedNDArray &r, const FixedNDArray &p);

FixedComplexNDArray cos  (const FixedComplexNDArray &x);
FixedComplexNDArray cosh  (const FixedComplexNDArray &x);
FixedComplexNDArray sin  (const FixedComplexNDArray &x);
FixedComplexNDArray sinh  (const FixedComplexNDArray &x);
FixedComplexNDArray tan  (const FixedComplexNDArray &x);
FixedComplexNDArray tanh  (const FixedComplexNDArray &x);

FixedComplexNDArray sqrt  (const FixedComplexNDArray &x);
FixedComplexNDArray exp  (const FixedComplexNDArray &x);
FixedComplexNDArray log  (const FixedComplexNDArray &x);
FixedComplexNDArray log10  (const FixedComplexNDArray &x);

FixedComplexNDArray round (const FixedComplexNDArray &x);
FixedComplexNDArray rint (const FixedComplexNDArray &x);
FixedComplexNDArray floor (const FixedComplexNDArray &x);
FixedComplexNDArray ceil (const FixedComplexNDArray &x);

inline ComplexNDArray fixedpoint (const FixedComplexNDArray& x) 
     { return x.fixedpoint(); }
inline ComplexNDArray sign (const FixedComplexNDArray& x) 
     { return x.sign(); }
inline ComplexNDArray getintsize (const FixedComplexNDArray& x) 
     { return x.getintsize(); }
inline ComplexNDArray getdecsize (const FixedComplexNDArray& x) 
     { return x.getdecsize(); }
inline ComplexNDArray getnumber (const FixedComplexNDArray& x) 
     { return x.getnumber(); }

std::ostream& operator << (std::ostream& os, 
				    const FixedComplexNDArray& a);
std::istream& operator >> (std::istream& is, FixedComplexNDArray& a);

FixedComplexNDArray min (const FixedPointComplex& c, 
				const FixedComplexNDArray& m);
FixedComplexNDArray min (const FixedComplexNDArray& m, 
				const FixedPointComplex& c);
FixedComplexNDArray min (const FixedComplexNDArray& a, 
				const FixedComplexNDArray& b);

FixedComplexNDArray max (const FixedPointComplex& c, 
				const FixedComplexNDArray& m);
FixedComplexNDArray max (const FixedComplexNDArray& m, 
				const FixedPointComplex& c);
FixedComplexNDArray max (const FixedComplexNDArray& a, 
				const FixedComplexNDArray& b);

FixedComplexNDArray elem_pow (const FixedComplexNDArray &a,
			      const FixedComplexNDArray &b);
FixedComplexNDArray elem_pow (const FixedComplexNDArray &a,
			      const FixedPointComplex &b);
FixedComplexNDArray elem_pow (const FixedPointComplex &a,
			      const FixedComplexNDArray &b);

NDS_CMP_OP_DECLS (FixedComplexNDArray, FixedPointComplex, )
NDS_BOOL_OP_DECLS (FixedComplexNDArray, FixedPointComplex, )

SND_CMP_OP_DECLS (FixedPointComplex, FixedComplexNDArray, )
SND_BOOL_OP_DECLS (FixedPointComplex, FixedComplexNDArray, )

NDND_CMP_OP_DECLS (FixedComplexNDArray, FixedComplexNDArray, )
NDND_BOOL_OP_DECLS (FixedComplexNDArray, FixedComplexNDArray, )

MARRAY_FORWARD_DEFS (MArray, FixedComplexNDArray, FixedPointComplex)

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/


