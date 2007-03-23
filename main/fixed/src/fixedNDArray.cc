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
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02110-1301, USA.

In addition to the terms of the GPL, you are permitted to link
this program with any Open Source program, as defined by the
Open Source Initiative (www.opensource.org)

*/

#include <iostream>

#include <octave/config.h>
#include <octave/lo-error.h>
#include <octave/lo-utils.h>
#include <octave/lo-error.h>
#include <octave/error.h>
#include <octave/dMatrix.h>
#include <octave/dNDArray.h>
#include <octave/CNDArray.h>
#include <octave/gripes.h>
#include <octave/ops.h>
#include <octave/quit.h>

#include "fixedMatrix.h"
#include "fixedNDArray.h"
#include "fixedCNDArray.h"

// Fixed Point NDArray class.

FixedNDArray::FixedNDArray (const MArrayN<int> &is, const MArrayN<int> &ds)
  : MArrayN<FixedPoint> (is.dims())
{
  if (dims () != ds.dims ()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i));
}


FixedNDArray::FixedNDArray (const NDArray &is, const NDArray &ds)
  : MArrayN<FixedPoint> (is.dims())
{
  if (dims () != ds.dims ()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i));
}

FixedNDArray::FixedNDArray (const MArrayN<int> &is, const MArrayN<int> &ds, 
			  const FixedNDArray& a)
  : MArrayN<FixedPoint> (a.dims())
{
  if ((dims () != is.dims ()) || (dims () != ds.dims ())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i), 
			       a.elem (i));
}

FixedNDArray::FixedNDArray (const NDArray &is, const NDArray &ds, 
			  const FixedNDArray& a)
  : MArrayN<FixedPoint> (a.dims())
{
  if ((dims () != is.dims ()) || (dims () != ds.dims ())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i), 
			       a.elem (i));
}

FixedNDArray::FixedNDArray (unsigned int is, unsigned int ds, 
			  const FixedNDArray& a)
  : MArrayN<FixedPoint> (a.dims())
{
  for (int i = 0; i < nelem (); i++)
      elem (i) = FixedPoint(is, ds, a.elem (i));
}

FixedNDArray::FixedNDArray (const MArrayN<int> &is, 
			    const MArrayN<int> &ds, 
			    const NDArray& a)
  : MArrayN<FixedPoint> (a.dims())
{
  if ((dims () != is.dims ()) || (dims () != ds.dims ())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i), 
			       a.elem (i));
}

FixedNDArray::FixedNDArray (const NDArray &is, const NDArray &ds, 
			  const NDArray& a)
  : MArrayN<FixedPoint> (a.dims())
{
  if ((dims () != is.dims ()) || (dims () != ds.dims ())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i), 
			       a.elem (i));
}

FixedNDArray::FixedNDArray (unsigned int is, unsigned int ds,
			    const NDArray& a)
  : MArrayN<FixedPoint> (a.dims())
{
  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPoint(is, ds, a.elem (i));
}

FixedNDArray::FixedNDArray (unsigned int is, unsigned int ds, 
			    const NDArray& a, const NDArray& b)
  : MArrayN<FixedPoint> (a.dims())
{
  if (dims() != b.dims()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPoint(is, ds, (unsigned int)a.elem (i), 
			  (unsigned int)b.elem (i));
}

FixedNDArray::FixedNDArray (const MArrayN<int> &is, const MArrayN<int> &ds, 
			  const NDArray& a, const NDArray& b)
  : MArrayN<FixedPoint> (a.dims())
{
  if ((dims() != b.dims()) || (dims() != is.dims()) || 
      (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (int i = 0; i < nelem (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i), 
			       (unsigned int)a.elem (i), 
			       (unsigned int)b.elem (i));
}

FixedNDArray::FixedNDArray (const NDArray &is, const NDArray &ds, 
			    const NDArray& a, const NDArray& b)
  : MArrayN<FixedPoint> (a.dims())
{
  if ((dims() != b.dims()) || (dims() != is.dims()) || 
      (dims() != ds.dims())) {
    (*current_liboctave_error_handler) ("NDArray size mismatch");
    return;
  }

  for (octave_idx_type i = 0; i < nelem (); i++)
    elem (i) = FixedPoint((unsigned int)is(i), (unsigned int)ds(i), 
			       (unsigned int)a.elem (i), 
			       (unsigned int)b.elem (i));
}

FixedNDArray::FixedNDArray (const MArrayN<int> &a)
  : MArrayN<FixedPoint> (a.dims())
{
  for (octave_idx_type i = 0; i < nelem (); i++)
    elem (i) = FixedPoint(a.elem (i));
}

FixedNDArray::FixedNDArray (const NDArray &a)
  : MArrayN<FixedPoint> (a.dims())
{
  for (octave_idx_type i = 0; i < nelem (); i++)
    elem (i) = FixedPoint(a.elem (i));
}

#define GET_FIXED_PROP(METHOD) \
  NDArray \
  FixedNDArray:: METHOD (void) const \
    { \
      int nel = nelem(); \
      NDArray retval(dims());	    \
      for (int i = 0; i < nel; i++) \
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

FixedNDArray 
FixedNDArray::chdecsize (const double n)
{
  int nel = nelem();
  FixedNDArray retval(dims());

  for (int i = 0; i < nel; i++)
    retval(i) = FixedPoint(elem(i).getintsize(), (int)n, elem(i));

  return retval;
}

FixedNDArray 
FixedNDArray::chdecsize (const NDArray &n)
{
  int nel = nelem();

  if (dims() != n.dims()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch in chdecsize");
    return FixedNDArray();
  }

  FixedNDArray retval(dims());

  for (int i = 0; i < nel; i++)
    retval(i) = FixedPoint(elem(i).getintsize(), (int)n(i), elem(i));

  return retval;
}

FixedNDArray 
FixedNDArray::chintsize (const double n)
{
  int nel = nelem();
  FixedNDArray retval(dims());

  for (int i = 0; i < nel; i++)
    retval(i) = FixedPoint((int)n, elem(i).getdecsize(), elem(i));

  return retval;
}

FixedNDArray 
FixedNDArray::chintsize (const NDArray &n)
{
  int nel = nelem();

  if (dims() != n.dims()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch in chintsize");
    return FixedNDArray();
  }

  FixedNDArray retval(dims());

  for (int i = 0; i < nel; i++)
    retval(i) = FixedPoint((int)n(i), elem(i).getdecsize(), elem(i));

  return retval;
}

FixedNDArray 
FixedNDArray::incdecsize (const double n) {
  return chdecsize(n + getdecsize());
}

FixedNDArray
FixedNDArray::incdecsize (const NDArray &n) {
  if (dims() != n.dims()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch in chintsize");
    return FixedNDArray();
  }
  return chdecsize(n + getdecsize());
}

FixedNDArray 
FixedNDArray::incdecsize () {
  return chdecsize(1 + getdecsize());
}

FixedNDArray 
FixedNDArray::incintsize (const double n) {
  return chintsize(n + getintsize());
}

FixedNDArray
FixedNDArray::incintsize (const NDArray &n) {
  if (dims() != n.dims()) {
    (*current_liboctave_error_handler) ("NDArray size mismatch in chintsize");
    return FixedNDArray();
  }
  return chintsize(n + getintsize());
}

FixedNDArray 
FixedNDArray::incintsize () {
  return chintsize(1 + getintsize());
}

bool
FixedNDArray::operator == (const FixedNDArray& a) const
{
  if (dims () != a.dims ())
    return false;

    for (int i = 0; i < nelem(); i++)
      if (elem(i) != a.elem(i))
	return false;
    return true;
}

bool
FixedNDArray::operator != (const FixedNDArray& a) const
{
  return !(*this != a);
}

// unary operations

FixedNDArray
FixedNDArray::operator ! (void) const
{
  int nel = nelem ();

  FixedNDArray b (dims());

  for (int i = 0; i < nel; i++)
    b.elem (i) =  ! elem (i);

  return b;
}

// other operations.

boolNDArray
FixedNDArray::all (octave_idx_type dim) const
{
#define FMX_ND_ALL_EXPR  elem (iter_idx) .fixedpoint () == 0.0
  MX_ND_ANY_ALL_REDUCTION (MX_ND_ALL_EVAL (FMX_ND_ALL_EXPR), true);
#undef FMX_ND_ALL_EXPR
}

boolNDArray
FixedNDArray::any (octave_idx_type dim) const
{
#define FMX_ND_ANY_EXPR  elem (iter_idx) .fixedpoint () != 0.0
  MX_ND_ANY_ALL_REDUCTION (MX_ND_ANY_EVAL (FMX_ND_ANY_EXPR), false);
#undef FMX_ND_ANY_EXPR
}

FixedNDArray
FixedNDArray::cumprod (octave_idx_type dim) const
{
  FixedPoint one(1,0,1,0);
  MX_ND_CUMULATIVE_OP (FixedNDArray, FixedPoint, one, *);
}

FixedNDArray
FixedNDArray::cumsum (octave_idx_type dim) const
{
  FixedPoint zero;
  MX_ND_CUMULATIVE_OP (FixedNDArray, FixedPoint, zero, +);
}

FixedNDArray
FixedNDArray::prod (octave_idx_type dim) const
{
  FixedPoint one(1,0,1,0);
  MX_ND_REDUCTION (retval(result_idx) *= elem (iter_idx), one, FixedNDArray);
}

FixedNDArray
FixedNDArray::sum (octave_idx_type dim) const
{
  FixedPoint zero;
  MX_ND_REDUCTION (retval(result_idx) += elem (iter_idx), zero, FixedNDArray);
}

FixedNDArray
FixedNDArray::sumsq (octave_idx_type dim) const
{
  FixedPoint zero;
  MX_ND_REDUCTION (retval(result_idx) += pow (elem (iter_idx), 2), zero, 
		   FixedNDArray);
}

FixedNDArray
FixedNDArray::max (octave_idx_type dim) const
{
  ArrayN<octave_idx_type> dummy_idx;
  return max (dummy_idx, dim);
}

FixedNDArray
FixedNDArray::max (ArrayN<octave_idx_type>& idx_arg, octave_idx_type dim) const
{
  dim_vector dv = dims ();
  dim_vector dr = dims ();

  if (dv.numel () == 0 || dim > dv.length () || dim < 0)
    return FixedNDArray ();
  
  dr(dim) = 1;

  FixedNDArray result (dr);
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
      FixedPoint tmp_max = elem (x_offset);;

      for (octave_idx_type j = 1; j < x_len; j++)
	{
	  FixedPoint tmp = elem (j * x_stride + x_offset);

	  if (tmp > tmp_max)
	    {
	      idx_j = j;
	      tmp_max = tmp;
	    }
	}
      
      result.elem (i) = tmp_max;
      idx_arg.elem (i) = idx_j;
    }

  return result;
}

FixedNDArray
FixedNDArray::min (octave_idx_type dim) const
{
  ArrayN<octave_idx_type> dummy_idx;
  return min (dummy_idx, dim);
}

FixedNDArray
FixedNDArray::min (ArrayN<octave_idx_type>& idx_arg, octave_idx_type dim) const
{
  dim_vector dv = dims ();
  dim_vector dr = dims ();

  if (dv.numel () == 0 || dim > dv.length () || dim < 0)
    return FixedNDArray ();
  
  dr(dim) = 1;

  FixedNDArray result (dr);
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
      FixedPoint tmp_min = elem (x_offset);

      for (octave_idx_type j = 1; j < x_len; j++)
	{
	  FixedPoint tmp = elem (j * x_stride + x_offset);

	  if (tmp < tmp_min)
	    {
	      idx_j = j;
	      tmp_min = tmp;
	    }
	}
      
      result.elem (i) = tmp_min;
      idx_arg.elem (i) = idx_j;
    }

  return result;
}

FixedNDArray
FixedNDArray::abs (void) const
{
  octave_idx_type nel = nelem ();

  FixedNDArray retval (dims());

  for (octave_idx_type i = 0; i < nel; i++)
    retval (i) = ::abs(elem (i));

  return retval;
}

FixedMatrix
FixedNDArray::fixed_matrix_value (void) const
{
  FixedMatrix retval;

  octave_idx_type nd = ndims ();

  switch (nd)
    {
    case 1:
      retval = FixedMatrix (Array2<FixedPoint> (*this, dimensions(0), 1));
      break;

    case 2:
      retval = FixedMatrix (Array2<FixedPoint> (*this, dimensions(0), 
						dimensions(1)));
      break;

    default:
      (*current_liboctave_error_handler)
	("invalid conversion of FixedNDArray to FixedMatrix");
      break;
    }

  return retval;
}

#define DO_FIXED_ND_FUNC(FUNC) \
  FixedNDArray FUNC (const FixedNDArray& x) \
  {  \
    octave_idx_type nel = x.nelem (); \
    FixedNDArray retval ( x.dims()); \
    for (octave_idx_type i = 0; i < nel; i++) \
      retval(i) = FUNC ( x (i) ); \
    return retval; \
  }

DO_FIXED_ND_FUNC(real);
DO_FIXED_ND_FUNC(imag);
DO_FIXED_ND_FUNC(conj);
DO_FIXED_ND_FUNC(abs);
DO_FIXED_ND_FUNC(cos);
DO_FIXED_ND_FUNC(cosh);
DO_FIXED_ND_FUNC(sin);
DO_FIXED_ND_FUNC(sinh);
DO_FIXED_ND_FUNC(tan);
DO_FIXED_ND_FUNC(tanh);
DO_FIXED_ND_FUNC(sqrt);
DO_FIXED_ND_FUNC(exp);
DO_FIXED_ND_FUNC(log);
DO_FIXED_ND_FUNC(log10);
DO_FIXED_ND_FUNC(round);
DO_FIXED_ND_FUNC(rint);
DO_FIXED_ND_FUNC(floor);
DO_FIXED_ND_FUNC(ceil);

FixedNDArray elem_pow (const FixedNDArray &a, const FixedNDArray &b)
{
  FixedNDArray retval;
  dim_vector a_dv = a.dims ();
  int a_nel = a.numel ();
  dim_vector b_dv = b.dims ();
  int b_nel = b.numel ();

  if (a_nel == 1)
    {
      retval.resize(b_dv);
      FixedPoint ad = a(0);
      for (int i = 0; i < b_nel; i++)
	retval(i) = pow(ad, b(i));
    }
  else if (b_nel == 1)
    {
      retval.resize(a_dv);
      FixedPoint bd = b(0);
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

FixedNDArray elem_pow (const FixedNDArray &a, const FixedPoint &b)
{
  return elem_pow (a, FixedNDArray(dim_vector (1), b));
}

FixedNDArray elem_pow (const FixedPoint &a, const FixedNDArray &b)
{
  return elem_pow (FixedNDArray(dim_vector (1), a), b);
}

FixedNDArray atan2 (const FixedNDArray &x, const FixedNDArray &y)
{
  FixedNDArray retval;
  if (x.dims() == y.dims()) {
    int nel = x.nelem ();
    retval.resize(x.dims());
    for (int i = 0; i < nel; i++)
      retval(i) = atan2 ( x(i), y(i));
  } else
    (*current_liboctave_error_handler) ("NDArray size mismatch");
  return retval;
}

FixedNDArray 
FixedNDArray::concat (const FixedNDArray& rb, const Array<octave_idx_type>& ra_idx)
{
  if (rb.numel () > 0)
    insert (rb, ra_idx);
  return *this;
}

FixedComplexNDArray 
FixedNDArray::concat (const FixedComplexNDArray& rb, 
		      const Array<octave_idx_type>& ra_idx)
{
  FixedComplexNDArray retval (*this);
  if (rb.numel () > 0)
    retval.insert (rb, ra_idx);
  return retval;
}

FixedNDArray&
FixedNDArray::insert (const FixedNDArray& a, const Array<octave_idx_type>& ra_idx)
{
  Array<FixedPoint>::insert (a, ra_idx);
  return *this;
}

void
FixedNDArray::increment_index (Array<octave_idx_type>& ra_idx,
			       const dim_vector& dimensions,
			       octave_idx_type start_dimension)
{
  ::increment_index (ra_idx, dimensions, start_dimension);
}

octave_idx_type
FixedNDArray::compute_index (Array<octave_idx_type>& ra_idx,
			     const dim_vector& dimensions)
{
  return ::compute_index (ra_idx, dimensions);
}

std::ostream&
operator << (std::ostream& os, const FixedNDArray& a)
{
  int nel = a.nelem ();

  for (int i = 0; i < nel; i++)
    os << " " << a.elem(i) << "\n";
  return os;
}

std::istream&
operator >> (std::istream& is, FixedNDArray& a)
{
  int nel = a.nelem ();

  if (nel < 1 )
    is.clear (std::ios::badbit);
  else
    {
      FixedPoint tmp;
      for (int i = 0; i < nel; i++)
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

// XXX FIXME XXX -- it would be nice to share code among the min/max
// functions below.

#define EMPTY_RETURN_CHECK(T) \
  if (nel == 0) \
    return T (dv);

FixedNDArray
min (FixedPoint d, const FixedNDArray& m)
{
  dim_vector dv = m.dims ();
  int nel = dv.numel ();

  EMPTY_RETURN_CHECK (FixedNDArray);

  FixedNDArray result (dv);

  for (int i = 0; i < nel; i++)
    {
      OCTAVE_QUIT;
      result (i) = m(i) < d ? m(i) : d;
    }

  return result;
}

FixedNDArray
min (const FixedNDArray& m, FixedPoint d)
{
  dim_vector dv = m.dims ();
  int nel = dv.numel ();

  EMPTY_RETURN_CHECK (FixedNDArray);

  FixedNDArray result (dv);

  for (int i = 0; i < nel; i++)
    {
      OCTAVE_QUIT;
      result (i) = m(i) < d ? m(i) : d;
    }

  return result;
}

FixedNDArray
min (const FixedNDArray& a, const FixedNDArray& b)
{
  dim_vector dv = a.dims ();
  int nel = dv.numel ();

  if (dv != b.dims ())
    {
      (*current_liboctave_error_handler)
	("two-arg min expecting args of same size");
      return FixedNDArray ();
    }

  EMPTY_RETURN_CHECK (FixedNDArray);

  FixedNDArray result (dv);

  for (int i = 0; i < nel; i++)
    {
      OCTAVE_QUIT;
      result (i) = a(i) < b(i) ? a(i) : b(i);
    }

  return result;
}

FixedNDArray
max (FixedPoint d, const FixedNDArray& m)
{
  dim_vector dv = m.dims ();
  int nel = dv.numel ();

  EMPTY_RETURN_CHECK (FixedNDArray);

  FixedNDArray result (dv);

  for (int i = 0; i < nel; i++)
    {
      OCTAVE_QUIT;
      result (i) = m(i) > d ? m(i) : d;
    }

  return result;
}

FixedNDArray
max (const FixedNDArray& m, FixedPoint d)
{
  dim_vector dv = m.dims ();
  int nel = dv.numel ();

  EMPTY_RETURN_CHECK (FixedNDArray);

  FixedNDArray result (dv);

  for (int i = 0; i < nel; i++)
    {
      OCTAVE_QUIT;
      result (i) = m(i) > d ? m(i) : d;
    }

  return result;
}

FixedNDArray
max (const FixedNDArray& a, const FixedNDArray& b)
{
  dim_vector dv = a.dims ();
  int nel = dv.numel ();

  if (dv != b.dims ())
    {
      (*current_liboctave_error_handler)
	("two-arg min expecting args of same size");
      return FixedNDArray ();
    }

  EMPTY_RETURN_CHECK (FixedNDArray);

  FixedNDArray result (dv);

  for (int i = 0; i < nel; i++)
    {
      OCTAVE_QUIT;
      result (i) = a(i) > b(i) ? a(i) : b(i);
    }

  return result;
}

NDS_CMP_OPS(FixedNDArray, , FixedPoint, )
NDS_BOOL_OPS(FixedNDArray, FixedPoint, FixedPoint())

SND_CMP_OPS(FixedPoint, , FixedNDArray, )
SND_BOOL_OPS(FixedPoint, FixedNDArray, FixedPoint())

NDND_CMP_OPS(FixedNDArray, , FixedNDArray, )
NDND_BOOL_OPS(FixedNDArray, FixedNDArray, FixedPoint())

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
