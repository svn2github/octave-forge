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

#if !defined (octave_FixedCRowVector_h)
#define octave_FixedCRowVector_h 1

#include <octave/MArray.h>
#include <octave/CRowVector.h>
#include <octave/dRowVector.h>
#include <octave/mx-defs.h>
#include <octave/mx-op-defs.h>

#include "int/fixed.h"
#include "fixedComplex.h"
#include "fixedRowVector.h"

#if !defined(octave_FixedCColVector_h)
class FixedComplexColumnVector;
#endif
#if !defined(octave_FixedCMatrix_h)
class FixedComplexMatrix;
#endif

typedef FixedPointComplex (*fpc_fpc_Mapper)(FixedPointComplex);

class
OCTAVE_FIXED_API 
FixedComplexRowVector : public MArray<FixedPointComplex>
{
public:

  FixedComplexRowVector (void) : MArray<FixedPointComplex> () { }

  explicit FixedComplexRowVector (int n) : MArray<FixedPointComplex> (dim_vector (1, n)) { }

  FixedComplexRowVector (int n, FixedPointComplex val) : 
    MArray<FixedPointComplex> (dim_vector (1, n), val) { }

  FixedComplexRowVector (const MArray<int> &is, const MArray<int> & ds);

  FixedComplexRowVector (const RowVector &is, const RowVector &ds);

  FixedComplexRowVector (const ComplexRowVector &is, 
			 const ComplexRowVector &ds);

  FixedComplexRowVector (unsigned int is, unsigned int ds, 
			 const FixedComplexRowVector& a);

  FixedComplexRowVector (Complex is, Complex ds, 
			 const FixedComplexRowVector& a);

  FixedComplexRowVector (const MArray<int> &is, const MArray<int> &ds, 
			 const FixedComplexRowVector& a);

  FixedComplexRowVector (const RowVector &is, const RowVector &ds, 
			 const FixedComplexRowVector& a);

  FixedComplexRowVector (const ComplexRowVector &is, 
			 const ComplexRowVector &ds, 
			 const FixedComplexRowVector& a);

  FixedComplexRowVector (unsigned int is, unsigned int ds, 
			 const FixedRowVector& a);

  FixedComplexRowVector (Complex is, Complex ds, 
			 const FixedRowVector& a);

  FixedComplexRowVector (const MArray<int> &is, const MArray<int> &ds, 
			 const FixedRowVector& a);

  FixedComplexRowVector (const RowVector &is, const RowVector &ds, 
			 const FixedRowVector& a);

  FixedComplexRowVector (const ComplexRowVector &is, 
			 const ComplexRowVector &ds, 
			 const FixedRowVector& a);

  FixedComplexRowVector (unsigned int is, unsigned int ds, 
			 const ComplexRowVector& a);

  FixedComplexRowVector (Complex is, Complex ds, const ComplexRowVector& a);

  FixedComplexRowVector (const MArray<int> &is, const MArray<int> &ds, 
			 const ComplexRowVector& a);

  FixedComplexRowVector (const RowVector &is, const RowVector &ds, 
			 const ComplexRowVector& a);

  FixedComplexRowVector (const ComplexRowVector &is, 
			 const ComplexRowVector &ds, 
			 const ComplexRowVector& a);

  FixedComplexRowVector (unsigned int is, unsigned int ds, const RowVector& a);

  FixedComplexRowVector (Complex is, Complex ds, const RowVector& a);

  FixedComplexRowVector (const MArray<int> &is, const MArray<int> &ds, 
			 const RowVector& a);

  FixedComplexRowVector (const RowVector &is, const RowVector &ds, 
			 const RowVector& a);

  FixedComplexRowVector (const ComplexRowVector &is, 
			 const ComplexRowVector &ds, const RowVector& a);

  FixedComplexRowVector (unsigned int is, unsigned int ds, 
			 const ComplexRowVector& a, const ComplexRowVector &b);

  FixedComplexRowVector (Complex is, Complex ds, const ComplexRowVector& a, 
			 const ComplexRowVector &b);

  FixedComplexRowVector (const MArray<int> &is, const MArray<int> &ds, 
			 const ComplexRowVector& a, const ComplexRowVector &b);

  FixedComplexRowVector (const RowVector &is, const RowVector &ds, 
			 const ComplexRowVector& a, const ComplexRowVector &b);

  FixedComplexRowVector (const ComplexRowVector &is, 
			 const ComplexRowVector &ds, 
			 const ComplexRowVector& a, const ComplexRowVector &b);

  FixedComplexRowVector (const FixedRowVector& a);

  FixedComplexRowVector (const FixedRowVector &a, const FixedRowVector &b); 

  FixedComplexRowVector (const FixedComplexRowVector& a) : MArray<FixedPointComplex> (a) { }

  FixedComplexRowVector (const MArray<FixedPointComplex>& a) : MArray<FixedPointComplex> (a) { }

  ComplexRowVector sign (void) const;
  ComplexRowVector getdecsize (void) const;
  ComplexRowVector getintsize (void) const;
  ComplexRowVector getnumber (void) const;
  ComplexRowVector fixedpoint (void) const;
  FixedComplexRowVector chdecsize (const Complex n);
  FixedComplexRowVector chdecsize (const ComplexRowVector &n);
  FixedComplexRowVector chintsize (const Complex n);
  FixedComplexRowVector chintsize (const ComplexRowVector &n);
  FixedComplexRowVector incdecsize (const Complex n);
  FixedComplexRowVector incdecsize (const ComplexRowVector &n);
  FixedComplexRowVector incdecsize ();
  FixedComplexRowVector incintsize (const Complex n);
  FixedComplexRowVector incintsize (const ComplexRowVector &n);
  FixedComplexRowVector incintsize ();

  FixedComplexRowVector& operator = (const FixedComplexRowVector& a)
    {
      MArray<FixedPointComplex>::operator = (a);
      return *this;
    }

  bool operator == (const FixedComplexRowVector& a) const;
  bool operator != (const FixedComplexRowVector& a) const;

  // destructive insert/delete/reorder operations

  FixedComplexRowVector& insert (const FixedComplexRowVector& a, int c);

  FixedComplexRowVector& fill (FixedPointComplex val);
  FixedComplexRowVector& fill (FixedPointComplex val, int c1, int c2);

  FixedComplexRowVector append (const FixedComplexRowVector& a) const;

  FixedComplexColumnVector transpose (void) const;

  // resize is the destructive equivalent for this one

  FixedComplexRowVector extract (int c1, int c2) const;

  FixedComplexRowVector extract_n (int c1, int n) const;

  // other operations

  FixedComplexRowVector map (fpc_fpc_Mapper f) const;

  FixedComplexRowVector& apply (fpc_fpc_Mapper f);

  FixedPointComplex min (void) const;
  FixedPointComplex max (void) const;

  friend FixedComplexRowVector operator * (const FixedComplexRowVector& a, const Matrix& b);

  friend FixedRowVector real (const FixedComplexRowVector &x);
  friend FixedRowVector imag (const FixedComplexRowVector &x);
  friend FixedComplexRowVector conj (const FixedComplexRowVector &x);

  friend FixedRowVector abs (const FixedComplexRowVector &x);
  friend FixedRowVector norm (const FixedComplexRowVector &x);
  friend FixedRowVector arg (const FixedComplexRowVector &x);
  friend FixedComplexRowVector polar (const FixedRowVector &r, 
				       const FixedRowVector &p);

  friend FixedComplexRowVector cos  (const FixedComplexRowVector &x);
  friend FixedComplexRowVector cosh  (const FixedComplexRowVector &x);
  friend FixedComplexRowVector sin  (const FixedComplexRowVector &x);
  friend FixedComplexRowVector sinh  (const FixedComplexRowVector &x);
  friend FixedComplexRowVector tan  (const FixedComplexRowVector &x);
  friend FixedComplexRowVector tanh  (const FixedComplexRowVector &x);

  friend FixedComplexRowVector sqrt  (const FixedComplexRowVector &x);
  friend FixedComplexRowVector exp  (const FixedComplexRowVector &x);
  friend FixedComplexRowVector log  (const FixedComplexRowVector &x);
  friend FixedComplexRowVector log10  (const FixedComplexRowVector &x);

  friend FixedComplexRowVector round (const FixedComplexRowVector &x);
  friend FixedComplexRowVector rint (const FixedComplexRowVector &x);
  friend FixedComplexRowVector floor (const FixedComplexRowVector &x);
  friend FixedComplexRowVector ceil (const FixedComplexRowVector &x);

  friend ComplexRowVector fixedpoint (const FixedComplexRowVector& x);
  friend ComplexRowVector sign (const FixedComplexRowVector& x);
  friend ComplexRowVector getintsize (const FixedComplexRowVector& x);
  friend ComplexRowVector getdecsize (const FixedComplexRowVector& x);
  friend ComplexRowVector getnumber (const FixedComplexRowVector& x);

  // i/o

  friend std::ostream& operator << (std::ostream& os, const FixedComplexRowVector& a);
  friend std::istream& operator >> (std::istream& is, FixedComplexRowVector& a);

  void resize (octave_idx_type n,
               const FixedPointComplex& rfv = FixedPointComplex ())
  {
    Array<FixedPointComplex>::resize (dim_vector (1, n), rfv);
  }
};

FixedPointComplex operator * (const FixedComplexRowVector& a, 
			      const FixedComplexColumnVector& b);

FixedRowVector real (const FixedComplexRowVector &x);
FixedRowVector imag (const FixedComplexRowVector &x);
FixedComplexRowVector conj (const FixedComplexRowVector &x);

FixedRowVector abs (const FixedComplexRowVector &x);
FixedRowVector norm (const FixedComplexRowVector &x);
FixedRowVector arg (const FixedComplexRowVector &x);
FixedComplexRowVector polar (const FixedRowVector &r, 
				       const FixedRowVector &p);

FixedComplexRowVector cos  (const FixedComplexRowVector &x);
FixedComplexRowVector cosh  (const FixedComplexRowVector &x);
FixedComplexRowVector sin  (const FixedComplexRowVector &x);
FixedComplexRowVector sinh  (const FixedComplexRowVector &x);
FixedComplexRowVector tan  (const FixedComplexRowVector &x);
FixedComplexRowVector tanh  (const FixedComplexRowVector &x);

FixedComplexRowVector sqrt  (const FixedComplexRowVector &x);
FixedComplexRowVector exp  (const FixedComplexRowVector &x);
FixedComplexRowVector log  (const FixedComplexRowVector &x);
FixedComplexRowVector log10  (const FixedComplexRowVector &x);

FixedComplexRowVector round (const FixedComplexRowVector &x);
FixedComplexRowVector rint (const FixedComplexRowVector &x);
FixedComplexRowVector floor (const FixedComplexRowVector &x);
FixedComplexRowVector ceil (const FixedComplexRowVector &x);

inline ComplexRowVector fixedpoint (const FixedComplexRowVector& x) 
     { return x.fixedpoint(); }
inline ComplexRowVector sign (const FixedComplexRowVector& x) 
     { return x.sign(); }
inline ComplexRowVector getintsize (const FixedComplexRowVector& x) 
     { return x.getintsize(); }
inline ComplexRowVector getdecsize (const FixedComplexRowVector& x) 
     { return x.getdecsize(); }
inline ComplexRowVector getnumber (const FixedComplexRowVector& x) 
     { return x.getnumber(); }

std::ostream& operator << (std::ostream& os, const FixedComplexRowVector& a);
std::istream& operator >> (std::istream& is, FixedComplexRowVector& a);


FixedComplexRowVector elem_pow (const FixedComplexRowVector &a,
			     const FixedComplexRowVector &b);
FixedComplexRowVector elem_pow (const FixedComplexRowVector &a,
			     const FixedPointComplex &b);
FixedComplexRowVector elem_pow (const FixedPointComplex &a,
			     const FixedComplexRowVector &b);

MARRAY_FORWARD_DEFS (MArray, FixedComplexRowVector, FixedPointComplex)

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
