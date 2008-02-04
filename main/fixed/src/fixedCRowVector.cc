// Fixed Point RowVector manipulations.
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

#include <iostream>

#include <octave/config.h>
#include <octave/lo-utils.h>
#include <octave/lo-error.h>
#include <octave/error.h>
#include <octave/gripes.h>
#include <octave/ops.h>

#include "fixedCMatrix.h"
#include "fixedCColVector.h"
#include "fixedCRowVector.h"

// Fixed Point Complex Row Vector class

FixedComplexRowVector::FixedComplexRowVector (const MArray<int> &is, 
	const MArray<int> &ds) : MArray<FixedPointComplex> (is.length())
{
  if (length() != ds.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i));
}

FixedComplexRowVector::FixedComplexRowVector (const RowVector &is, 
	const RowVector &ds) : MArray<FixedPointComplex> (is.length())
{
  if (length() != ds.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex((unsigned int)is(i), (unsigned int)ds(i));
}

FixedComplexRowVector::FixedComplexRowVector (const ComplexRowVector &is, 
	const ComplexRowVector &ds) : MArray<FixedPointComplex> (is.length())
{
  if (length() != ds.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i));
}

FixedComplexRowVector::FixedComplexRowVector (unsigned int is, 
	unsigned int ds, const FixedComplexRowVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i));
}

FixedComplexRowVector::FixedComplexRowVector (Complex is, 
	Complex ds, const FixedComplexRowVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i));
}

FixedComplexRowVector::FixedComplexRowVector (const MArray<int> &is, 
	const MArray<int> &ds, const FixedComplexRowVector& a) : 
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

FixedComplexRowVector::FixedComplexRowVector (const RowVector &is, 
	const RowVector &ds, const FixedComplexRowVector& a) : 
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

FixedComplexRowVector::FixedComplexRowVector (const ComplexRowVector &is, 
	const ComplexRowVector &ds, const FixedComplexRowVector& a) : 
	MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i), a(i));
}

FixedComplexRowVector::FixedComplexRowVector (unsigned int is, 
	unsigned int ds, const FixedRowVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i));
}

FixedComplexRowVector::FixedComplexRowVector (Complex is, 
	Complex ds, const FixedRowVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, FixedPointComplex(a(i)));
}

FixedComplexRowVector::FixedComplexRowVector (const MArray<int> &is, 
	const MArray<int> &ds, const FixedRowVector& a) : 
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

FixedComplexRowVector::FixedComplexRowVector (const RowVector &is, 
	const RowVector &ds, const FixedRowVector& a) : 
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

FixedComplexRowVector::FixedComplexRowVector (const ComplexRowVector &is, 
	const ComplexRowVector &ds, const FixedRowVector& a) : 
	MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i), FixedPointComplex(a(i)));
}

FixedComplexRowVector::FixedComplexRowVector (unsigned int is, 
	unsigned int ds, const ComplexRowVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i));
}

FixedComplexRowVector::FixedComplexRowVector (Complex is, 
	Complex ds, const ComplexRowVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i));
}

FixedComplexRowVector::FixedComplexRowVector (const MArray<int> &is, 
	const MArray<int> &ds, const ComplexRowVector& a) : 
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

FixedComplexRowVector::FixedComplexRowVector (const RowVector &is, 
	const RowVector &ds, const ComplexRowVector& a) : 
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

FixedComplexRowVector::FixedComplexRowVector (const ComplexRowVector &is, 
	const ComplexRowVector &ds, const ComplexRowVector& a) : 
	MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i), a(i));
}

FixedComplexRowVector::FixedComplexRowVector (unsigned int is, 
	unsigned int ds, const RowVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i));
}

FixedComplexRowVector::FixedComplexRowVector (Complex is, 
	Complex ds, const RowVector& a) : 
	MArray<FixedPointComplex> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i));
}

FixedComplexRowVector::FixedComplexRowVector (const MArray<int> &is, 
	const MArray<int> &ds, const RowVector& a) : 
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

FixedComplexRowVector::FixedComplexRowVector (const RowVector &is, 
	const RowVector &ds, const RowVector& a) : 
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

FixedComplexRowVector::FixedComplexRowVector (const ComplexRowVector &is, 
	const ComplexRowVector &ds, const RowVector& a) : 
	MArray<FixedPointComplex> (is.length())
{
  if ((length() != ds.length()) || (length() != a.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is(i), ds(i), a(i));
}

FixedComplexRowVector::FixedComplexRowVector (unsigned int is, 
	unsigned int ds, const ComplexRowVector& a, 
	const ComplexRowVector& b) : MArray<FixedPointComplex> (a.length())
{
  if (length() != b.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i), b(i));
}

FixedComplexRowVector::FixedComplexRowVector (Complex is, 
	Complex ds, const ComplexRowVector& a, const ComplexRowVector& b) : 
	MArray<FixedPointComplex> (a.length())
{
  if (length() != b.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPointComplex(is, ds, a(i), b(i));
}

FixedComplexRowVector::FixedComplexRowVector (const MArray<int> &is, 
	const MArray<int> &ds, const ComplexRowVector& a, 
	const ComplexRowVector& b) : MArray<FixedPointComplex> (is.length())
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

FixedComplexRowVector::FixedComplexRowVector (const RowVector &is, 
	const RowVector &ds, const ComplexRowVector& a, 
	const ComplexRowVector& b) : MArray<FixedPointComplex> (is.length())
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

FixedComplexRowVector::FixedComplexRowVector (const ComplexRowVector &is, 
	const ComplexRowVector &ds, const ComplexRowVector& a,
	const ComplexRowVector& b) : MArray<FixedPointComplex> (is.length())
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
  ComplexRowVector \
  FixedComplexRowVector:: METHOD (void) const \
    { \
      int len = length(); \
      ComplexRowVector retval(len); \
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

FixedComplexRowVector 
FixedComplexRowVector::chdecsize (const Complex n)
{
  int len = length();
  FixedComplexRowVector retval(len);

  for (int i = 0; i < len; i++)
    retval(i) = FixedPointComplex(elem(i).getintsize(), n, elem(i));

  return retval;
}

FixedComplexRowVector
FixedComplexRowVector::chdecsize (const ComplexRowVector &n)
{
  int len = length();

  if (len != n.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in chdecsize");
    return FixedComplexRowVector();
  }

  FixedComplexRowVector retval(len);

  for (int i = 0; i < len; i++)
    retval(i) = FixedPointComplex(elem(i).getintsize(), n(i), elem(i));

  return retval;
}

FixedComplexRowVector 
FixedComplexRowVector::chintsize (const Complex n)
{
  int len = length();
  FixedComplexRowVector retval(len);

  for (int i = 0; i < len; i++)
    retval(i) = FixedPointComplex(n, elem(i).getdecsize(), elem(i));

  return retval;
}

FixedComplexRowVector
FixedComplexRowVector::chintsize (const ComplexRowVector &n)
{
  int len = length();

  if (len != n.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in chdecsize");
    return FixedComplexRowVector();
  }

  FixedComplexRowVector retval(len);

  for (int i = 0; i < len; i++)
    retval(i) = FixedPointComplex(n(i), elem(i).getdecsize(), elem(i));

  return retval;
}

FixedComplexRowVector 
FixedComplexRowVector::incdecsize (const Complex n) {
  return chdecsize(n + getdecsize());
}

FixedComplexRowVector
FixedComplexRowVector::incdecsize (const ComplexRowVector &n) {
  if (n.length() != length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in incdecsize");
    return FixedComplexRowVector();
  }
  return chdecsize(n + getdecsize());
}

FixedComplexRowVector 
FixedComplexRowVector::incdecsize () {
  return chdecsize(1 + getdecsize());
}

FixedComplexRowVector 
FixedComplexRowVector::incintsize (const Complex n) {
  return chintsize(n + getintsize());
}

FixedComplexRowVector
FixedComplexRowVector::incintsize (const ComplexRowVector &n) {
  if (n.length() != length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in incintsize");
    return FixedComplexRowVector();
  }
  return chintsize(n + getintsize());
}

FixedComplexRowVector 
FixedComplexRowVector::incintsize () {
  return chintsize(1 + getintsize());
}

// Fixed Point Complex Row Vector class.

bool
FixedComplexRowVector::operator == (const FixedComplexRowVector& a) const
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
FixedComplexRowVector::operator != (const FixedComplexRowVector& a) const
{
  return !(*this == a);
}

FixedComplexRowVector&
FixedComplexRowVector::insert (const FixedComplexRowVector& a, int c)
{
  int a_len = a.length ();

  if (c < 0 || c + a_len > length ())
    {
      (*current_liboctave_error_handler) ("range error for insert");
      return *this;
    }

  if (a_len > 0)
    {
      make_unique ();

      for (int i = 0; i < a_len; i++)
	xelem (c+i) = a.elem (i);
    }

  return *this;
}

FixedComplexRowVector&
FixedComplexRowVector::fill (FixedPointComplex val)
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

FixedComplexRowVector&
FixedComplexRowVector::fill (FixedPointComplex val, int c1, int c2)
{
  int len = length ();

  if (c1 < 0 || c2 < 0 || c1 >= len || c2 >= len)
    {
      (*current_liboctave_error_handler) ("range error for fill");
      return *this;
    }

  if (c1 > c2) { int tmp = c1; c1 = c2; c2 = tmp; }

  if (c2 >= c1)
    {
      make_unique ();

      for (int i = c1; i <= c2; i++)
	xelem (i) = val;
    }

  return *this;
}

FixedComplexRowVector
FixedComplexRowVector::append (const FixedComplexRowVector& a) const
{
  int len = length ();
  int nc_insert = len;
  FixedComplexRowVector retval (len + a.length ());
  retval.insert (*this, 0);
  retval.insert (a, nc_insert);
  return retval;
}

FixedComplexColumnVector
FixedComplexRowVector::transpose (void) const
{
  return FixedComplexColumnVector (*this);
}

FixedComplexRowVector
FixedComplexRowVector::extract (int c1, int c2) const
{
  if (c1 > c2) { int tmp = c1; c1 = c2; c2 = tmp; }

  int new_c = c2 - c1 + 1;

  FixedComplexRowVector result (new_c);

  for (int i = 0; i < new_c; i++)
    result.xelem (i) = elem (c1+i);

  return result;
}

FixedComplexRowVector
FixedComplexRowVector::extract_n (int r1, int n) const
{
  FixedComplexRowVector result (n);

  for (int i = 0; i < n; i++)
    result.xelem (i) = elem (r1+i);

  return result;
}

// row vector by matrix -> row vector

FixedComplexRowVector
operator * (const FixedComplexRowVector& v, const FixedComplexMatrix& a)
{
  FixedComplexRowVector retval;

  int len = v.length ();

  int a_nr = a.rows ();
  int a_nc = a.cols ();

  if (a_nr != len)
    gripe_nonconformant ("operator *", 1, len, a_nr, a_nc);
  else
    {
      int a_nr = a.rows ();
      int a_nc = a.cols ();

      retval.resize (a_nc, FixedPointComplex());
      if (len != 0)
	for (int i = 0; i <  a_nc; i++) 
	  for (int j = 0; j <  a_nr; j++)
	    retval.elem (i) += v.elem(j) * a.elem(j,i);  
    }

  return retval;
}

// other operations
FixedComplexRowVector
FixedComplexRowVector::map (fc_fc_Mapper f) const
{
  FixedComplexRowVector b (*this);
  return b.apply (f);
}

FixedComplexRowVector&
FixedComplexRowVector::apply (fc_fc_Mapper f)
{
  FixedPointComplex *d = fortran_vec (); // Ensures only one reference to my privates!

  for (int i = 0; i < length (); i++)
    d[i] = f (d[i]);

  return *this;
}

FixedPointComplex
FixedComplexRowVector::min (void) const
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
FixedComplexRowVector::max (void) const
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
  MT FUNC (const FixedComplexRowVector& x) \
  {  \
    MT retval (x.length()); \
    for (int i = 0; i < x.length(); i++) \
      retval(i) = FUNC ( x (i) ); \
    return retval; \
  }

DO_FIXED_VEC_FUNC(real, FixedRowVector);
DO_FIXED_VEC_FUNC(imag, FixedRowVector);
DO_FIXED_VEC_FUNC(conj, FixedComplexRowVector);
DO_FIXED_VEC_FUNC(abs, FixedRowVector);
DO_FIXED_VEC_FUNC(norm, FixedRowVector);
DO_FIXED_VEC_FUNC(arg, FixedRowVector);
DO_FIXED_VEC_FUNC(cos, FixedComplexRowVector);
DO_FIXED_VEC_FUNC(cosh, FixedComplexRowVector);
DO_FIXED_VEC_FUNC(sin, FixedComplexRowVector);
DO_FIXED_VEC_FUNC(sinh, FixedComplexRowVector);
DO_FIXED_VEC_FUNC(tan, FixedComplexRowVector);
DO_FIXED_VEC_FUNC(tanh, FixedComplexRowVector);
DO_FIXED_VEC_FUNC(sqrt, FixedComplexRowVector);
DO_FIXED_VEC_FUNC(exp, FixedComplexRowVector);
DO_FIXED_VEC_FUNC(log, FixedComplexRowVector);
DO_FIXED_VEC_FUNC(log10, FixedComplexRowVector);
DO_FIXED_VEC_FUNC(round, FixedComplexRowVector);
DO_FIXED_VEC_FUNC(rint, FixedComplexRowVector);
DO_FIXED_VEC_FUNC(floor, FixedComplexRowVector);
DO_FIXED_VEC_FUNC(ceil, FixedComplexRowVector);

FixedComplexRowVector polar (const FixedRowVector &r, 
				const FixedRowVector &p)
{
  if (r.length() != p.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return FixedComplexRowVector();
  }

  FixedComplexRowVector retval ( r.length());
  for (int i = 0; i < r.length(); i++)
        retval(i) = polar ( r (i), p (i) );
    return retval;
}

FixedComplexRowVector elem_pow (const FixedComplexRowVector &a, 
				   const FixedComplexRowVector &b)
{
  FixedComplexRowVector retval;
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

FixedComplexRowVector elem_pow (const FixedComplexRowVector &a, const FixedPointComplex &b)
{
  return elem_pow (a, FixedComplexRowVector(1, b));
}

FixedComplexRowVector elem_pow (const FixedPointComplex &a, const FixedComplexRowVector &b)
{
  return elem_pow (FixedComplexRowVector(1, a), b);
}

std::ostream&
operator << (std::ostream& os, const FixedComplexRowVector& a)
{
  for (int i = 0; i < a.length (); i++)
    os << " " << a.elem (i);
  return os;
}

std::istream&
operator >> (std::istream& is, FixedComplexRowVector& a)
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

// row vector by column vector -> scalar

FixedPointComplex
operator * (const FixedComplexRowVector& v, const FixedComplexColumnVector& a)
{
  FixedPointComplex retval;

  int len = v.length ();

  int a_len = a.length ();

  if (len != a_len)
    gripe_nonconformant ("operator *", len, a_len);
  else if (len != 0)
    for (int i = 0; i < len; i++) 
      retval += v.elem(i) * a.elem(i);

  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
