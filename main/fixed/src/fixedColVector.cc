// Fixed Point ColumnVector manipulations.
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

#include "fixedMatrix.h"
#include "fixedRowVector.h"
#include "fixedColVector.h"

// Fixed Point Column Vector class

FixedColumnVector::FixedColumnVector (const MArray<int> &is, 
				      const MArray<int> &ds)
  : MArray<FixedPoint> (is.length())
{
  if (length() != ds.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i));
}

FixedColumnVector::FixedColumnVector (const ColumnVector &is, 
				      const ColumnVector &ds)
  : MArray<FixedPoint> (is.length())
{
  if (length() != ds.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i));
}

FixedColumnVector::FixedColumnVector (const MArray<int> &is, 
		const MArray<int> &ds, const FixedColumnVector& a)
  : MArray<FixedPoint> (a.length())
{
  if ((length() != is.length()) || (length() != ds.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i), 
			  a.elem (i));
}

FixedColumnVector::FixedColumnVector (const ColumnVector &is, 
		const ColumnVector &ds, const FixedColumnVector& a)
  : MArray<FixedPoint> (a.length())
{
  if ((length() != is.length()) || (length() != ds.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i), 
			  a.elem (i));
}

FixedColumnVector::FixedColumnVector (unsigned int is, unsigned int ds, 
				const FixedColumnVector& a)
  : MArray<FixedPoint> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPoint(is, ds, a.elem (i));
}

FixedColumnVector::FixedColumnVector (const MArray<int> &is, 
		const MArray<int> &ds, const ColumnVector& a)
  : MArray<FixedPoint> (a.length())
{
  if ((length() != is.length()) || (length() != ds.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i), 
			  a.elem (i));
}

FixedColumnVector::FixedColumnVector (const ColumnVector &is, 
		const ColumnVector &ds, const ColumnVector& a)
  : MArray<FixedPoint> (a.length())
{
  if ((length() != is.length()) || (length() != ds.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i), 
			  a.elem (i));
}

FixedColumnVector::FixedColumnVector (unsigned int is, unsigned int ds, 
				const ColumnVector& a)
  : MArray<FixedPoint> (a.length())
{
  for (int i = 0; i < length (); i++)
      elem (i) = FixedPoint(is, ds, a.elem (i));
}

FixedColumnVector::FixedColumnVector (const MArray<int> &is, 
			const MArray<int> &ds, const ColumnVector& a, 
			const ColumnVector& b)
  : MArray<FixedPoint> (a.length())
{
  if ((length() != b.length())  || (length() != is.length()) ||
      (length() != ds.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i), 
			  (unsigned int)a.elem (i), 
			  (unsigned int)b.elem (i));
}

FixedColumnVector::FixedColumnVector (const ColumnVector &is, 
		const ColumnVector &ds, const ColumnVector& a, 
		const ColumnVector& b)
  : MArray<FixedPoint> (a.length())
{
  if ((length() != b.length())  || (length() != is.length()) ||
      (length() != ds.length())) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i), 
			  (unsigned int)a.elem (i), 
			  (unsigned int)b.elem (i));
}

FixedColumnVector::FixedColumnVector (unsigned int is, unsigned int ds, 
				const ColumnVector& a, const ColumnVector& b)
  : MArray<FixedPoint> (a.length())
{
  if (length() != b.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPoint(is, ds, (int)a.elem (i), (int)b.elem (i));
}

#define GET_FIXED_PROP(METHOD) \
  ColumnVector \
  FixedColumnVector:: METHOD (void) const \
    { \
      int len = length(); \
      ColumnVector retval(len); \
      for (int i = 0; i < len; i++) \
        retval(i) = (double) elem(i) . METHOD (); \
      return retval; \
    } \

GET_FIXED_PROP(sign);
GET_FIXED_PROP(signbit);
GET_FIXED_PROP(getdecsize);
GET_FIXED_PROP(getintsize);
GET_FIXED_PROP(getnumber);
GET_FIXED_PROP(fixedpoint);

#undef GET_FIXED_PROP

FixedColumnVector 
FixedColumnVector::chdecsize (const double n)
{
  int len = length();
  FixedColumnVector retval(len);

  for (int i = 0; i < len; i++)
    retval(i) = FixedPoint(elem(i).getintsize(), (int)n, elem(i));

  return retval;
}

FixedColumnVector 
FixedColumnVector::chdecsize (const ColumnVector &n)
{
  int len = length();

  if (len != n.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in chdecsize");
    return FixedColumnVector();
  }

  FixedColumnVector retval(len);

  for (int i = 0; i < len; i++)
      retval(i) = FixedPoint(elem(i).getintsize(), (int)n(i), elem(i));

  return retval;
}

FixedColumnVector 
FixedColumnVector::chintsize (const double n)
{
  int len = length();
  FixedColumnVector retval(len);

  for (int i = 0; i < len; i++)
    retval(i) = FixedPoint((int)n, elem(i).getdecsize(), elem(i));

  return retval;
}

FixedColumnVector 
FixedColumnVector::chintsize (const ColumnVector &n)
{
  int len = length();

  if (len != n.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in chdecsize");
    return FixedColumnVector();
  }

  FixedColumnVector retval(len);

  for (int i = 0; i < len; i++)
      retval(i) = FixedPoint((int)n(i), elem(i).getdecsize(), elem(i));

  return retval;
}

FixedColumnVector 
FixedColumnVector::incdecsize (const double n) {
  return chdecsize(n + getdecsize());
}

FixedColumnVector
FixedColumnVector::incdecsize (const ColumnVector &n) {
  if (n.length() != length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in incdecsize");
    return FixedColumnVector();
  }
  return chdecsize(n + getdecsize());
}

FixedColumnVector 
FixedColumnVector::incdecsize () {
  return chdecsize(1 + getdecsize());
}

FixedColumnVector 
FixedColumnVector::incintsize (const double n) {
  return chintsize(n + getintsize());
}

FixedColumnVector
FixedColumnVector::incintsize (const ColumnVector &n) {
  if (n.length() != length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in incintsize");
    return FixedColumnVector();
  }
  return chintsize(n + getintsize());
}

FixedColumnVector 
FixedColumnVector::incintsize () {
  return chintsize(1 + getintsize());
}

// Fixed Point Column Vector class.

bool
FixedColumnVector::operator == (const FixedColumnVector& a) const
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
FixedColumnVector::operator != (const FixedColumnVector& a) const
{
  return !(*this == a);
}

FixedColumnVector&
FixedColumnVector::insert (const FixedColumnVector& a, int r)
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

FixedColumnVector&
FixedColumnVector::fill (FixedPoint val)
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

FixedColumnVector&
FixedColumnVector::fill (FixedPoint val, int r1, int r2)
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

FixedColumnVector
FixedColumnVector::stack (const FixedColumnVector& a) const
{
  int len = length ();
  int nr_insert = len;
  FixedColumnVector retval (len + a.length ());
  retval.insert (*this, 0);
  retval.insert (a, nr_insert);
  return retval;
}

FixedRowVector
FixedColumnVector::transpose (void) const
{
  return FixedRowVector (*this);
}

// resize is the destructive equivalent for this one

FixedColumnVector
FixedColumnVector::extract (int r1, int r2) const
{
  if (r1 > r2) { int tmp = r1; r1 = r2; r2 = tmp; }

  int new_r = r2 - r1 + 1;

  FixedColumnVector result (new_r);

  for (int i = 0; i < new_r; i++)
    result.xelem (i) = elem (r1+i);

  return result;
}

FixedColumnVector
FixedColumnVector::extract_n (int r1, int n) const
{
  FixedColumnVector result (n);

  for (int i = 0; i < n; i++)
    result.xelem (i) = elem (r1+i);

  return result;
}

// fixed point matrix by fixed column vector -> fixed column vector operations

FixedColumnVector
operator * (const FixedMatrix& m, const FixedColumnVector& a)
{
  FixedColumnVector retval;

  int nr = m.rows ();
  int nc = m.cols ();

  int a_len = a.length ();

  if (nc != a_len)
    gripe_nonconformant ("operator *", nr, nc, a_len, 1);
  else
    {
      retval.resize (nr, FixedPoint());
      if (nr != 0 && nc != 0)
	for (int i = 0; i <  nc; i++) 
	  for (int j = 0; j <  nr; j++)
	    retval.elem (j) += a.elem(i) * m.elem(j,i);  
    }

  return retval;
}

// other operations

FixedColumnVector
FixedColumnVector::map (f_f_Mapper f) const
{
  FixedColumnVector b (*this);
  return b.apply (f);
}

FixedColumnVector&
FixedColumnVector::apply (f_f_Mapper f)
{
  FixedPoint *d = fortran_vec (); // Ensures only one reference to my privates!

  for (int i = 0; i < length (); i++)
    d[i] = f (d[i]);

  return *this;
}

FixedPoint
FixedColumnVector::min (void) const
{
  int len = length ();
  if (len == 0)
    return FixedPoint();

  FixedPoint res = elem (0);
  double res_val = res.fixedpoint ();

  for (int i = 1; i < len; i++)
    if (elem (i) .fixedpoint () < res_val) {
      res = elem (i);
      res_val = res.fixedpoint ();
    }

  return res;
}

FixedPoint
FixedColumnVector::max (void) const
{
  int len = length ();
  if (len == 0)
    return FixedPoint();

  FixedPoint res = elem (0);
  double res_val = res.fixedpoint ();

  for (int i = 1; i < len; i++)
    if (elem (i) .fixedpoint () > res_val) {
      res = elem (i);
      res_val = res.fixedpoint ();
    }

  return res;
}

#define DO_FIXED_VEC_FUNC(FUNC, MT) \
  MT FUNC (const FixedColumnVector& x) \
  {  \
    MT retval (x.length()); \
    for (int i = 0; i < x.length(); i++) \
      retval(i) = FUNC ( x (i) ); \
    return retval; \
  }

DO_FIXED_VEC_FUNC(real, FixedColumnVector);
DO_FIXED_VEC_FUNC(imag, FixedColumnVector);
DO_FIXED_VEC_FUNC(conj, FixedColumnVector);
DO_FIXED_VEC_FUNC(abs, FixedColumnVector);
DO_FIXED_VEC_FUNC(cos, FixedColumnVector);
DO_FIXED_VEC_FUNC(cosh, FixedColumnVector);
DO_FIXED_VEC_FUNC(sin, FixedColumnVector);
DO_FIXED_VEC_FUNC(sinh, FixedColumnVector);
DO_FIXED_VEC_FUNC(tan, FixedColumnVector);
DO_FIXED_VEC_FUNC(tanh, FixedColumnVector);
DO_FIXED_VEC_FUNC(sqrt, FixedColumnVector);
DO_FIXED_VEC_FUNC(exp, FixedColumnVector);
DO_FIXED_VEC_FUNC(log, FixedColumnVector);
DO_FIXED_VEC_FUNC(log10, FixedColumnVector);
DO_FIXED_VEC_FUNC(round, FixedColumnVector);
DO_FIXED_VEC_FUNC(rint, FixedColumnVector);
DO_FIXED_VEC_FUNC(floor, FixedColumnVector);
DO_FIXED_VEC_FUNC(ceil, FixedColumnVector);

FixedColumnVector elem_pow (const FixedColumnVector &a, 
				   const FixedColumnVector &b)
{
  FixedColumnVector retval;
  int a_len = a.length ();
  int b_len = b.length ();

  if (a_len == 1)
    {
      retval.resize(b_len);
      FixedPoint ad = a(0);
      for (int i = 0; i < b_len; i++)
	retval(i) = pow(ad, b(i));
    }
  else if (b_len == 1)
    {
      retval.resize(a_len);
      FixedPoint bd = b(0);
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

FixedColumnVector elem_pow (const FixedColumnVector &a, const FixedPoint &b)
{
  return elem_pow (a, FixedColumnVector(1, b));
}

FixedColumnVector elem_pow (const FixedPoint &a, const FixedColumnVector &b)
{
  return elem_pow (FixedColumnVector(1, a), b);
}

std::ostream&
operator << (std::ostream& os, const FixedColumnVector& a)
{
  for (int i = 0; i < a.length (); i++)
    os << a.elem (i) << "\n";
  return os;
}

std::istream&
operator >> (std::istream& is, FixedColumnVector& a)
{
  int len = a.length();

  if (len < 1)
    is.clear (std::ios::badbit);
  else
    {
      FixedPoint tmp;
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
