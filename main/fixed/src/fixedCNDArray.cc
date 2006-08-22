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

#include <iostream>

#include <octave/config.h>
#include <octave/lo-error.h>
#include <octave/lo-utils.h>
#include <octave/lo-error.h>
#include <octave/lo-mappers.h>
#include <octave/error.h>
#include <octave/dMatrix.h>
#include <octave/dNDArray.h>
#include <octave/CNDArray.h>
#include <octave/gripes.h>
#include <octave/ops.h>
#include <octave/quit.h>

#include "fixedCMatrix.h"
#include "fixedCNDArray.h"

// Fixed Point Complex Matrix class.

FixedComplexNDArray::FixedComplexNDArray (const MArrayN<int> &is, 
					const MArrayN<int> &ds)
  : MArrayN<FixedPointComplex> (is.dims())
{
  if (dims () != ds.dims ()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i));
}

FixedComplexNDArray::FixedComplexNDArray (const NDArray &is, 
					  const NDArray &ds)
  : MArrayN<FixedPointComplex> (is.dims())
{
  if (dims () != ds.dims ()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i));
}

FixedComplexNDArray::FixedComplexNDArray (const ComplexNDArray &is, 
					const ComplexNDArray &ds)
  : MArrayN<FixedPointComplex> (is.dims())
{
  if (dims () != ds.dims ()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i));
}

FixedComplexNDArray::FixedComplexNDArray (unsigned int is, 
					  unsigned int ds, 
					  const FixedComplexNDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is, ds, a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (Complex is, Complex ds, 
					  const FixedComplexNDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is, ds, a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const MArrayN<int> &is,
					  const MArrayN<int> &ds, 
					  const FixedComplexNDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if ((dims() != is.dims()) || (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i),
				 a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const NDArray &is, 
					  const NDArray &ds, 
					  const FixedComplexNDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if ((dims() != is.dims()) || (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i),
				 a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const ComplexNDArray &is,
					  const ComplexNDArray &ds, 
					  const FixedComplexNDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if ((dims() != is.dims()) || (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i), a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (unsigned int is, 
					  unsigned int ds, 
					  const FixedNDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is, ds, a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (Complex is, Complex ds, 
					  const FixedNDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is, ds, a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const MArrayN<int> &is,
					  const MArrayN<int> &ds, 
					  const FixedNDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if ((dims() != is.dims()) || (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i),
				 a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const NDArray &is, 
					  const NDArray &ds, 
					  const FixedNDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if ((dims() != is.dims()) || (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i),
				 a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const ComplexNDArray &is,
					  const ComplexNDArray &ds, 
					  const FixedNDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if ((dims() != is.dims()) || (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i), a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (unsigned int is, 
					  unsigned int ds, 
					  const ComplexNDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is, ds, a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (Complex is, Complex ds, 
					  const ComplexNDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is, ds, a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const MArrayN<int> &is, 
					  const MArrayN<int> &ds, 
					  const ComplexNDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if ((dims() != is.dims()) || (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i),
				 a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const NDArray &is, 
					  const NDArray &ds, 
					  const ComplexNDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if ((dims() != is.dims()) || (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i),
				 a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const ComplexNDArray &is,
					  const ComplexNDArray &ds, 
					  const ComplexNDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if ((dims() != is.dims()) || (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i), a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (unsigned int is, 
					  unsigned int ds, 
					  const NDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is, ds, a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (Complex is, Complex ds, 
					  const NDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is, ds, a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const MArrayN<int> &is, 
					  const MArrayN<int> &ds, 
					  const NDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if ((dims() != is.dims()) || (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i),
				 a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const NDArray &is, 
					  const NDArray &ds, 
					  const NDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if ((dims() != is.dims()) || (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i),
				 a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const ComplexNDArray &is, 
					  const ComplexNDArray &ds, 
					  const NDArray& a)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if ((dims() != is.dims()) || (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i), a.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (unsigned int is, 
					  unsigned int ds, 
					  const ComplexNDArray& a, 
					  const ComplexNDArray& b)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if (dims() != b.dims()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is, ds, a.elem (i), b.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (Complex is, Complex ds, 
					  const ComplexNDArray& a, 
					  const ComplexNDArray& b)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if (dims() != b.dims()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is, ds, a.elem (i), b.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const MArrayN<int> &is, 
					  const MArrayN<int> &ds, 
					  const ComplexNDArray& a, 
					  const ComplexNDArray& b)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if ((dims() != b.dims()) || (dims() != is.dims()) 
      || (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is (i), ds (i), a.elem (i), b.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const NDArray &is, 
					  const NDArray &ds, 
					  const ComplexNDArray& a, 
					  const ComplexNDArray& b)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if ((dims() != b.dims()) || (dims() != is.dims()) 
      || (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex((unsigned int)is (i), 
				 (unsigned int)ds (i), 
				 a.elem (i), b.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const ComplexNDArray &is, 
		const ComplexNDArray &ds, const ComplexNDArray& a, 
		const ComplexNDArray& b)
  : MArrayN<FixedPointComplex> (a.dims())
{
  if ((dims() != b.dims()) || (dims() != is.dims()) 
      || (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(is (i), ds (i), a.elem (i), b.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const FixedNDArray& m)
  : MArrayN<FixedPointComplex> (m.dims (), FixedPointComplex())
{
  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(m.elem (i));
}

FixedComplexNDArray::FixedComplexNDArray (const FixedNDArray& a,
					  const FixedNDArray& b)
  : MArrayN<FixedPointComplex> (a.dims (), FixedPointComplex())
{
  if (dims() != b.dims()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }
  
  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPointComplex(a.elem (i), b.elem (i));
}

#define GET_FIXED_PROP(METHOD) \
  ComplexNDArray \
  FixedComplexNDArray:: METHOD (void) const \
    { \
      int nel = nelem (); \
      ComplexNDArray retval(dims());  \
      for (int i = 0; i < nel; i++)   \
          retval(i) = elem(i) . METHOD (); \
      return retval; \
    } \

GET_FIXED_PROP(sign);
GET_FIXED_PROP(getdecsize);
GET_FIXED_PROP(getintsize);
GET_FIXED_PROP(getnumber);
GET_FIXED_PROP(fixedpoint);

#undef GET_FIXED_PROP

FixedComplexNDArray 
FixedComplexNDArray::chdecsize (const Complex n)
{
  int nel = nelem();
  FixedComplexNDArray retval(dims());

  for (int i = 0; i < nel; i++)
    retval(i) = FixedPointComplex(elem(i).getintsize(), n, elem(i));

  return retval;
}

FixedComplexNDArray 
FixedComplexNDArray::chdecsize (const ComplexNDArray &n)
{
  int nel = nelem();

  if (dims() != n.dims()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch in chdecsize");
    return FixedComplexNDArray();
  }

  FixedComplexNDArray retval(dims());

  for (int i = 0; i < nel; i++)
    retval(i) = FixedPointComplex(elem(i).getintsize(), n(i), elem(i));

  return retval;
}

FixedComplexNDArray 
FixedComplexNDArray::chintsize (const Complex n)
{
  int nel = nelem();
  FixedComplexNDArray retval(dims());

  for (int i = 0; i < nel; i++)
    retval(i) = FixedPointComplex(n, elem(i).getdecsize(), elem(i));

  return retval;
}

FixedComplexNDArray 
FixedComplexNDArray::chintsize (const ComplexNDArray &n)
{
  int nel = nelem();

  if (dims() != n.dims()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch in chintsize");
    return FixedComplexNDArray();
  }

  FixedComplexNDArray retval(dims());

  for (int i = 0; i < nel; i++)
      retval(i) = FixedPointComplex(n(i), elem(i).getdecsize(), elem(i));

  return retval;
}

FixedComplexNDArray 
FixedComplexNDArray::incdecsize (const Complex n) {
  return chdecsize(n + getdecsize());
}

FixedComplexNDArray
FixedComplexNDArray::incdecsize (const ComplexNDArray &n) {
  if (dims() != n.dims()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch in chintsize");
    return FixedComplexNDArray();
  }
  return chdecsize(n + getdecsize());
}

FixedComplexNDArray 
FixedComplexNDArray::incdecsize () {
  return chdecsize(Complex(1,1) + getdecsize());
}

FixedComplexNDArray 
FixedComplexNDArray::incintsize (const Complex n) {
  return chintsize(n + getintsize());
}

FixedComplexNDArray
FixedComplexNDArray::incintsize (const ComplexNDArray &n) {
  if (dims() != n.dims()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch in chintsize");
    return FixedComplexNDArray();
  }
  return chintsize(n + getintsize());
}

FixedComplexNDArray 
FixedComplexNDArray::incintsize () {
  return chintsize(Complex(1,1) + getintsize());
}

bool
FixedComplexNDArray::operator == (const FixedComplexNDArray& a) const
{
  if (dims() != a.dims()) 
    return false;

  for (int i = 0; i < nelem(); i++)
    if (elem(i) != a.elem(i))
      return false;
  return true;
}

bool
FixedComplexNDArray::operator != (const FixedComplexNDArray& a) const
{
  return !(*this != a);
}

FixedComplexNDArray
FixedComplexNDArray::operator ! (void) const
{
  int nel = nelem ();
  FixedComplexNDArray b (dims());

  for (int i = 0; i < nel; i++)
    b.elem (i) =  ! elem (i) ;
  
  return b;
}

boolNDArray
FixedComplexNDArray::all (octave_idx_type dim) const
{
#define FMX_ND_ALL_EXPR  elem (iter_idx) .fixedpoint () == Complex (0, 0)
  MX_ND_ANY_ALL_REDUCTION (MX_ND_ALL_EVAL (FMX_ND_ALL_EXPR), true);
#undef FMX_ND_ALL_EXPR
}

boolNDArray
FixedComplexNDArray::any (octave_idx_type dim) const
{
#define FMX_ND_ANY_EXPR  elem (iter_idx) .fixedpoint () != Complex (0, 0)
  MX_ND_ANY_ALL_REDUCTION (MX_ND_ANY_EVAL (FMX_ND_ANY_EXPR), false);
#undef FMX_ND_ANY_EXPR
}

FixedComplexNDArray
FixedComplexNDArray::cumprod (octave_idx_type dim) const
{
  FixedPointComplex one (1, 0, 1, 0);
  MX_ND_CUMULATIVE_OP (FixedComplexNDArray, FixedPointComplex, one, *);
}

FixedComplexNDArray
FixedComplexNDArray::cumsum (octave_idx_type dim) const
{
  FixedPointComplex zero;
  MX_ND_CUMULATIVE_OP (FixedComplexNDArray, FixedPointComplex, zero, +);
}

FixedComplexNDArray
FixedComplexNDArray::prod (octave_idx_type dim) const
{
  FixedPointComplex one(1, 0, 1, 0);
  MX_ND_REDUCTION (retval(result_idx) *= elem (iter_idx), one,
		   FixedComplexNDArray);
}

FixedComplexNDArray
FixedComplexNDArray::sum (octave_idx_type dim) const
{
  FixedPointComplex zero;
  MX_ND_REDUCTION (retval(result_idx) += elem (iter_idx), zero,
		   FixedComplexNDArray);
}

FixedComplexNDArray
FixedComplexNDArray::sumsq (octave_idx_type dim) const
{
  FixedPointComplex zero;
  MX_ND_REDUCTION (retval(result_idx) += elem (iter_idx) * 
		   conj (elem (iter_idx)), zero, FixedComplexNDArray);
}

FixedNDArray
FixedComplexNDArray::abs (void) const
{
  int nel = nelem ();

  FixedNDArray retval (dims());

  for (int i = 0; i < nel; i++)
    retval (i) = ::abs(elem (i));

  return retval;
}

#define DO_FIXED_MAT_FUNC(FUNC, MT) \
  MT FUNC (const FixedComplexNDArray& x) \
  {  \
    MT retval (x.dims()); \
    for (int i = 0; i < x.nelem(); i++) \
      retval(i) = FUNC ( x (i) ); \
    return retval; \
  }

DO_FIXED_MAT_FUNC(real, FixedNDArray);
DO_FIXED_MAT_FUNC(imag, FixedNDArray);
DO_FIXED_MAT_FUNC(conj, FixedComplexNDArray);
DO_FIXED_MAT_FUNC(abs, FixedNDArray);
DO_FIXED_MAT_FUNC(norm, FixedNDArray);
DO_FIXED_MAT_FUNC(arg, FixedNDArray);
DO_FIXED_MAT_FUNC(cos, FixedComplexNDArray);
DO_FIXED_MAT_FUNC(cosh, FixedComplexNDArray);
DO_FIXED_MAT_FUNC(sin, FixedComplexNDArray);
DO_FIXED_MAT_FUNC(sinh, FixedComplexNDArray);
DO_FIXED_MAT_FUNC(tan, FixedComplexNDArray);
DO_FIXED_MAT_FUNC(tanh, FixedComplexNDArray);
DO_FIXED_MAT_FUNC(sqrt, FixedComplexNDArray);
DO_FIXED_MAT_FUNC(exp, FixedComplexNDArray);
DO_FIXED_MAT_FUNC(log, FixedComplexNDArray);
DO_FIXED_MAT_FUNC(log10, FixedComplexNDArray);
DO_FIXED_MAT_FUNC(round, FixedComplexNDArray);
DO_FIXED_MAT_FUNC(rint, FixedComplexNDArray);
DO_FIXED_MAT_FUNC(floor, FixedComplexNDArray);
DO_FIXED_MAT_FUNC(ceil, FixedComplexNDArray);

FixedComplexNDArray polar (const FixedNDArray &r, const FixedNDArray &p)
{
  if (r.dims () != p.dims ()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return FixedComplexNDArray();
  }

  FixedComplexNDArray retval ( r.dims());
  for (int i = 0; i < r.nelem(); i++)
    retval(i) = polar ( r (i), p (i) );
  return retval;
}

FixedComplexNDArray elem_pow (const FixedComplexNDArray &a, 
			      const FixedComplexNDArray &b)
{
  FixedComplexNDArray retval;
  dim_vector a_dv = a.dims ();
  int a_nel = a.numel ();
  dim_vector b_dv = b.dims ();
  int b_nel = b.numel ();

  if (a_nel == 1)
    {
      retval.resize(b_dv);
      FixedPointComplex ad = a(0);
      for (int i = 0; i < b_nel; i++)
	retval(i) = pow(ad, b(i));
    }
  else if (b_nel == 1)
    {
      retval.resize(a_dv);
      FixedPointComplex bd = b(0);
      for (int i = 0; i < a_nel; i++)
	retval(i) = pow(a(i), bd);
    }
  else if (a_dv == b_dv)
    {
      retval.resize(a_dv);
      for (int i = 0; i < a_nel; i++)
	retval(i) = pow(a(i), b(i));
    }
  else
    gripe_nonconformant ("operator .^", a_dv, b_dv);

  return retval;
}

FixedComplexNDArray elem_pow (const FixedComplexNDArray &a, const FixedPointComplex &b)
{
  return elem_pow (a, FixedComplexNDArray(dim_vector(1), b));
}

FixedComplexNDArray elem_pow (const FixedPointComplex &a, const FixedComplexNDArray &b)
{
  return elem_pow (FixedComplexNDArray(dim_vector(1), a), b);
}

FixedComplexNDArray
FixedComplexNDArray::max (octave_idx_type dim) const
{
  ArrayN<octave_idx_type> dummy_idx;
  return max (dummy_idx, dim);
}

FixedComplexNDArray
FixedComplexNDArray::max (ArrayN<octave_idx_type>& idx_arg, octave_idx_type dim) const
{
  dim_vector dv = dims ();
  dim_vector dr = dims ();

  if (dv.numel () == 0 || dim > dv.length () || dim < 0)
    return FixedComplexNDArray ();
  
  dr(dim) = 1;

  FixedComplexNDArray result (dr);
  idx_arg.resize (dr);

  octave_idx_type x_stride = 1;
  octave_idx_type x_len = dv(dim);
  for (octave_idx_type i = 0; i < dim; i++)
    x_stride *= dv(i);

  for (octave_idx_type i = 0; i < dr.numel (); i++)
    {
      octave_idx_type x_offset;
      if (x_stride == 1)
	x_offset = i * x_len;
      else
	{
	  octave_idx_type x_offset2 = 0;
	  x_offset = i;
	  while (x_offset >= x_stride)
	    {
	      x_offset -= x_stride;
	      x_offset2++;
	    }
	  x_offset += x_offset2 * x_stride * x_len;
	}

      octave_idx_type idx_j = 0;
      FixedPointComplex tmp_max = elem (x_offset);
      FixedPoint abs_max = ::abs (tmp_max);

      for (octave_idx_type j = 1; j < x_len; j++)
	{
	  FixedPointComplex tmp = elem (j * x_stride + x_offset);
	  FixedPoint abs_tmp = ::abs (tmp);

	  if (abs_tmp > abs_max)
	    {
	      idx_j = j;
	      tmp_max = tmp;
	      abs_max = abs_tmp;
	    }
	}

      result.elem (i) = tmp_max;
      idx_arg.elem (i) = idx_j;
    }

  return result;
}

FixedComplexNDArray
FixedComplexNDArray::min (octave_idx_type dim) const
{
  ArrayN<octave_idx_type> dummy_idx;
  return min (dummy_idx, dim);
}

FixedComplexNDArray
FixedComplexNDArray::min (ArrayN<octave_idx_type>& idx_arg, octave_idx_type dim) const
{
  dim_vector dv = dims ();
  dim_vector dr = dims ();

  if (dv.numel () == 0 || dim > dv.length () || dim < 0)
    return FixedComplexNDArray ();
  
  dr(dim) = 1;

  FixedComplexNDArray result (dr);
  idx_arg.resize (dr);

  octave_idx_type x_stride = 1;
  octave_idx_type x_len = dv(dim);
  for (octave_idx_type i = 0; i < dim; i++)
    x_stride *= dv(i);

  for (octave_idx_type i = 0; i < dr.numel (); i++)
    {
      octave_idx_type x_offset;
      if (x_stride == 1)
	x_offset = i * x_len;
      else
	{
	  octave_idx_type x_offset2 = 0;
	  x_offset = i;
	  while (x_offset >= x_stride)
	    {
	      x_offset -= x_stride;
	      x_offset2++;
	    }
	  x_offset += x_offset2 * x_stride * x_len;
	}

      octave_idx_type idx_j = 0;
      FixedPointComplex tmp_min = elem (x_offset);
      FixedPoint abs_min = ::abs (tmp_min);

      for (octave_idx_type j = 1; j < x_len; j++)
	{
	  FixedPointComplex tmp = elem (j * x_stride + x_offset);
	  FixedPoint abs_tmp = ::abs (tmp);

	  if (abs_tmp < abs_min)
	    {
	      idx_j = j;
	      tmp_min = tmp;
	      abs_min = abs_tmp;
	    }
	}

      result.elem (i) = tmp_min;
      idx_arg.elem (i) = idx_j;
    }

  return result;
}

FixedComplexMatrix
FixedComplexNDArray::fixed_complex_matrix_value (void) const
{
  FixedComplexMatrix retval;

  octave_idx_type nd = ndims ();

  switch (nd)
    {
    case 1:
      retval = FixedComplexMatrix (Array2<FixedPointComplex> 
				   (*this, dimensions(0), 1));
      break;

    case 2:
      retval = FixedComplexMatrix (Array2<FixedPointComplex> 
				   (*this, dimensions(0), dimensions(1)));
      break;

    default:
      (*current_liboctave_error_handler)
	("invalid conversion of FixedComplexNDArray to FixedComplexMatrix");
      break;
    }

  return retval;
}

FixedComplexNDArray 
FixedComplexNDArray ::concat (const FixedComplexNDArray& rb, 
			      const Array<octave_idx_type>& ra_idx)
{
  if (rb.numel () > 0)
    insert (rb, ra_idx);
  return *this;
}

FixedComplexNDArray 
FixedComplexNDArray::concat (const FixedNDArray& rb, 
			     const Array<octave_idx_type>& ra_idx)
{
  if (rb.numel () > 0)
    insert (FixedComplexNDArray (rb), ra_idx);
  return *this;
}

FixedComplexNDArray& 
FixedComplexNDArray::insert (const FixedComplexNDArray& a, 
			     const Array<octave_idx_type>& ra_idx)
{
  Array<FixedPointComplex>::insert (a, ra_idx);
  return *this;
}

void
FixedComplexNDArray::increment_index (Array<octave_idx_type>& ra_idx,
				 const dim_vector& dimensions,
				 octave_idx_type start_dimension)
{
  ::increment_index (ra_idx, dimensions, start_dimension);
}

octave_idx_type 
FixedComplexNDArray::compute_index (Array<octave_idx_type>& ra_idx,
			       const dim_vector& dimensions)
{
  return ::compute_index (ra_idx, dimensions);
}

// This contains no information on the array structure !!!
std::ostream&
operator << (std::ostream& os, const FixedComplexNDArray& a)
{
  octave_idx_type nel = a.nelem ();

  for (octave_idx_type i = 0; i < nel; i++)
    {
      os << " " << a.elem (i);
    }
  os << "\n";
  return os;
}

std::istream&
operator >> (std::istream& is, FixedComplexNDArray& a)
{
  octave_idx_type nel = a.nelem ();

  if (nel < 1 )
    is.clear (std::ios::badbit);
  else
    {
      FixedPointComplex tmp;
      for (octave_idx_type i = 0; i < nel; i++)
	  {
	    is >> tmp;
	    if (is)
	      a.elem (i) = tmp;
	    else
	      goto done;
	  }
    }

 done:

  return is;
}

#define EMPTY_RETURN_CHECK(T) \
  if (nel == 0)	\
    return T (dv);

FixedComplexNDArray
min (const FixedPointComplex& c, const FixedComplexNDArray& m)
{
  dim_vector dv = m.dims ();
  octave_idx_type nel = dv.numel ();
  FixedPoint cabs = ::abs(c);

  EMPTY_RETURN_CHECK (FixedComplexNDArray);

  FixedComplexNDArray result (dv);

  for (octave_idx_type i = 0; i < nel; i++)
    {
      OCTAVE_QUIT;
      result (i) = ::abs(m(i)) < cabs ? m(i) : c;
    }

  return result;
}

FixedComplexNDArray
min (const FixedComplexNDArray& m, const FixedPointComplex& c)
{
  dim_vector dv = m.dims ();
  octave_idx_type nel = dv.numel ();
  FixedPoint cabs = ::abs(c);

  EMPTY_RETURN_CHECK (FixedComplexNDArray);

  FixedComplexNDArray result (dv);

  for (octave_idx_type i = 0; i < nel; i++)
    {
      OCTAVE_QUIT;
      result (i) = ::abs(m(i)) < cabs ? m(i) : c;
    }

  return result;
}

FixedComplexNDArray
min (const FixedComplexNDArray& a, const FixedComplexNDArray& b)
{
  dim_vector dv = a.dims ();
  octave_idx_type nel = dv.numel ();

  if (dv != b.dims ())
    {
      (*current_liboctave_error_handler)
	("two-arg min expecting args of same size");
      return FixedComplexNDArray ();
    }

  EMPTY_RETURN_CHECK (FixedComplexNDArray);

  FixedComplexNDArray result (dv);

  for (octave_idx_type i = 0; i < nel; i++)
    {
      OCTAVE_QUIT;
      result (i) = ::abs(a(i)) < ::abs(b(i)) ? a(i) : b(i);
    }

  return result;
}

FixedComplexNDArray
max (const FixedPointComplex& c, const FixedComplexNDArray& m)
{
  dim_vector dv = m.dims ();
  octave_idx_type nel = dv.numel ();
  FixedPoint cabs = ::abs(c);

  EMPTY_RETURN_CHECK (FixedComplexNDArray);

  FixedComplexNDArray result (dv);

  for (octave_idx_type i = 0; i < nel; i++)
    {
      OCTAVE_QUIT;
      result (i) = ::abs(m(i)) > cabs ? m(i) : c;
    }

  return result;
}

FixedComplexNDArray
max (const FixedComplexNDArray& m, const FixedPointComplex& c)
{
  dim_vector dv = m.dims ();
  octave_idx_type nel = dv.numel ();
  FixedPoint cabs = ::abs(c);

  EMPTY_RETURN_CHECK (FixedComplexNDArray);

  FixedComplexNDArray result (dv);

  for (octave_idx_type i = 0; i < nel; i++)
    {
      OCTAVE_QUIT;
      result (i) = ::abs(m(i)) > cabs ? m(i) : c;
    }

  return result;
}

FixedComplexNDArray
max (const FixedComplexNDArray& a, const FixedComplexNDArray& b)
{
  dim_vector dv = a.dims ();
  octave_idx_type nel = dv.numel ();

  if (dv != b.dims ())
    {
      (*current_liboctave_error_handler)
	("two-arg max expecting args of same size");
      return FixedComplexNDArray ();
    }

  EMPTY_RETURN_CHECK (FixedComplexNDArray);

  FixedComplexNDArray result (dv);

  for (octave_idx_type i = 0; i < nel; i++)
    {
      OCTAVE_QUIT;
      result (i) = ::abs(a(i)) < ::abs(b(i)) ? a(i) : b(i);
    }

  return result;
}

NDS_CMP_OPS(FixedComplexNDArray, real, FixedPointComplex, real)
NDS_BOOL_OPS(FixedComplexNDArray, FixedPointComplex, FixedPointComplex())

SND_CMP_OPS(FixedPointComplex, real, FixedComplexNDArray, real)
SND_BOOL_OPS(FixedPointComplex, FixedComplexNDArray, FixedPointComplex())

NDND_CMP_OPS(FixedComplexNDArray, real, FixedComplexNDArray, real)
NDND_BOOL_OPS(FixedComplexNDArray, FixedComplexNDArray, FixedPointComplex())

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
