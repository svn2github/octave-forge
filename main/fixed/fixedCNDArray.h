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

#if !defined (octave_FixedCNDArray_h) && defined (HAVE_ND_ARRAYS)
#define octave_FixedCNDArray_h 1

#if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#pragma interface
#endif

#include <octave/MArrayN.h>
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
FixedComplexNDArray : public MArrayN<FixedPointComplex>
{
public:

  FixedComplexNDArray (void) : MArrayN<FixedPointComplex> () { }

  FixedComplexNDArray (const dim_vector& dv) 
    : MArrayN<FixedPointComplex> (dv) { }

  FixedComplexNDArray (const dim_vector& dv, const FixedPointComplex val) :
    MArrayN<FixedPointComplex> (dv, val) { }

  FixedComplexNDArray (const MArrayN<int> &is, const MArrayN<int> &ds);

  FixedComplexNDArray (const NDArray &is, const NDArray &ds);

  FixedComplexNDArray (const ComplexNDArray &is, const ComplexNDArray &ds);

  FixedComplexNDArray (unsigned int is, unsigned int ds, 
		      const FixedComplexNDArray& a);

  FixedComplexNDArray (Complex is, Complex ds, 
		       const FixedComplexNDArray& a);

  FixedComplexNDArray (const MArrayN<int> &is, const MArrayN<int> &ds, 
		      const FixedComplexNDArray& a);

  FixedComplexNDArray (const NDArray &is, const NDArray &ds, 
		      const FixedComplexNDArray& a);

  FixedComplexNDArray (const ComplexNDArray &is, const ComplexNDArray &ds, 
		      const FixedComplexNDArray& a);

  FixedComplexNDArray (unsigned int is, unsigned int ds, 
		       const FixedNDArray& a);

  FixedComplexNDArray (Complex is, Complex ds, const FixedNDArray& a);

  FixedComplexNDArray (const MArrayN<int> &is, const MArrayN<int> &ds, 
		       const FixedNDArray& a);

  FixedComplexNDArray (const NDArray &is, const NDArray &ds, 
		       const FixedNDArray& a);

  FixedComplexNDArray (const ComplexNDArray &is, const ComplexNDArray &ds, 
		       const FixedNDArray& a);

  FixedComplexNDArray (unsigned int is, unsigned int ds, 
		       const ComplexNDArray& a);

  FixedComplexNDArray (Complex is, Complex ds, const ComplexNDArray& a);

  FixedComplexNDArray (const MArrayN<int> &is, const MArrayN<int> & ds, 
		       const ComplexNDArray& a);

  FixedComplexNDArray (const NDArray &is, const NDArray & ds, 
		       const ComplexNDArray& a);

  FixedComplexNDArray (const ComplexNDArray &is, 
		       const ComplexNDArray & ds, 
		       const ComplexNDArray& a);

  FixedComplexNDArray (unsigned int is, unsigned int ds, const NDArray& a);

  FixedComplexNDArray (Complex is, Complex ds, const NDArray& a);

  FixedComplexNDArray (const MArrayN<int> &is, const MArrayN<int> & ds, 
		       const NDArray& a);

  FixedComplexNDArray (const NDArray &is, const NDArray & ds, 
		       const NDArray& a);

  FixedComplexNDArray (const ComplexNDArray &is, 
		       const ComplexNDArray & ds, const NDArray& a);

  FixedComplexNDArray (unsigned int is, unsigned int ds,
		       const ComplexNDArray &a, const ComplexNDArray &b);

  FixedComplexNDArray (Complex is, Complex ds, const ComplexNDArray &a, 
		       const ComplexNDArray &b);

  FixedComplexNDArray (const MArrayN<int> &is, const MArrayN<int> &ds,
		       const ComplexNDArray &a, const ComplexNDArray &b);

  FixedComplexNDArray (const NDArray &is, const NDArray &ds,
		       const ComplexNDArray &a, const ComplexNDArray &b);

  FixedComplexNDArray (const ComplexNDArray &is, const ComplexNDArray &ds,
		       const ComplexNDArray &a, const ComplexNDArray &b);

  FixedComplexNDArray (const FixedNDArray& a);

  FixedComplexNDArray (const FixedNDArray& a, const FixedNDArray& b);

  FixedComplexNDArray (const FixedComplexNDArray& a)
    : MArrayN<FixedPointComplex> (a) { }

  FixedComplexNDArray (const MArrayN<FixedPointComplex>& a)
    : MArrayN<FixedPointComplex> (a) { }

  FixedComplexNDArray (const ArrayN<FixedPointComplex>& a)
    : MArrayN<FixedPointComplex> (a) { }

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
      MArrayN<FixedPointComplex>::operator = (a);
      return *this;
    }

  bool operator == (const FixedComplexNDArray& a) const;
  bool operator != (const FixedComplexNDArray& a) const;

  FixedComplexNDArray operator ! (void) const;

  boolNDArray all (int dim = -1) const;
  boolNDArray any (int dim = -1) const;

#ifdef HAVE_OLD_OCTAVE_CONCAT
  friend FixedComplexNDArray concat (const FixedComplexNDArray& ra, 
				     const FixedComplexNDArray& rb, 
				     const Array<int>& ra_idx);

  friend FixedComplexNDArray concat (const FixedComplexNDArray& ra, 
				     const FixedNDArray& rb, 
				     const Array<int>& ra_idx);

  friend FixedComplexNDArray concat (const FixedNDArray& ra, 
				     const FixedComplexNDArray& rb, 
				     const Array<int>& ra_idx);
#endif

#ifdef HAVE_OCTAVE_CONCAT
  FixedComplexNDArray concat (const FixedComplexNDArray& rb, 
			      const Array<int>& ra_idx);

  FixedComplexNDArray concat (const FixedNDArray& rb, 
			      const Array<int>& ra_idx);
#endif

#if defined (HAVE_OCTAVE_CONCAT) || defined (HAVE_OLD_OCTAVE_CONCAT)
  FixedComplexNDArray& insert (const FixedComplexNDArray& a, 
			       const Array<int>& ra_idx);
#endif

  FixedComplexNDArray cumprod (int dim = -1) const;
  FixedComplexNDArray cumsum (int dim = -1) const;
  FixedComplexNDArray prod (int dim = -1) const;
  FixedComplexNDArray sum (int dim = -1) const;
  FixedComplexNDArray sumsq (int dim = -1) const;

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

  friend ComplexNDArray fixedpoint (const FixedComplexNDArray& x) 
     { return x.fixedpoint(); }
  friend ComplexNDArray sign (const FixedComplexNDArray& x) 
     { return x.sign(); }
  friend ComplexNDArray getintsize (const FixedComplexNDArray& x) 
     { return x.getintsize(); }
  friend ComplexNDArray getdecsize (const FixedComplexNDArray& x) 
     { return x.getdecsize(); }
  friend ComplexNDArray getnumber (const FixedComplexNDArray& x) 
     { return x.getnumber(); }

  FixedComplexNDArray max (int dim = 0) const;
  FixedComplexNDArray max (ArrayN<int>& index, int dim = 0) const;
  FixedComplexNDArray min (int dim = 0) const;
  FixedComplexNDArray min (ArrayN<int>& index, int dim = 0) const;

  FixedNDArray abs (void) const;

  FixedComplexMatrix fixed_complex_matrix_value (void) const;

  FixedComplexNDArray squeeze (void) const 
    { return ArrayN<FixedPointComplex>::squeeze (); }

  static void increment_index (Array<int>& ra_idx,
			       const dim_vector& dimensions,
			       int start_dimension = 0);

  static int compute_index (Array<int>& ra_idx,
			    const dim_vector& dimensions);

  // i/o

  friend std::ostream& operator << (std::ostream& os, 
				    const FixedComplexNDArray& a);
  friend std::istream& operator >> (std::istream& is, FixedComplexNDArray& a);

  static FixedPointComplex resize_fill_value (void) 
      { return FixedPointComplex(); }

private:

  FixedComplexNDArray (FixedPointComplex *d, const dim_vector& dv) 
    : MArrayN<FixedPointComplex> (d, dv) { }
};


extern FixedComplexNDArray min (const FixedPointComplex& c, 
				const FixedComplexNDArray& m);
extern FixedComplexNDArray min (const FixedComplexNDArray& m, 
				const FixedPointComplex& c);
extern FixedComplexNDArray min (const FixedComplexNDArray& a, 
				const FixedComplexNDArray& b);

extern FixedComplexNDArray max (const FixedPointComplex& c, 
				const FixedComplexNDArray& m);
extern FixedComplexNDArray max (const FixedComplexNDArray& m, 
				const FixedPointComplex& c);
extern FixedComplexNDArray max (const FixedComplexNDArray& a, 
				const FixedComplexNDArray& b);

FixedComplexNDArray elem_pow (const FixedComplexNDArray &a,
			      const FixedComplexNDArray &b);
FixedComplexNDArray elem_pow (const FixedComplexNDArray &a,
			      const FixedPointComplex &b);
FixedComplexNDArray elem_pow (const FixedPointComplex &a,
			      const FixedComplexNDArray &b);

NDS_CMP_OP_DECLS (FixedComplexNDArray, FixedPointComplex)
NDS_BOOL_OP_DECLS (FixedComplexNDArray, FixedPointComplex)

SND_CMP_OP_DECLS (FixedPointComplex, FixedComplexNDArray)
SND_BOOL_OP_DECLS (FixedPointComplex, FixedComplexNDArray)

NDND_CMP_OP_DECLS (FixedComplexNDArray, FixedComplexNDArray)
NDND_BOOL_OP_DECLS (FixedComplexNDArray, FixedComplexNDArray)

MARRAY_FORWARD_DEFS (MArrayN, FixedComplexNDArray, FixedPointComplex)

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/


