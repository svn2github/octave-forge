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
#include <octave/lo-error.h>
#include <octave/lo-utils.h>
#include <octave/lo-error.h>
#include <octave/error.h>
#include <octave/dMatrix.h>
#include <octave/gripes.h>
#include <octave/ops.h>
#include <octave/quit.h>

#include "fixedColVector.h"
#include "fixedRowVector.h"
#include "fixedMatrix.h"
#include "fixedCColVector.h"
#include "fixedCRowVector.h"
#include "fixedCMatrix.h"

// Fixed Point Complex Matrix class.

FixedComplexMatrix::FixedComplexMatrix (const MArray2<int> &is, 
					const MArray2<int> &ds)
  : MArray2<FixedPointComplex> (is.rows(), is.cols())
{
  if ((rows() != ds.rows()) || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex((unsigned int)is(i,j), 
				      (unsigned int)ds(i,j));
}

FixedComplexMatrix::FixedComplexMatrix (const Matrix &is, const Matrix &ds)
  : MArray2<FixedPointComplex> (is.rows(), is.cols())
{
  if ((rows() != ds.rows()) || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex((unsigned int)is(i,j), 
				      (unsigned int)ds(i,j));
}

FixedComplexMatrix::FixedComplexMatrix (const ComplexMatrix &is, 
					const ComplexMatrix &ds)
  : MArray2<FixedPointComplex> (is.rows(), is.cols())
{
  if ((rows() != ds.rows()) || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex( is(i,j), ds(i,j));
}

FixedComplexMatrix::FixedComplexMatrix (unsigned int is, unsigned int ds, 
					const FixedComplexMatrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex(is, ds, a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (Complex is, Complex ds, 
					const FixedComplexMatrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex(is, ds, a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (const MArray2<int> &is,
		const MArray2<int> &ds, const FixedComplexMatrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex((unsigned int)is(i,j), 
				      (unsigned int)ds(i,j), a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (const Matrix &is, const Matrix &ds, 
					const FixedComplexMatrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex((unsigned int)is(i,j), 
				      (unsigned int)ds(i,j), a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (const ComplexMatrix &is,
		const ComplexMatrix &ds, const FixedComplexMatrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex( is(i,j), ds(i,j), a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (unsigned int is, unsigned int ds, 
					const FixedMatrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex(is, ds, a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (Complex is, Complex ds, 
					const FixedMatrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex(is, ds, FixedPointComplex(a.elem (i, j)));
}

FixedComplexMatrix::FixedComplexMatrix (const MArray2<int> &is,
		const MArray2<int> &ds, const FixedMatrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex((unsigned int)is(i,j), 
				      (unsigned int)ds(i,j), a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (const Matrix &is, const Matrix &ds, 
					const FixedMatrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex((unsigned int)is(i,j), 
				      (unsigned int)ds(i,j), a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (const ComplexMatrix &is,
		const ComplexMatrix &ds, const FixedMatrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex( is(i,j), ds(i,j), FixedPointComplex(a.elem (i, j)));
}

FixedComplexMatrix::FixedComplexMatrix (unsigned int is, unsigned int ds, 
					const ComplexMatrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex(is, ds, a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (Complex is, Complex ds, 
					const ComplexMatrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex(is, ds, a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (const MArray2<int> &is, 
		const MArray2<int> &ds, const ComplexMatrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex((unsigned int)is(i,j), 
				      (unsigned int)ds(i,j), a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (const Matrix &is, const Matrix &ds, 
					const ComplexMatrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex((unsigned int)is(i,j), 
				      (unsigned int)ds(i,j), a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (const ComplexMatrix &is, 
		const ComplexMatrix &ds, const ComplexMatrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex(is(i,j), ds(i,j), a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (unsigned int is, unsigned int ds, 
					const Matrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex(is, ds, a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (Complex is, Complex ds, 
					const Matrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex(is, ds, a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (const MArray2<int> &is, 
		const MArray2<int> &ds, const Matrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex((unsigned int)is(i,j), 
				      (unsigned int)ds(i,j), a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (const Matrix &is, const Matrix &ds, 
					const Matrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex((unsigned int)is(i,j), 
				      (unsigned int)ds(i,j), a.elem (i, j));
}

FixedComplexMatrix::FixedComplexMatrix (const ComplexMatrix &is, 
		const ComplexMatrix &ds, const Matrix& a)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex(is(i,j), ds(i,j), a.elem (i, j));
}


FixedComplexMatrix::FixedComplexMatrix (unsigned int is, unsigned int ds, 
			const ComplexMatrix& a, const ComplexMatrix& b)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != b.rows()) || (cols() != b.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex(is, ds, a.elem (i, j), b.elem(i,j));
}

FixedComplexMatrix::FixedComplexMatrix (Complex is, Complex ds, 
			const ComplexMatrix& a, const ComplexMatrix& b)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != b.rows()) || (cols() != b.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex(is, ds, a.elem (i, j), b.elem(i,j));
}

FixedComplexMatrix::FixedComplexMatrix (const MArray2<int> &is, 
		const MArray2<int> &ds, const ComplexMatrix& a, 
		const ComplexMatrix& b)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != b.rows()) || (cols() != b.cols()) || (rows() != is.rows())
      || (cols() != is.cols()) || (rows() != ds.rows()) 
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex(is(i, j), ds(i, j), a.elem (i, j), 
				      b.elem(i,j));
}

FixedComplexMatrix::FixedComplexMatrix (const Matrix &is, const Matrix &ds, 
		const ComplexMatrix& a, const ComplexMatrix& b)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != b.rows()) || (cols() != b.cols()) || (rows() != is.rows())
      || (cols() != is.cols()) || (rows() != ds.rows()) 
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex((unsigned int)is(i, j), 
			(unsigned int)ds(i, j), a.elem (i, j), b.elem(i,j));
}

FixedComplexMatrix::FixedComplexMatrix (const ComplexMatrix &is, 
		const ComplexMatrix &ds, const ComplexMatrix& a, 
		const ComplexMatrix& b)
  : MArray2<FixedPointComplex> (a.rows(), a.cols())
{
  if ((rows() != b.rows()) || (cols() != b.cols()) || (rows() != is.rows())
      || (cols() != is.cols()) || (rows() != ds.rows()) 
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPointComplex(is(i, j), ds(i, j), a.elem (i, j), 
				      b.elem(i,j));
}

FixedComplexMatrix::FixedComplexMatrix (const FixedComplexRowVector& rv)
  : MArray2<FixedPointComplex> (1, rv.length (), FixedPointComplex())
{
  for (int i = 0; i < rv.length (); i++)
    elem (0, i) = rv.elem (i);
}

FixedComplexMatrix::FixedComplexMatrix (const FixedRowVector& rv)
  : MArray2<FixedPointComplex> (1, rv.length (), FixedPointComplex())
{
  for (int i = 0; i < rv.length (); i++)
    elem (0, i) = FixedPointComplex(rv.elem (i));
}

FixedComplexMatrix::FixedComplexMatrix (const FixedComplexColumnVector& cv)
  : MArray2<FixedPointComplex> (cv.length (), 1, FixedPointComplex())
{
  for (int i = 0; i < cv.length (); i++)
    elem (i, 0) = cv.elem (i);
}

FixedComplexMatrix::FixedComplexMatrix (const FixedColumnVector& cv)
  : MArray2<FixedPointComplex> (cv.length (), 1, FixedPointComplex())
{
  for (int i = 0; i < cv.length (); i++)
    elem (i, 0) = FixedPointComplex(cv.elem (i));
}

FixedComplexMatrix::FixedComplexMatrix (const FixedMatrix& m)
  : MArray2<FixedPointComplex> (m.rows (), m.cols (), FixedPointComplex())
{
  for (int j = 0; j < m.cols (); j++)
    for (int i = 0; i < m.rows (); i++)
    elem (i, j) = FixedPointComplex(m.elem (i,j));
}

FixedComplexMatrix::FixedComplexMatrix (const FixedMatrix& a,
					const FixedMatrix& b)
  : MArray2<FixedPointComplex> (a.rows (), a.cols (), FixedPointComplex())
{
  if ((rows() != b.rows()) || (cols() != b.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }
  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
    elem (i, j) = FixedPointComplex(a.elem (i,j), b.elem (i,j));
}

#define GET_FIXED_PROP(METHOD) \
  ComplexMatrix \
  FixedComplexMatrix:: METHOD (void) const \
    { \
      int nr = rows(); \
      int nc = cols(); \
      ComplexMatrix retval(nr,nc); \
      for (int i = 0; i < nr; i++) \
        for (int j = 0; j < nc; j++) \
          retval(i,j) = elem(i,j) . METHOD (); \
      return retval; \
    } \

GET_FIXED_PROP(sign);
GET_FIXED_PROP(getdecsize);
GET_FIXED_PROP(getintsize);
GET_FIXED_PROP(getnumber);
GET_FIXED_PROP(fixedpoint);

#undef GET_FIXED_PROP

FixedComplexMatrix 
FixedComplexMatrix::chdecsize (const Complex n)
{
  int nr = rows();
  int nc = cols();
  FixedComplexMatrix retval(nr,nc);

  for (int i = 0; i < nr; i++)
    for (int j = 0; j < nc; j++)
      retval(i,j) = FixedPointComplex(elem(i,j).getintsize(), n, elem(i,j));

  return retval;
}

FixedComplexMatrix 
FixedComplexMatrix::chdecsize (const ComplexMatrix &n)
{
  int nr = rows();
  int nc = cols();

  if ((nr != n.rows()) || (nc != n.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch in chdecsize");
    return FixedComplexMatrix();
  }

  FixedComplexMatrix retval(nr,nc);

  for (int i = 0; i < nr; i++)
    for (int j = 0; j < nc; j++)
      retval(i,j) = FixedPointComplex(elem(i,j).getintsize(), n(i,j), 
				      elem(i,j));

  return retval;
}

FixedComplexMatrix 
FixedComplexMatrix::chintsize (const Complex n)
{
  int nr = rows();
  int nc = cols();
  FixedComplexMatrix retval(nr,nc);

  for (int i = 0; i < nr; i++)
    for (int j = 0; j < nc; j++)
      retval(i,j) = FixedPointComplex(n, elem(i,j).getdecsize(), elem(i,j));

  return retval;
}

FixedComplexMatrix 
FixedComplexMatrix::chintsize (const ComplexMatrix &n)
{
  int nr = rows();
  int nc = cols();

  if ((nr != n.rows()) || (nc != n.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch in chintsize");
    return FixedComplexMatrix();
  }

  FixedComplexMatrix retval(nr,nc);

  for (int i = 0; i < nr; i++)
    for (int j = 0; j < nc; j++)
      retval(i,j) = FixedPointComplex(n(i,j), elem(i,j).getdecsize(), 
				      elem(i,j));

  return retval;
}

FixedComplexMatrix 
FixedComplexMatrix::incdecsize (const Complex n) {
  return chdecsize(n + getdecsize());
}

FixedComplexMatrix
FixedComplexMatrix::incdecsize (const ComplexMatrix &n) {
  if ((n.rows() != rows()) || (n.cols() != cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch in chintsize");
    return FixedComplexMatrix();
  }
  return chdecsize(n + getdecsize());
}

FixedComplexMatrix 
FixedComplexMatrix::incdecsize () {
  return chdecsize(Complex(1,1) + getdecsize());
}

FixedComplexMatrix 
FixedComplexMatrix::incintsize (const Complex n) {
  return chintsize(n + getintsize());
}

FixedComplexMatrix
FixedComplexMatrix::incintsize (const ComplexMatrix &n) {
  if ((n.rows() != rows()) || (n.cols() != cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch in chintsize");
    return FixedComplexMatrix();
  }
  return chintsize(n + getintsize());
}

FixedComplexMatrix 
FixedComplexMatrix::incintsize () {
  return chintsize(Complex(1,1) + getintsize());
}

bool
FixedComplexMatrix::operator == (const FixedComplexMatrix& a) const
{
  if (rows () != a.rows () || cols () != a.cols ())
    return false;

    for (int i = 0; i < rows(); i++)
      for (int j = 0; j < cols(); j++)
	if (elem(i,j) != a.elem(i,j))
	  return false;
    return true;
}

bool
FixedComplexMatrix::operator != (const FixedComplexMatrix& a) const
{
  return !(*this == a);
}

bool
FixedComplexMatrix::is_symmetric (void) const
{
  if (is_square () && rows () > 0)
    {
      for (int i = 0; i < rows (); i++)
	for (int j = i+1; j < cols (); j++)
	  if (elem (i, j) != elem (j, i))
	    return false;

      return true;
    }

  return false;
}

FixedComplexMatrix 
FixedComplexMatrix::concat (const FixedComplexMatrix& rb, 
			    const Array<int>& ra_idx)
{
  if (rb.numel() > 0)
    insert (rb, ra_idx(0), ra_idx(1));
  return *this;
}

FixedComplexMatrix
FixedComplexMatrix::concat (const FixedMatrix& rb, 
			    const Array<int>& ra_idx)
{
  if (rb.numel() > 0)
    insert (FixedComplexMatrix (rb), ra_idx(0), ra_idx(1));
  return *this;
}

FixedComplexMatrix&
FixedComplexMatrix::insert (const FixedComplexMatrix& a, int r, int c)
{
  Array2<FixedPointComplex>::insert (a, r, c);
  return *this;
}

FixedComplexMatrix&
FixedComplexMatrix::insert (const FixedComplexRowVector& a, int r, int c)
{
  int a_len = a.length ();

  if (r < 0 || r >= rows () || c < 0 || c + a_len > cols ())
    {
      (*current_liboctave_error_handler) ("range error for insert");
      return *this;
    }

  if (a_len > 0)
    {
      make_unique ();

      for (int i = 0; i < a_len; i++)
	xelem (r, c+i) = a.elem (i);
    }

  return *this;
}

FixedComplexMatrix&
FixedComplexMatrix::insert (const FixedComplexColumnVector& a, int r, int c)
{
  int a_len = a.length ();

  if (r < 0 || r + a_len > rows () || c < 0 || c >= cols ())
    {
      (*current_liboctave_error_handler) ("range error for insert");
      return *this;
    }

  if (a_len > 0)
    {
      make_unique ();

      for (int i = 0; i < a_len; i++)
	xelem (r+i, c) = a.elem (i);
    }

  return *this;
}

FixedComplexMatrix&
FixedComplexMatrix::fill (FixedPointComplex val)
{
  int nr = rows ();
  int nc = cols ();

  if (nr > 0 && nc > 0)
    {
      make_unique ();

      for (int j = 0; j < nc; j++)
	for (int i = 0; i < nr; i++)
	  xelem (i, j) = val;
    }

  return *this;
}

FixedComplexMatrix&
FixedComplexMatrix::fill (FixedPointComplex val, int r1, int c1, int r2, int c2)
{
  int nr = rows ();
  int nc = cols ();

  if (r1 < 0 || r2 < 0 || c1 < 0 || c2 < 0
      || r1 >= nr || r2 >= nr || c1 >= nc || c2 >= nc)
    {
      (*current_liboctave_error_handler) ("range error for fill");
      return *this;
    }

  if (r1 > r2) { int tmp = r1; r1 = r2; r2 = tmp; }
  if (c1 > c2) { int tmp = c1; c1 = c2; c2 = tmp; }

  if (r2 >= r1 && c2 >= c1)
    {
      make_unique ();

      for (int j = c1; j <= c2; j++)
	for (int i = r1; i <= r2; i++)
	  xelem (i, j) = val;
    }

  return *this;
}

FixedComplexMatrix
FixedComplexMatrix::append (const FixedComplexMatrix& a) const
{
  int nr = rows ();
  int nc = cols ();
  if (nr != a.rows ())
    {
      (*current_liboctave_error_handler) ("row dimension mismatch for append");
      return FixedComplexMatrix ();
    }

  int nc_insert = nc;
  FixedComplexMatrix retval (nr, nc + a.cols ());
  retval.insert (*this, 0, 0);
  retval.insert (a, 0, nc_insert);
  return retval;
}

FixedComplexMatrix
FixedComplexMatrix::append (const FixedComplexRowVector& a) const
{
  int nr = rows ();
  int nc = cols ();
  if (nr != 1)
    {
      (*current_liboctave_error_handler) ("row dimension mismatch for append");
      return FixedComplexMatrix ();
    }

  int nc_insert = nc;
  FixedComplexMatrix retval (nr, nc + a.length ());
  retval.insert (*this, 0, 0);
  retval.insert (a, 0, nc_insert);
  return retval;
}

FixedComplexMatrix
FixedComplexMatrix::append (const FixedComplexColumnVector& a) const
{
  int nr = rows ();
  int nc = cols ();
  if (nr != a.length ())
    {
      (*current_liboctave_error_handler) ("row dimension mismatch for append");
      return FixedComplexMatrix ();
    }

  int nc_insert = nc;
  FixedComplexMatrix retval (nr, nc + 1);
  retval.insert (*this, 0, 0);
  retval.insert (a, 0, nc_insert);
  return retval;
}

FixedComplexMatrix
FixedComplexMatrix::stack (const FixedComplexMatrix& a) const
{
  int nr = rows ();
  int nc = cols ();
  if (nc != a.cols ())
    {
      (*current_liboctave_error_handler)
	("column dimension mismatch for stack");
      return FixedComplexMatrix ();
    }

  int nr_insert = nr;
  FixedComplexMatrix retval (nr + a.rows (), nc);
  retval.insert (*this, 0, 0);
  retval.insert (a, nr_insert, 0);
  return retval;
}

FixedComplexMatrix
FixedComplexMatrix::stack (const FixedComplexRowVector& a) const
{
  int nr = rows ();
  int nc = cols ();
  if (nc != a.length ())
    {
      (*current_liboctave_error_handler)
	("column dimension mismatch for stack");
      return FixedComplexMatrix ();
    }

  int nr_insert = nr;
  FixedComplexMatrix retval (nr + 1, nc);
  retval.insert (*this, 0, 0);
  retval.insert (a, nr_insert, 0);
  return retval;
}

FixedComplexMatrix
FixedComplexMatrix::stack (const FixedComplexColumnVector& a) const
{
  int nr = rows ();
  int nc = cols ();
  if (nc != 1)
    {
      (*current_liboctave_error_handler)
	("column dimension mismatch for stack");
      return FixedComplexMatrix ();
    }

  int nr_insert = nr;
  FixedComplexMatrix retval (nr + a.length (), nc);
  retval.insert (*this, 0, 0);
  retval.insert (a, nr_insert, 0);
  return retval;
}

FixedComplexMatrix
FixedComplexMatrix::extract (int r1, int c1, int r2, int c2) const
{
  if (r1 > r2) { int tmp = r1; r1 = r2; r2 = tmp; }
  if (c1 > c2) { int tmp = c1; c1 = c2; c2 = tmp; }

  int new_r = r2 - r1 + 1;
  int new_c = c2 - c1 + 1;

  FixedComplexMatrix result (new_r, new_c);

  for (int j = 0; j < new_c; j++)
    for (int i = 0; i < new_r; i++)
      result.xelem (i, j) = elem (r1+i, c1+j);

  return result;
}

FixedComplexMatrix
FixedComplexMatrix::extract_n (int r1, int c1, int nr, int nc) const
{
  FixedComplexMatrix result (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      result.xelem (i, j) = elem (r1+i, c1+j);

  return result;
}

// extract row or column i.

FixedComplexRowVector
FixedComplexMatrix::row (int i) const
{
  int nc = cols ();
  if (i < 0 || i >= rows ())
    {
      (*current_liboctave_error_handler) ("invalid row selection");
      return FixedComplexRowVector ();
    }

  FixedComplexRowVector retval (nc);
  for (int j = 0; j < nc; j++)
    retval.xelem (j) = elem (i, j);

  return retval;
}

FixedComplexRowVector
FixedComplexMatrix::row (char *s) const
{
  if (! s)
    {
      (*current_liboctave_error_handler) ("invalid row selection");
      return FixedComplexRowVector ();
    }

  char c = *s;
  if (c == 'f' || c == 'F')
    return row (0);
  else if (c == 'l' || c == 'L')
    return row (rows () - 1);
  else
    {
      (*current_liboctave_error_handler) ("invalid row selection");
      return FixedComplexRowVector ();
    }
}

FixedComplexColumnVector
FixedComplexMatrix::column (int i) const
{
  int nr = rows ();
  if (i < 0 || i >= cols ())
    {
      (*current_liboctave_error_handler) ("invalid column selection");
      return FixedComplexColumnVector ();
    }

  FixedComplexColumnVector retval (nr);
  for (int j = 0; j < nr; j++)
    retval.xelem (j) = elem (j, i);

  return retval;
}

FixedComplexColumnVector
FixedComplexMatrix::column (char *s) const
{
  if (! s)
    {
      (*current_liboctave_error_handler) ("invalid column selection");
      return FixedComplexColumnVector ();
    }

  char c = *s;
  if (c == 'f' || c == 'F')
    return column (0);
  else if (c == 'l' || c == 'L')
    return column (cols () - 1);
  else
    {
      (*current_liboctave_error_handler) ("invalid column selection");
      return FixedComplexColumnVector ();
    }
}

// unary operations

FixedComplexMatrix
FixedComplexMatrix::operator ! (void) const
{
  int nr = rows ();
  int nc = cols ();

  FixedComplexMatrix b (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      b.elem (i, j) =  ! elem (i, j) ;
  
  return b;
}

// column vector by row vector -> matrix operations

FixedComplexMatrix
operator * (const FixedComplexColumnVector& v, const FixedComplexRowVector& a)
{
  FixedComplexMatrix retval;

  int len = v.length ();

  if (len != 0)
    {
      int a_len = a.length ();

      retval.resize (len, a_len);

      for (int i = 0; i < len; i++)
	for (int j = 0; j < a_len; j++)
	  retval.elem(j,i) = v.elem(i) * a.elem(j);
    }

  return retval;
}

// other operations.

FixedComplexMatrix
FixedComplexMatrix::map (fc_fc_Mapper f) const
{
  FixedComplexMatrix b (*this);
  return b.apply (f);
}

FixedComplexMatrix&
FixedComplexMatrix::apply (fc_fc_Mapper f)
{
  FixedPointComplex *d = fortran_vec (); // Ensures only one reference to my privates!

  for (int i = 0; i < length (); i++)
    d[i] = f (d[i]);

  return *this;
}

boolMatrix
FixedComplexMatrix::all (int dim) const
{
#define ROW_EXPR \
  if (elem (i, j) .fixedpoint () == 0.0) \
    { \
      retval.elem (i, 0) = false; \
      break; \
    }
#define COL_EXPR \
  if (elem (i, j) .fixedpoint () == 0.0) \
    { \
      retval.elem (0, j) = false; \
      break; \
    }

  MX_BASE_REDUCTION_OP (boolMatrix, ROW_EXPR, COL_EXPR, true, true);

#undef ROW_EXPR
#undef COL_EXPR
}

boolMatrix
FixedComplexMatrix::any (int dim) const
{
#define ROW_EXPR \
  if (elem (i, j) .fixedpoint () != 0.0) \
    { \
      retval.elem (i, 0) = true; \
      break; \
    }
#define COL_EXPR \
  if (elem (i, j) .fixedpoint () != 0.0) \
    { \
      retval.elem (0, j) = true; \
      break; \
    }

  MX_BASE_REDUCTION_OP (boolMatrix, ROW_EXPR, COL_EXPR, false, false);

#undef ROW_EXPR
#undef COL_EXPR
}

FixedComplexMatrix
FixedComplexMatrix::cumprod (int dim) const
{
  MX_CUMULATIVE_OP (FixedComplexMatrix, FixedPointComplex, *=);
}

FixedComplexMatrix
FixedComplexMatrix::cumsum (int dim) const
{
  MX_CUMULATIVE_OP (FixedComplexMatrix, FixedPointComplex, +=);
}

FixedComplexMatrix
FixedComplexMatrix::prod (int dim) const
{
  FixedPointComplex one(1, 0, 1, 0);
  MX_REDUCTION_OP (FixedComplexMatrix, *=, one, one);
}

FixedComplexMatrix
FixedComplexMatrix::sum (int dim) const
{
  FixedPointComplex zero;
  MX_REDUCTION_OP (FixedComplexMatrix, +=, zero, zero);
}

FixedComplexMatrix
FixedComplexMatrix::sumsq (int dim) const
{
  FixedPointComplex zero;
#define ROW_EXPR \
  FixedPointComplex d = elem (i, j); \
  retval.elem (i, 0) += d * conj(d)

#define COL_EXPR \
  FixedPointComplex d = elem (i, j); \
  retval.elem (0, j) += d * conj(d)

  MX_BASE_REDUCTION_OP (FixedComplexMatrix, ROW_EXPR, COL_EXPR, zero, zero);

#undef ROW_EXPR
#undef COL_EXPR
}

FixedComplexMatrix
FixedComplexMatrix::abs (void) const
{
  int nr = rows ();
  int nc = cols ();

  FixedComplexMatrix retval (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      retval (i, j) = ::abs(elem (i, j));

  return retval;
}

FixedComplexColumnVector
FixedComplexMatrix::diag (void) const
{
  return diag (0);
}

FixedComplexColumnVector
FixedComplexMatrix::diag (int k) const
{
  int nnr = rows ();
  int nnc = cols ();
  if (k > 0)
    nnc -= k;
  else if (k < 0)
    nnr += k;

  FixedComplexColumnVector d;

  if (nnr > 0 && nnc > 0)
    {
      int ndiag = (nnr < nnc) ? nnr : nnc;

      d.resize (ndiag);

      if (k > 0)
	{
	  for (int i = 0; i < ndiag; i++)
	    d.elem (i) = elem (i, i+k);
	}
      else if ( k < 0)
	{
	  for (int i = 0; i < ndiag; i++)
	    d.elem (i) = elem (i-k, i);
	}
      else
	{
	  for (int i = 0; i < ndiag; i++)
	    d.elem (i) = elem (i, i);
	}
    }
  else
    std::cerr << "diag: requested diagonal out of range\n";

  return d;
}

FixedComplexColumnVector
FixedComplexMatrix::row_min (void) const
{
  Array<int> index;
  return row_min (index);
}

FixedComplexColumnVector
FixedComplexMatrix::row_min (Array<int>& index) const
{
  FixedComplexColumnVector result;

  int nr = rows ();
  int nc = cols ();

  if (nr > 0 && nc > 0)
    {
      result.resize (nr);
      index.resize (nr);

      for (int i = 0; i < nr; i++)
        {
	  int idx_j = 0;

	  FixedPointComplex tmp_min = elem (i, idx_j);
	  FixedPoint tmp_min_abs = ::abs(tmp_min);

	  for (int j = 1; j < nc; j++)
	    {
	      FixedPointComplex tmp = elem (i, j);
	      FixedPoint tmp_abs = ::abs(tmp);
	      if (tmp_abs < tmp_min_abs)
		{
		  idx_j = j;
		  tmp_min = tmp;
		  tmp_min_abs = tmp_abs;
		}
	    }
	  
	  result.elem (i) = tmp_min;
	  index.elem (i) = idx_j;
        }
    }
  
  return result;
}

FixedComplexColumnVector
FixedComplexMatrix::row_max (void) const
{
  Array<int> index;
  return row_max (index);
}

FixedComplexColumnVector
FixedComplexMatrix::row_max (Array<int>& index) const
{
  FixedComplexColumnVector result;

  int nr = rows ();
  int nc = cols ();

  if (nr > 0 && nc > 0)
    {
      result.resize (nr);
      index.resize (nr);

      for (int i = 0; i < nr; i++)
        {
	  int idx_j = 0;

	  FixedPointComplex tmp_max = elem (i, idx_j);
	  FixedPoint tmp_max_abs = ::abs(tmp_max);

	  for (int j = 1; j < nc; j++)
	    {
	      FixedPointComplex tmp = elem (i, j);
	      FixedPoint tmp_abs = ::abs(tmp);
	      if (tmp_abs > tmp_max_abs)
		{
		  idx_j = j;
		  tmp_max = tmp;
		  tmp_max_abs = tmp_abs;
		}
	    }

	  result.elem (i) = tmp_max;
	  index.elem (i) = idx_j;
        }
    }

  return result;
}

FixedComplexRowVector
FixedComplexMatrix::column_min (void) const
{
  Array<int> index;
  return column_min (index);
}

FixedComplexRowVector
FixedComplexMatrix::column_min (Array<int>& index) const
{
  FixedComplexRowVector result;

  int nr = rows ();
  int nc = cols ();

  if (nr > 0 && nc > 0)
    {
      result.resize (nc);
      index.resize (nc);

      for (int j = 0; j < nc; j++)
        {
	  int idx_i = 0;

	  FixedPointComplex tmp_min = elem (idx_i, j);
	  FixedPoint tmp_min_abs = ::abs(tmp_min);

	  for (int i = 1; i < nr; i++)
	    {
	      FixedPointComplex tmp = elem (i, j);
	      FixedPoint tmp_abs = ::abs(tmp);
	      if (tmp_abs < tmp_min_abs)
		{
		  idx_i = i;
		  tmp_min = tmp;
		  tmp_min_abs = tmp_abs;
		}
	    }

	  result.elem (j) = tmp_min;
	  index.elem (j) = idx_i;
        }
    }

  return result;
}

FixedComplexRowVector
FixedComplexMatrix::column_max (void) const
{
  Array<int> index;
  return column_max (index);
}

FixedComplexRowVector
FixedComplexMatrix::column_max (Array<int>& index) const
{
  FixedComplexRowVector result;

  int nr = rows ();
  int nc = cols ();

  if (nr > 0 && nc > 0)
    {
      result.resize (nc);
      index.resize (nc);

      for (int j = 0; j < nc; j++)
        {
	  int idx_i = 0;

	  FixedPointComplex tmp_max = elem (idx_i, j);
	  FixedPoint tmp_max_abs = ::abs(tmp_max);

	  for (int i = 1; i < nr; i++)
	    {
	      FixedPointComplex tmp = elem (i, j);
	      FixedPoint tmp_abs = ::abs(tmp);

	      if (tmp_abs > tmp_max_abs)
		{
		  idx_i = i;
		  tmp_max = tmp;
		  tmp_max_abs = tmp_abs;
		}
	    }

	  result.elem (j) = tmp_max;
	  index.elem (j) = idx_i;
        }
    }

  return result;
}

#define DO_FIXED_MAT_FUNC(FUNC, MT) \
  MT FUNC (const FixedComplexMatrix& x) \
  {  \
    MT retval ( x.rows(), x.cols()); \
    for (int j = 0; j < x.cols(); j++) \
      for (int i = 0; i < x.rows(); i++) \
        retval(i,j) = FUNC ( x (i,j) ); \
    return retval; \
  }

DO_FIXED_MAT_FUNC(real, FixedMatrix);
DO_FIXED_MAT_FUNC(imag, FixedMatrix);
DO_FIXED_MAT_FUNC(conj, FixedComplexMatrix);
DO_FIXED_MAT_FUNC(abs, FixedMatrix);
DO_FIXED_MAT_FUNC(norm, FixedMatrix);
DO_FIXED_MAT_FUNC(arg, FixedMatrix);
DO_FIXED_MAT_FUNC(cos, FixedComplexMatrix);
DO_FIXED_MAT_FUNC(cosh, FixedComplexMatrix);
DO_FIXED_MAT_FUNC(sin, FixedComplexMatrix);
DO_FIXED_MAT_FUNC(sinh, FixedComplexMatrix);
DO_FIXED_MAT_FUNC(tan, FixedComplexMatrix);
DO_FIXED_MAT_FUNC(tanh, FixedComplexMatrix);
DO_FIXED_MAT_FUNC(sqrt, FixedComplexMatrix);
DO_FIXED_MAT_FUNC(exp, FixedComplexMatrix);
DO_FIXED_MAT_FUNC(log, FixedComplexMatrix);
DO_FIXED_MAT_FUNC(log10, FixedComplexMatrix);
DO_FIXED_MAT_FUNC(round, FixedComplexMatrix);
DO_FIXED_MAT_FUNC(rint, FixedComplexMatrix);
DO_FIXED_MAT_FUNC(floor, FixedComplexMatrix);
DO_FIXED_MAT_FUNC(ceil, FixedComplexMatrix);

FixedComplexMatrix polar (const FixedMatrix &r, const FixedMatrix &p)
{
  if ((r.rows() != p.rows()) || (r.cols() != p.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return FixedComplexMatrix();
  }

  FixedComplexMatrix retval ( r.rows(), r.cols());
    for (int j = 0; j < r.cols(); j++)
      for (int i = 0; i < r.rows(); i++)
        retval(i,j) = polar ( r (i,j), p (i,j) );
    return retval;
}

FixedComplexMatrix elem_pow (const FixedComplexMatrix &a, const FixedComplexMatrix &b)
{
  FixedComplexMatrix retval;
  int a_nr = a.rows ();
  int a_nc = a.cols ();
  int b_nr = b.rows ();
  int b_nc = b.cols ();

  if (a_nr == 1 && a_nc == 1)
    {
      retval.resize(b_nr,b_nc);
      FixedPointComplex ad = a(0,0);
      for (int j = 0; j < b_nc; j++)
	for (int i = 0; i < b_nr; i++)
	  retval(i,j) = pow(ad, b(i,j));
    }
  else if (b_nr == 1 && b_nc == 1)
    {
      retval.resize(a_nr,a_nc);
      FixedPointComplex bd = b(0,0);
      for (int j = 0; j < a_nc; j++)
	for (int i = 0; i < a_nr; i++)
	  retval(i,j) = pow(a(i,j), bd);
    }
  else if ((a_nr == b_nr) && (a_nc == b_nc))
    {
      retval.resize(a_nr,a_nc);
      for (int j = 0; j < a_nc; j++)
	for (int i = 0; i < a_nr; i++)
	  retval(i,j) = pow(a(i,j), b(i,j));
    }
  else
    gripe_nonconformant ("operator .^", a_nr, a_nc, a_nr, a_nc);

  return retval;
}

FixedComplexMatrix elem_pow (const FixedComplexMatrix &a, const FixedPointComplex &b)
{
  return elem_pow (a, FixedComplexMatrix(1, 1, b));
}

FixedComplexMatrix elem_pow (const FixedPointComplex &a, const FixedComplexMatrix &b)
{
  return elem_pow (FixedComplexMatrix(1, 1, a), b);
}

FixedComplexMatrix pow (const FixedComplexMatrix& a, int b)
{
  FixedComplexMatrix retval;
  int nr = a.rows ();
  int nc = a.cols ();

  if (nr == 0 || nc == 0 || nr != nc)
    (*current_liboctave_error_handler)
      ("for A^x, A must be square and x a real scalar");
  else if (b == 0) 
    {
      retval = a;
      FixedPointComplex one(1, 0, Complex(1, 0));
      for (int j = 0; j < nc; j++)
	for (int i = 0; i < nr; i++)
	  retval(i,j) = 
            FixedPointComplex(a(i,j).getintsize(), a(i,j).getdecsize(), one);
    }
  else
    {
      if (b < 0 ) 
	(*current_liboctave_error_handler)
	  ("can not treat matrix inversion");

      FixedComplexMatrix atmp (a);
      retval = atmp;
      b--;
      while (b > 0)
	{
	  if (b & 1)
	    retval = retval * atmp;

	  b >>= 1;

	  if (b > 0)
	    atmp = atmp * atmp;
	}
    }
  return retval;
}

FixedComplexMatrix pow  (const FixedComplexMatrix &a, const double b)
{
  int bi = (int)b;
  if ((double)bi != b) {
    (*current_liboctave_error_handler)
      ("can only treat integer powers of a matrix");
    return FixedComplexMatrix();
  }

  return pow(a, bi);
}

FixedComplexMatrix pow  (const FixedComplexMatrix &a, 
			 const FixedPointComplex &b)
{
  if (a.rows() == 0 || a.rows() == 0 || a.rows() != a.rows() || 
      b.imag() != FixedPoint()) {
    (*current_liboctave_error_handler)
      ("for A^x, A must be square and x a real scalar");
    return FixedComplexMatrix();
  } else
    return pow(a, b.real().fixedpoint());
}

FixedComplexMatrix pow  (const FixedComplexMatrix &a, const FixedComplexMatrix &b)
{
  if (a.rows() == 0 || a.rows() == 0 || a.rows() != a.rows() || 
      b.rows() != 1 || b.cols() != 1 || b(0,0).imag() != FixedPoint()) {
    (*current_liboctave_error_handler)
      ("for A^x, A must be square and x a real scalar");
    return FixedComplexMatrix();
  } else
    return pow(a, b(0,0).real().fixedpoint());
}

// Return true if no elements have imaginary components.

bool
FixedComplexMatrix::all_elements_are_real (void) const
{
  int nr = rows ();
  int nc = cols ();
  FixedPoint zero;

  for (int j = 0; j < nc; j++)
    {
      for (int i = 0; i < nr; i++)
	{
	  FixedPoint ip = imag (elem (i, j));

	  if (ip != zero || ip.signbit())
	    return false;
	}
    }

  return true;
}

bool
FixedComplexMatrix::is_hermitian (void) const
{
  int nr = rows ();
  int nc = cols ();

  if (is_square () && nr > 0)
    {
      for (int i = 0; i < nr; i++)
	for (int j = i; j < nc; j++)
	  if (elem (i, j) != conj (elem (j, i)))
	    return false;

      return true;
    }

  return false;
}

FixedComplexMatrix
FixedComplexMatrix::hermitian (void) const
{
  int nr = rows ();
  int nc = cols ();
  FixedComplexMatrix result;
  if (length () > 0)
    {
      result.resize (nc, nr);
      for (int j = 0; j < nc; j++)
	for (int i = 0; i < nr; i++)
	  result.elem (j, i) = conj (elem (i, j));
    }
  return result;
}

std::ostream&
operator << (std::ostream& os, const FixedComplexMatrix& a)
{
  for (int i = 0; i < a.rows (); i++)
    {
      for (int j = 0; j < a.cols (); j++)
	{
	  os << " " << a.elem(i,j);
	}
      os << "\n";
    }
  return os;
}

std::istream&
operator >> (std::istream& is, FixedComplexMatrix& a)
{
  int nr = a.rows ();
  int nc = a.cols ();

  if (nr < 1 || nc < 1)
    is.clear (std::ios::badbit);
  else
    {
      FixedPointComplex tmp;
      for (int i = 0; i < nr; i++)
	for (int j = 0; j < nc; j++)
	  {
	    is >> tmp;
	    if (is)
	      a.elem (i, j) = tmp;
	    else
	      goto done;
	  }
    }

 done:

  return is;
}

FixedComplexMatrix
operator * (const FixedComplexMatrix& a, const FixedComplexMatrix& b)
{
  FixedComplexMatrix retval;

  int a_nr = a.rows ();
  int a_nc = a.cols ();

  int b_nr = b.rows ();
  int b_nc = b.cols ();

  if (a_nc != b_nr)
    gripe_nonconformant ("operator *", a_nr, a_nc, b_nr, b_nc);
  else
    {
      retval.resize (a_nr, b_nc, FixedPointComplex());
      if (a_nr != 0 && a_nc != 0 && b_nc != 0)
	{
	  for (int j = 0; j <  b_nr; j++) 
	    for (int i = 0; i <  b_nc; i++) {
	      FixedPointComplex tmp = b.elem(j,i);
	      for (int k = 0; k <  a_nr; k++)
		retval.elem (k,i) += a.elem(k,j) * tmp;  
	    }
	}
    }

  return retval;
}

// XXX FIXME XXX -- it would be nice to share code among the min/max
// functions below.

#define EMPTY_RETURN_CHECK(T) \
  if (nr == 0 || nc == 0) \
    return T (nr, nc);

FixedComplexMatrix
min (FixedPointComplex d, const FixedComplexMatrix& m)
{
  int nr = m.rows ();
  int nc = m.columns ();
  FixedPoint dabs = ::abs(d);

  EMPTY_RETURN_CHECK (FixedComplexMatrix);

  FixedComplexMatrix result (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      {
	OCTAVE_QUIT;
	result (i, j) = ::abs(m(i,j)) < dabs ? m(i,j) : d;
      }

  return result;
}

FixedComplexMatrix
min (const FixedComplexMatrix& m, FixedPointComplex d)
{
  int nr = m.rows ();
  int nc = m.columns ();
  FixedPoint dabs = ::abs(d);

  EMPTY_RETURN_CHECK (FixedComplexMatrix);

  FixedComplexMatrix result (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      {
	OCTAVE_QUIT;
	result (i, j) = ::abs(m(i,j)) < dabs ? m(i,j) : d;
      }

  return result;
}

FixedComplexMatrix
min (const FixedComplexMatrix& a, const FixedComplexMatrix& b)
{
  int nr = a.rows ();
  int nc = a.columns ();

  if (nr != b.rows () || nc != b.columns ())
    {
      (*current_liboctave_error_handler)
	("two-arg min expecting args of same size");
      return FixedComplexMatrix ();
    }

  EMPTY_RETURN_CHECK (FixedComplexMatrix);

  FixedComplexMatrix result (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      {
	OCTAVE_QUIT;
	result (i, j) = ::abs(a(i,j)) < ::abs(b(i,j)) ? a(i,j) : b(i,j);

      }

  return result;
}

FixedComplexMatrix
max (FixedPointComplex d, const FixedComplexMatrix& m)
{
  int nr = m.rows ();
  int nc = m.columns ();
  FixedPoint dabs = ::abs(d);

  EMPTY_RETURN_CHECK (FixedComplexMatrix);

  FixedComplexMatrix result (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      {
	OCTAVE_QUIT;
	result (i, j) = ::abs(m(i,j)) > dabs ? m(i,j) : d;
      }

  return result;
}

FixedComplexMatrix
max (const FixedComplexMatrix& m, FixedPointComplex d)
{
  int nr = m.rows ();
  int nc = m.columns ();
  FixedPoint dabs = ::abs(d);

  EMPTY_RETURN_CHECK (FixedComplexMatrix);

  FixedComplexMatrix result (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      {
	OCTAVE_QUIT;
	result (i, j) = ::abs(m(i,j)) > dabs ? m(i,j) : d;
      }

  return result;
}

FixedComplexMatrix
max (const FixedComplexMatrix& a, const FixedComplexMatrix& b)
{
  int nr = a.rows ();
  int nc = a.columns ();

  if (nr != b.rows () || nc != b.columns ())
    {
      (*current_liboctave_error_handler)
	("two-arg max expecting args of same size");
      return FixedComplexMatrix ();
    }

  EMPTY_RETURN_CHECK (FixedComplexMatrix);

  FixedComplexMatrix result (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      {
	OCTAVE_QUIT;
	result (i, j) = ::abs(a(i,j)) > ::abs(b(i,j)) ? a(i,j) : b(i,j);
      }

  return result;
}

MS_CMP_OPS(FixedComplexMatrix, real, FixedPointComplex, real)
MS_BOOL_OPS(FixedComplexMatrix, FixedPointComplex, FixedPointComplex())

SM_CMP_OPS(FixedPointComplex, real, FixedComplexMatrix, real)
SM_BOOL_OPS(FixedPointComplex, FixedComplexMatrix, FixedPointComplex())

MM_CMP_OPS(FixedComplexMatrix, real, FixedComplexMatrix, real)
MM_BOOL_OPS(FixedComplexMatrix, FixedComplexMatrix, FixedPointComplex())

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
