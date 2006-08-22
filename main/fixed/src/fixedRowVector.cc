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

#include "fixedMatrix.h"
#include "fixedColVector.h"
#include "fixedRowVector.h"

// Fixed Point Row Vector class

FixedRowVector::FixedRowVector (const MArray<int> &is, const MArray<int> &ds)
  : MArray<FixedPoint> (is.length())
{
  if (length() != ds.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i));
}

FixedRowVector::FixedRowVector (const RowVector &is, const RowVector &ds)
  : MArray<FixedPoint> (is.length())
{
  if (length() != ds.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i));
}

FixedRowVector::FixedRowVector (const MArray<int> &is, const MArray<int> &ds, 
				const FixedRowVector& a)
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

FixedRowVector::FixedRowVector (const RowVector &is, const RowVector &ds, 
				const FixedRowVector& a)
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

FixedRowVector::FixedRowVector (unsigned int is, unsigned int ds, 
				const FixedRowVector& a)
  : MArray<FixedPoint> (a.length())
{
  for (int i = 0; i < length (); i++)
    elem (i) = FixedPoint(is, ds, a.elem (i));
}

FixedRowVector::FixedRowVector (const MArray<int> &is, const MArray<int> &ds, 
				const RowVector& a)
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

FixedRowVector::FixedRowVector (const RowVector &is, const RowVector &ds, 
				const RowVector& a)
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

FixedRowVector::FixedRowVector (unsigned int is, unsigned int ds, 
				const RowVector& a)
  : MArray<FixedPoint> (a.length())
{
  for (int i = 0; i < length (); i++)
      elem (i) = FixedPoint(is, ds, a.elem (i));
}

FixedRowVector::FixedRowVector (const MArray<int> &is, const MArray<int> &ds, 
				const RowVector& a, const RowVector& b)
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

FixedRowVector::FixedRowVector (const RowVector &is, const RowVector &ds, 
				const RowVector& a, const RowVector& b)
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

FixedRowVector::FixedRowVector (unsigned int is, unsigned int ds, 
				const RowVector& a, const RowVector& b)
  : MArray<FixedPoint> (a.length())
{
  if (length() != b.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch");
    return;
  }

  for (int i = 0; i < length (); i++)
    elem (i) = FixedPoint(is, ds, (unsigned int)a.elem (i), 
			  (unsigned int)b.elem (i));
}

#define GET_FIXED_PROP(METHOD) \
  RowVector \
  FixedRowVector:: METHOD (void) const \
    { \
      int len = length(); \
      RowVector retval(len); \
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

FixedRowVector 
FixedRowVector::chdecsize (const double n)
{
  int len = length();
  FixedRowVector retval(len);

  for (int i = 0; i < len; i++)
    retval(i) = FixedPoint(elem(i).getintsize(), (int)n, elem(i));

  return retval;
}

FixedRowVector 
FixedRowVector::chdecsize (const RowVector &n)
{
  int len = length();

  if (len != n.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in chdecsize");
    return FixedRowVector();
  }

  FixedRowVector retval(len);

  for (int i = 0; i < len; i++)
      retval(i) = FixedPoint(elem(i).getintsize(), (int)n(i), elem(i));

  return retval;
}

FixedRowVector 
FixedRowVector::chintsize (const double n)
{
  int len = length();
  FixedRowVector retval(len);

  for (int i = 0; i < len; i++)
    retval(i) = FixedPoint((int)n, elem(i).getdecsize(), elem(i));

  return retval;
}

FixedRowVector 
FixedRowVector::chintsize (const RowVector &n)
{
  int len = length();

  if (len != n.length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in chdecsize");
    return FixedRowVector();
  }

  FixedRowVector retval(len);

  for (int i = 0; i < len; i++)
      retval(i) = FixedPoint((int)n(i), elem(i).getdecsize(), elem(i));

  return retval;
}

FixedRowVector 
FixedRowVector::incdecsize (const double n) {
  return chdecsize(n + getdecsize());
}

FixedRowVector
FixedRowVector::incdecsize (const RowVector &n) {
  if (n.length() != length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in incdecsize");
    return FixedRowVector();
  }
  return chdecsize(n + getdecsize());
}

FixedRowVector 
FixedRowVector::incdecsize () {
  return chdecsize(1 + getdecsize());
}

FixedRowVector 
FixedRowVector::incintsize (const double n) {
  return chintsize(n + getintsize());
}

FixedRowVector
FixedRowVector::incintsize (const RowVector &n) {
  if (n.length() != length()) {
    (*current_liboctave_error_handler) ("vector size mismatch in incintsize");
    return FixedRowVector();
  }
  return chintsize(n + getintsize());
}

FixedRowVector 
FixedRowVector::incintsize () {
  return chintsize(1 + getintsize());
}

// Fixed Point Row Vector class.

bool
FixedRowVector::operator == (const FixedRowVector& a) const
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
FixedRowVector::operator != (const FixedRowVector& a) const
{
  return !(*this == a);
}

FixedRowVector&
FixedRowVector::insert (const FixedRowVector& a, int c)
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

FixedRowVector&
FixedRowVector::fill (FixedPoint val)
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

FixedRowVector&
FixedRowVector::fill (FixedPoint val, int c1, int c2)
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

FixedRowVector
FixedRowVector::append (const FixedRowVector& a) const
{
  int len = length ();
  int nc_insert = len;
  FixedRowVector retval (len + a.length ());
  retval.insert (*this, 0);
  retval.insert (a, nc_insert);
  return retval;
}

FixedColumnVector
FixedRowVector::transpose (void) const
{
  return FixedColumnVector (*this);
}

FixedRowVector
FixedRowVector::extract (int c1, int c2) const
{
  if (c1 > c2) { int tmp = c1; c1 = c2; c2 = tmp; }

  int new_c = c2 - c1 + 1;

  FixedRowVector result (new_c);

  for (int i = 0; i < new_c; i++)
    result.xelem (i) = elem (c1+i);

  return result;
}

FixedRowVector
FixedRowVector::extract_n (int r1, int n) const
{
  FixedRowVector result (n);

  for (int i = 0; i < n; i++)
    result.xelem (i) = elem (r1+i);

  return result;
}

#define DO_FIXED_VEC_FUNC(FUNC, MT) \
  MT FUNC (const FixedRowVector& x) \
  {  \
    MT retval (x.length()); \
    for (int i = 0; i < x.length(); i++) \
      retval(i) = FUNC ( x (i) ); \
    return retval; \
  }

DO_FIXED_VEC_FUNC(real, FixedRowVector);
DO_FIXED_VEC_FUNC(imag, FixedRowVector);
DO_FIXED_VEC_FUNC(conj, FixedRowVector);
DO_FIXED_VEC_FUNC(abs, FixedRowVector);
DO_FIXED_VEC_FUNC(cos, FixedRowVector);
DO_FIXED_VEC_FUNC(cosh, FixedRowVector);
DO_FIXED_VEC_FUNC(sin, FixedRowVector);
DO_FIXED_VEC_FUNC(sinh, FixedRowVector);
DO_FIXED_VEC_FUNC(tan, FixedRowVector);
DO_FIXED_VEC_FUNC(tanh, FixedRowVector);
DO_FIXED_VEC_FUNC(sqrt, FixedRowVector);
DO_FIXED_VEC_FUNC(exp, FixedRowVector);
DO_FIXED_VEC_FUNC(log, FixedRowVector);
DO_FIXED_VEC_FUNC(log10, FixedRowVector);
DO_FIXED_VEC_FUNC(round, FixedRowVector);
DO_FIXED_VEC_FUNC(rint, FixedRowVector);
DO_FIXED_VEC_FUNC(floor, FixedRowVector);
DO_FIXED_VEC_FUNC(ceil, FixedRowVector);

FixedRowVector elem_pow (const FixedRowVector &a, 
				   const FixedRowVector &b)
{
  FixedRowVector retval;
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

FixedRowVector elem_pow (const FixedRowVector &a, const FixedPoint &b)
{
  return elem_pow (a, FixedRowVector(1, b));
}

FixedRowVector elem_pow (const FixedPoint &a, const FixedRowVector &b)
{
  return elem_pow (FixedRowVector(1, a), b);
}

// row vector by matrix -> row vector

FixedRowVector
operator * (const FixedRowVector& v, const FixedMatrix& a)
{
  FixedRowVector retval;

  int len = v.length ();

  int a_nr = a.rows ();
  int a_nc = a.cols ();

  if (a_nr != len)
    gripe_nonconformant ("operator *", 1, len, a_nr, a_nc);
  else
    {
      int a_nr = a.rows ();
      int a_nc = a.cols ();

      retval.resize (a_nc, FixedPoint());
      if (len != 0)
	for (int i = 0; i <  a_nc; i++) 
	  for (int j = 0; j <  a_nr; j++)
	    retval.elem (i) += v.elem(j) * a.elem(j,i);  
    }

  return retval;
}

// other operations
FixedRowVector
FixedRowVector::map (f_f_Mapper f) const
{
  FixedRowVector b (*this);
  return b.apply (f);
}

FixedRowVector&
FixedRowVector::apply (f_f_Mapper f)
{
  FixedPoint *d = fortran_vec (); // Ensures only one reference to my privates!

  for (int i = 0; i < length (); i++)
    d[i] = f (d[i]);

  return *this;
}

FixedPoint
FixedRowVector::min (void) const
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
FixedRowVector::max (void) const
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

std::ostream&
operator << (std::ostream& os, const FixedRowVector& a)
{
  for (int i = 0; i < a.length (); i++)
    os << " " << a.elem (i);
  return os;
}

std::istream&
operator >> (std::istream& is, FixedRowVector& a)
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

// row vector by column vector -> scalar

FixedPoint
operator * (const FixedRowVector& v, const FixedColumnVector& a)
{
  FixedPoint retval;

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
