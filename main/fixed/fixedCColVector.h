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

#if !defined (octave_FixedCColumnVector_h)
#define octave_FixedCColumnVector_h 1

#if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#pragma interface
#endif

#include <octave/MArray.h>
#include <octave/CColVector.h>
#include <octave/dColVector.h>
#include <octave/mx-defs.h>
#include <octave/mx-op-defs.h>

#include "int/fixed.h"
#include "fixedComplex.h"
#include "fixedColVector.h"

#if !defined(octave_FixedCRowVector_h)
class FixedComplexRowVector;
#endif
#if !defined(octave_FixedCMatrix_h)
class FixedComplexMatrix;
#endif

typedef FixedPointComplex (*fc_fc_Mapper)(FixedPointComplex);

class
FixedComplexColumnVector : public MArray<FixedPointComplex>
{
public:

  FixedComplexColumnVector (void) : MArray<FixedPointComplex> () { }

  explicit FixedComplexColumnVector (int n) : MArray<FixedPointComplex> (n) { }

  FixedComplexColumnVector (int n, FixedPointComplex val) : 
    MArray<FixedPointComplex> (n, val) { }

  FixedComplexColumnVector (const MArray<int> &is, const MArray<int> &ds);

  FixedComplexColumnVector (const ColumnVector &is, const ColumnVector &ds);

  FixedComplexColumnVector (const ComplexColumnVector &is, 
			    const ComplexColumnVector &ds);

  FixedComplexColumnVector (unsigned int is, unsigned int ds, 
		     const FixedComplexColumnVector& a);

  FixedComplexColumnVector (Complex is, Complex ds, 
		     const FixedComplexColumnVector& a);

  FixedComplexColumnVector (const MArray<int> &is, const MArray<int> &ds, 
		     const FixedComplexColumnVector& a);

  FixedComplexColumnVector (const ColumnVector &is, const ColumnVector &ds, 
		     const FixedComplexColumnVector& a);

  FixedComplexColumnVector (const ComplexColumnVector &is, 
			    const ComplexColumnVector &ds, 
			    const FixedComplexColumnVector& a);

  FixedComplexColumnVector (unsigned int is, unsigned int ds, 
		     const FixedColumnVector& a);

  FixedComplexColumnVector (Complex is, Complex ds, 
		     const FixedColumnVector& a);

  FixedComplexColumnVector (const MArray<int> &is, const MArray<int> &ds, 
		     const FixedColumnVector& a);

  FixedComplexColumnVector (const ColumnVector &is, const ColumnVector &ds, 
		     const FixedColumnVector& a);

  FixedComplexColumnVector (const ComplexColumnVector &is, 
			    const ComplexColumnVector &ds, 
			    const FixedColumnVector& a);

  FixedComplexColumnVector (unsigned int is, unsigned int ds, 
		     const ComplexColumnVector& a);

  FixedComplexColumnVector (Complex is, Complex ds, 
		     const ComplexColumnVector& a);

  FixedComplexColumnVector (const MArray<int> &is, const MArray<int> &ds, 
		     const ComplexColumnVector& a);

  FixedComplexColumnVector (const ColumnVector &is, const ColumnVector &ds, 
		     const ComplexColumnVector& a);

  FixedComplexColumnVector (const ComplexColumnVector &is, 
			    const ComplexColumnVector &ds, 
			    const ComplexColumnVector& a);

  FixedComplexColumnVector (unsigned int is, unsigned int ds, 
			    const ColumnVector& a);

  FixedComplexColumnVector (Complex is, Complex ds, const ColumnVector& a);

  FixedComplexColumnVector (const MArray<int> &is, const MArray<int> &ds, 
		     const ColumnVector& a);

  FixedComplexColumnVector (const ColumnVector &is, const ColumnVector &ds, 
		     const ColumnVector& a);

  FixedComplexColumnVector (const ComplexColumnVector &is, 
			    const ComplexColumnVector &ds, 
			    const ColumnVector& a);

  FixedComplexColumnVector (unsigned int is, unsigned int ds, 
	const ComplexColumnVector& a, const ComplexColumnVector &b);

  FixedComplexColumnVector (Complex is, Complex ds, 
	const ComplexColumnVector& a,  const ComplexColumnVector &b);

  FixedComplexColumnVector (const MArray<int> &is, const MArray<int> &ds, 
	const ComplexColumnVector& a, const ComplexColumnVector &b);

  FixedComplexColumnVector (const ColumnVector &is, const ColumnVector &ds, 
	const ComplexColumnVector& a, const ComplexColumnVector &b);

  FixedComplexColumnVector (const ComplexColumnVector &is, 
	const ComplexColumnVector &ds, const ComplexColumnVector& a, 
	const ComplexColumnVector &b);

  FixedComplexColumnVector (const FixedColumnVector& a);

  FixedComplexColumnVector (const FixedColumnVector &a, const FixedColumnVector &b); 

  FixedComplexColumnVector (const FixedComplexColumnVector& a) : MArray<FixedPointComplex> (a) { }

  FixedComplexColumnVector (const MArray<FixedPointComplex>& a) : MArray<FixedPointComplex> (a) { }

  ComplexColumnVector sign (void) const;
  ComplexColumnVector getdecsize (void) const;
  ComplexColumnVector getintsize (void) const;
  ComplexColumnVector getnumber (void) const;
  ComplexColumnVector fixedpoint (void) const;
  FixedComplexColumnVector chdecsize (const Complex n);
  FixedComplexColumnVector chdecsize (const ComplexColumnVector &n);
  FixedComplexColumnVector chintsize (const Complex n);
  FixedComplexColumnVector chintsize (const ComplexColumnVector &n);
  FixedComplexColumnVector incdecsize (const Complex n);
  FixedComplexColumnVector incdecsize (const ComplexColumnVector &n);
  FixedComplexColumnVector incdecsize ();
  FixedComplexColumnVector incintsize (const Complex n);
  FixedComplexColumnVector incintsize (const ComplexColumnVector &n);
  FixedComplexColumnVector incintsize ();

  FixedComplexColumnVector& operator = (const FixedComplexColumnVector& a)
    {
      MArray<FixedPointComplex>::operator = (a);
      return *this;
    }

  bool operator == (const FixedComplexColumnVector& a) const;
  bool operator != (const FixedComplexColumnVector& a) const;

  // destructive insert/delete/reorder operations

  FixedComplexColumnVector& insert (const FixedComplexColumnVector& a, int r);

  FixedComplexColumnVector& fill (FixedPointComplex val);
  FixedComplexColumnVector& fill (FixedPointComplex val, int r1, int r2);

  FixedComplexColumnVector stack (const FixedComplexColumnVector& a) const;

  FixedComplexRowVector transpose (void) const;

  // resize is the destructive equivalent for this one

  FixedComplexColumnVector extract (int r1, int r2) const;

  FixedComplexColumnVector extract_n (int r1, int n) const;

  // matrix by column vector -> column vector operations

  friend FixedComplexColumnVector operator * (const FixedComplexMatrix& a, 
				const FixedComplexColumnVector& b);

  // other operations

  FixedComplexColumnVector map (fc_fc_Mapper f) const;

  FixedComplexColumnVector& apply (fc_fc_Mapper f);

  FixedPointComplex min (void) const;
  FixedPointComplex max (void) const;

  friend FixedColumnVector real (const FixedComplexColumnVector &x);
  friend FixedColumnVector imag (const FixedComplexColumnVector &x);
  friend FixedComplexColumnVector conj (const FixedComplexColumnVector &x);

  friend FixedColumnVector abs (const FixedComplexColumnVector &x);
  friend FixedColumnVector norm (const FixedComplexColumnVector &x);
  friend FixedColumnVector arg (const FixedComplexColumnVector &x);
  friend FixedComplexColumnVector polar (const FixedColumnVector &r, 
				       const FixedColumnVector &p);

  friend FixedComplexColumnVector cos  (const FixedComplexColumnVector &x);
  friend FixedComplexColumnVector cosh  (const FixedComplexColumnVector &x);
  friend FixedComplexColumnVector sin  (const FixedComplexColumnVector &x);
  friend FixedComplexColumnVector sinh  (const FixedComplexColumnVector &x);
  friend FixedComplexColumnVector tan  (const FixedComplexColumnVector &x);
  friend FixedComplexColumnVector tanh  (const FixedComplexColumnVector &x);

  friend FixedComplexColumnVector sqrt  (const FixedComplexColumnVector &x);
  friend FixedComplexColumnVector exp  (const FixedComplexColumnVector &x);
  friend FixedComplexColumnVector log  (const FixedComplexColumnVector &x);
  friend FixedComplexColumnVector log10  (const FixedComplexColumnVector &x);

  friend FixedComplexColumnVector round (const FixedComplexColumnVector &x);
  friend FixedComplexColumnVector rint (const FixedComplexColumnVector &x);
  friend FixedComplexColumnVector floor (const FixedComplexColumnVector &x);
  friend FixedComplexColumnVector ceil (const FixedComplexColumnVector &x);

  friend ComplexColumnVector fixedpoint (const FixedComplexColumnVector& x) 
     { return x.fixedpoint(); }
  friend ComplexColumnVector sign (const FixedComplexColumnVector& x) 
     { return x.sign(); }
  friend ComplexColumnVector getintsize (const FixedComplexColumnVector& x) 
     { return x.getintsize(); }
  friend ComplexColumnVector getdecsize (const FixedComplexColumnVector& x) 
     { return x.getdecsize(); }
  friend ComplexColumnVector getnumber (const FixedComplexColumnVector& x) 
     { return x.getnumber(); }

  // i/o

  friend std::ostream& operator << (std::ostream& os, const FixedComplexColumnVector& a);
  friend std::istream& operator >> (std::istream& is, FixedComplexColumnVector& a);

private:

  FixedComplexColumnVector (FixedPointComplex *d, int l) : MArray<FixedPointComplex> (d, l) { }
};

FixedComplexColumnVector elem_pow (const FixedComplexColumnVector &a,
			     const FixedComplexColumnVector &b);
FixedComplexColumnVector elem_pow (const FixedComplexColumnVector &a,
			     const FixedPointComplex &b);
FixedComplexColumnVector elem_pow (const FixedPointComplex &a,
			     const FixedComplexColumnVector &b);

MARRAY_FORWARD_DEFS (MArray, FixedComplexColumnVector, FixedPointComplex)

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
