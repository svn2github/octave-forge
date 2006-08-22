// Fixed Point Complex ColumnVector manipulations.
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

#include <iostream>

#include <octave/config.h>
#include <octave/lo-utils.h>
#include <octave/lo-error.h>
#include <octave/error.h>
#include <octave/gripes.h>
#include <octave/ops.h>

#include "fixedCMatrix.h"
#include "fixedCRowVector.h"
#include "fixedCColVector.h"

// Fixed Point Complex Column Vector class


FixedComplexColumnVector::FixedComplexColumnVector (const MArray<int> &is, 
	const MArray<int> &ds) : MArray<FixedPointComplex> (is.length())
{
  if (length() != ds.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (const ColumnVector &is, 
	const ColumnVector &ds) : MArray<FixedPointComplex> (is.length())
{
  if (length() != ds.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (
	const ComplexColumnVector &is, const ComplexColumnVector &ds) : 
	MArray<FixedPointComplex> (is.length())
{
  if (length() != ds.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (unsigned int is, 
	unsigned int ds, const FixedComplexColumnVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (Complex is, 
	Complex ds, const FixedComplexColumnVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (const MArray<int> &is, 
	const MArray<int> &ds, const FixedComplexColumnVector& a) : 
	MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i), 
				 a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (const ColumnVector &is, 
	const ColumnVector &ds, const FixedComplexColumnVector& a) : 
	MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i), 
				 a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (
	const ComplexColumnVector &is, const ComplexColumnVector &ds, 
	const FixedComplexColumnVector& a) : 
	MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i), a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (unsigned int is, 
	unsigned int ds, const FixedColumnVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (Complex is, 
	Complex ds, const FixedColumnVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (const MArray<int> &is, 
	const MArray<int> &ds, const FixedColumnVector& a) : 
	MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i), 
				 a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (const ColumnVector &is, 
	const ColumnVector &ds, const FixedColumnVector& a) : 
	MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i), 
				 a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (
	const ComplexColumnVector &is, const ComplexColumnVector &ds, 
	const FixedColumnVector& a) : MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i), a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (unsigned int is, 
	unsigned int ds, const ComplexColumnVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (Complex is, 
	Complex ds, const ComplexColumnVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (const MArray<int> &is, 
	const MArray<int> &ds, const ComplexColumnVector& a) : 
	MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i), 
				 a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (const ColumnVector &is, 
	const ColumnVector &ds, const ComplexColumnVector& a) : 
	MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i), 
				 a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (
	const ComplexColumnVector &is, const ComplexColumnVector &ds, 
	const ComplexColumnVector& a) : MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i), a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (unsigned int is, 
	unsigned int ds, const ColumnVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (Complex is, 
	Complex ds, const ColumnVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (const MArray<int> &is, 
	const MArray<int> &ds, const ColumnVector& a) : 
	MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i), 
				 a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (const ColumnVector &is, 
	const ColumnVector &ds, const ColumnVector& a) : 
	MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i), 
				 a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (
	const ComplexColumnVector &is, const ComplexColumnVector &ds, 
	const ColumnVector& a) : MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i), a(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (unsigned int is, 
	unsigned int ds, const ComplexColumnVector& a, 
	const ComplexColumnVector& b) : MArray<FixedPointComplex> (a.length())
{
  if (length() != b.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i), b(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (Complex is, 
	Complex ds, const ComplexColumnVector& a, 
	const ComplexColumnVector& b) : MArray<FixedPointComplex> (a.length())
{
  if (length() != b.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i), b(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (const MArray<int> &is, 
	const MArray<int> &ds, const ComplexColumnVector& a, 
	const ComplexColumnVector& b) : MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length()) || 
      (length() != b.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i), 
				 a(i), b(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (const ColumnVector &is, 
	const ColumnVector &ds, const ComplexColumnVector& a, 
	const ComplexColumnVector& b) : MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length()) || 
      (length() != b.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i), 
				 a(i), b(i));
}

FixedComplexColumnVector::FixedComplexColumnVector (
	const ComplexColumnVector &is, const ComplexColumnVector &ds, 
	const ComplexColumnVector& a, const ComplexColumnVector& b) : 
	MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length()) || 
      (length() != b.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i), a(i), b(i));
}

#define GET_FIXED_PROP(METHOD) \
  ComplexColumnVector \
  FixedComplexColumnVector:: METHOD (void) const \
    { \
      int len = length(); \
      ComplexColumnVector retval(len); \
      for (int i = 0; i < len; i++) \
        retval(i) = elem(i) . METHOD (); \
      return retval; \
    } \

GET_FIXED_PROP(sign);
GET_FIXED_PROP(getdecsize);
GET_FIXED_PROP(getintsize);
GET_FIXED_PROP(getnumber);
GET_FIXED_PROP(fixedpoint);

#undef GET_FIXED_PROP

FixedComplexColumnVector 
FixedComplexColumnVector::chdecsize (const Complex n)
{
  int len = length();
  FixedComplexColumnVector retval(len);

  for (int i = 0; i < len; i++)
    retval(i) = FixedPointComplex(elem(i).getintsize(), n, elem(i));

  return retval;
}

FixedComplexColumnVector
FixedComplexColumnVector::chdecsize (const ComplexColumnVector &n)
{
  int len = length();

  if (len != n.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in chdecsize");
    return FixedComplexColumnVector();
  }

  FixedComplexColumnVector retval(len);

  for (int i = 0; i < len; i++)
    retval(i) = FixedPointComplex(elem(i).getintsize(), n(i), elem(i));

  return retval;
}

FixedComplexColumnVector 
FixedComplexColumnVector::chintsize (const Complex n)
{
  int len = length();
  FixedComplexColumnVector retval(len);

  for (int i = 0; i < len; i++)
    retval(i) = FixedPointComplex(n, elem(i).getdecsize(), elem(i));

  return retval;
}

FixedComplexColumnVector
FixedComplexColumnVector::chintsize (const ComplexColumnVector &n)
{
  int len = length();

  if (len != n.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in chdecsize");
    return FixedComplexColumnVector();
  }

  FixedComplexColumnVector retval(len);

  for (int i = 0; i < len; i++)
    retval(i) = FixedPointComplex(n(i), elem(i).getdecsize(), elem(i));

  return retval;
}

FixedComplexColumnVector 
FixedComplexColumnVector::incdecsize (const Complex n) {
  return chdecsize(n + getdecsize());
}

FixedComplexColumnVector
FixedComplexColumnVector::incdecsize (const ComplexColumnVector &n) {
  if (n.length() != length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in incdecsize");
    return FixedComplexColumnVector();
  }
  return chdecsize(n + getdecsize());
}

FixedComplexColumnVector 
FixedComplexColumnVector::incdecsize () {
  return chdecsize(1 + getdecsize());
}

FixedComplexColumnVector 
FixedComplexColumnVector::incintsize (const Complex n) {
  return chintsize(n + getintsize());
}

FixedComplexColumnVector
FixedComplexColumnVector::incintsize (const ComplexColumnVector &n) {
  if (n.length() != length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in incintsize");
    return FixedComplexColumnVector();
  }
  return chintsize(n + getintsize());
}

FixedComplexColumnVector 
FixedComplexColumnVector::incintsize () {
  return chintsize(1 + getintsize());
}

// Fixed Point Complex Column Vector class.

bool
FixedComplexColumnVector::operator == (const FixedComplexColumnVector& a) const
{
  int len = length ();
  if (len != a.length ())
    return 0;

    for (int i = 0; i < len; i++)
      if (elem(i) != a.elem(i))
        return false;
    return true;
}

bool
FixedComplexColumnVector::operator != (const FixedComplexColumnVector& a) const
{
  return !(*this == a);
}

FixedComplexColumnVector&
FixedComplexColumnVector::insert (const FixedComplexColumnVector& a, int r)
{
  int a_len = a.length ();

  if (r < 0 || r + a_len > length ())
    {
      (*current_liboctave_error_handler) ("range error for insert");
      return *this;
    }

  if (a_len > 0)
    {
      make_unique ();

      for (int i = 0; i < a_len; i++)
	xelem (r+i) = a.elem (i);
    }

  return *this;
}

FixedComplexColumnVector&
FixedComplexColumnVector::fill (FixedPointComplex val)
{
  int len = length ();

  if (len > 0)
    {
      make_unique ();

      for (int i = 0; i < len; i++)
	xelem (i) = val;
    }

  return *this;
}

FixedComplexColumnVector&
FixedComplexColumnVector::fill (FixedPointComplex val, int r1, int r2)
{
  int len = length ();

  if (r1 < 0 || r2 < 0 || r1 >= len || r2 >= len)
    {
      (*current_liboctave_error_handler) ("range error for fill");
      return *this;
    }

  if (r1 > r2) { int tmp = r1; r1 = r2; r2 = tmp; }

  if (r2 >= r1)
    {
      make_unique ();

      for (int i = r1; i <= r2; i++)
	xelem (i) = val;
    }

  return *this;
}

FixedComplexColumnVector
FixedComplexColumnVector::stack (const FixedComplexColumnVector& a) const
{
  int len = length ();
  int nr_insert = len;
  FixedComplexColumnVector retval (len + a.length ());
  retval.insert (*this, 0);
  retval.insert (a, nr_insert);
  return retval;
}

FixedComplexRowVector
FixedComplexColumnVector::transpose (void) const
{
  return FixedComplexRowVector (*this);
}

// resize is the destructive equivalent for this one

FixedComplexColumnVector
FixedComplexColumnVector::extract (int r1, int r2) const
{
  if (r1 > r2) { int tmp = r1; r1 = r2; r2 = tmp; }

  int new_r = r2 - r1 + 1;

  FixedComplexColumnVector result (new_r);

  for (int i = 0; i < new_r; i++)
    result.xelem (i) = elem (r1+i);

  return result;
}

FixedComplexColumnVector
FixedComplexColumnVector::extract_n (int r1, int n) const
{
  FixedComplexColumnVector result (n);

  for (int i = 0; i < n; i++)
    result.xelem (i) = elem (r1+i);

  return result;
}

// fixed point matrix by fixed column vector -> fixed column vector operations

FixedComplexColumnVector
operator * (const FixedComplexMatrix& m, const FixedComplexColumnVector& a)
{
  FixedComplexColumnVector retval;

  int nr = m.rows ();
  int nc = m.cols ();

  int a_len = a.length ();

  if (nc != a_len)
    gripe_nonconformant ("operator *", nr, nc, a_len, 1);
  else
    {
      retval.resize (nr, FixedPointComplex());
      if (nr != 0 && nc != 0)
	for (int i = 0; i <  nc; i++) 
	  for (int j = 0; j <  nr; j++)
	    retval.elem (j) += a.elem(i) * m.elem(j,i);  
    }

  return retval;
}

// other operations

FixedComplexColumnVector
FixedComplexColumnVector::map (fc_fc_Mapper f) const
{
  FixedComplexColumnVector b (*this);
  return b.apply (f);
}

FixedComplexColumnVector&
FixedComplexColumnVector::apply (fc_fc_Mapper f)
{
  FixedPointComplex *d = fortran_vec (); // Ensures only one reference to my privates!

  for (int i = 0; i < length (); i++)
    d[i] = f (d[i]);

  return *this;
}

FixedPointComplex
FixedComplexColumnVector::min (void) const
{
  int len = length ();
  if (len == 0)
    return FixedPointComplex();

  FixedPointComplex res = elem (0);
  double res_val = std::abs(res.fixedpoint ());

  for (int i = 1; i < len; i++)
    if (std::abs(elem (i) .fixedpoint ()) < res_val) {
      res = elem (i);
      res_val = std::abs(res.fixedpoint ());
    }

  return res;
}

FixedPointComplex
FixedComplexColumnVector::max (void) const
{
  int len = length ();
  if (len == 0)
    return FixedPointComplex();

  FixedPointComplex res = elem (0);
  double res_val = std::abs(res.fixedpoint ());

  for (int i = 1; i < len; i++)
    if (std::abs(elem (i) .fixedpoint ()) > res_val) {
      res = elem (i);
      res_val = std::abs(res.fixedpoint ());
    }

  return res;
}

#define DO_FIXED_VEC_FUNC(FUNC, MT) \
  MT FUNC (const FixedComplexColumnVector& x) \
  {  \
    MT retval (x.length()); \
    for (int i = 0; i < x.length(); i++) \
      retval(i) = FUNC ( x (i) ); \
    return retval; \
  }

DO_FIXED_VEC_FUNC(real, FixedColumnVector);
DO_FIXED_VEC_FUNC(imag, FixedColumnVector);
DO_FIXED_VEC_FUNC(conj, FixedComplexColumnVector);
DO_FIXED_VEC_FUNC(abs, FixedColumnVector);
DO_FIXED_VEC_FUNC(norm, FixedColumnVector);
DO_FIXED_VEC_FUNC(arg, FixedColumnVector);
DO_FIXED_VEC_FUNC(cos, FixedComplexColumnVector);
DO_FIXED_VEC_FUNC(cosh, FixedComplexColumnVector);
DO_FIXED_VEC_FUNC(sin, FixedComplexColumnVector);
DO_FIXED_VEC_FUNC(sinh, FixedComplexColumnVector);
DO_FIXED_VEC_FUNC(tan, FixedComplexColumnVector);
DO_FIXED_VEC_FUNC(tanh, FixedComplexColumnVector);
DO_FIXED_VEC_FUNC(sqrt, FixedComplexColumnVector);
DO_FIXED_VEC_FUNC(exp, FixedComplexColumnVector);
DO_FIXED_VEC_FUNC(log, FixedComplexColumnVector);
DO_FIXED_VEC_FUNC(log10, FixedComplexColumnVector);
DO_FIXED_VEC_FUNC(round, FixedComplexColumnVector);
DO_FIXED_VEC_FUNC(rint, FixedComplexColumnVector);
DO_FIXED_VEC_FUNC(floor, FixedComplexColumnVector);
DO_FIXED_VEC_FUNC(ceil, FixedComplexColumnVector);

FixedComplexColumnVector polar (const FixedColumnVector &r, 
				const FixedColumnVector &p)
{
  if (r.length() != p.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return FixedComplexColumnVector();
  }

  FixedComplexColumnVector retval ( r.length());
  for (int i = 0; i < r.length(); i++)
        retval(i) = polar ( r (i), p (i) );
    return retval;
}

FixedComplexColumnVector elem_pow (const FixedComplexColumnVector &a, 
				   const FixedComplexColumnVector &b)
{
  FixedComplexColumnVector retval;
  int a_len = a.length ();
  int b_len = b.length ();

  if (a_len == 1)
    {
      retval.resize(b_len);
      FixedPointComplex ad = a(0);
      for (int i = 0; i < b_len; i++)
	retval(i) = pow(ad, b(i));
    }
  else if (b_len == 1)
    {
      retval.resize(a_len);
      FixedPointComplex bd = b(0);
      for (int i = 0; i < a_len; i++)
	  retval(i) = pow(a(i), bd);
    }
  else if (a_len == b_len)
    {
      retval.resize(a_len);
      for (int i = 0; i < a_len; i++)
	  retval(i) = pow(a(i), b(i));
    }
  else
    gripe_nonconformant ("operator .^", a_len, b_len);

  return retval;
}

FixedComplexColumnVector elem_pow (const FixedComplexColumnVector &a, const FixedPointComplex &b)
{
  return elem_pow (a, FixedComplexColumnVector(1, b));
}

FixedComplexColumnVector elem_pow (const FixedPointComplex &a, const FixedComplexColumnVector &b)
{
  return elem_pow (FixedComplexColumnVector(1, a), b);
}

std::ostream&
operator << (std::ostream& os, const FixedComplexColumnVector& a)
{
  for (int i = 0; i < a.length (); i++)
    os << a.elem (i) << "\n";
  return os;
}

std::istream&
operator >> (std::istream& is, FixedComplexColumnVector& a)
{
  int len = a.length();

  if (len < 1)
    is.clear (std::ios::badbit);
  else
    {
      FixedPointComplex tmp;
      for (int i = 0; i < len; i++)
        {
          is >> tmp;
          if (is)
            a.elem (i) = tmp;
          else
            break;
        }
    }
  return is;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
