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
#include <octave/gripes.h>
#include <octave/ops.h>
#include <octave/quit.h>

#include "fixedColVector.h"
#include "fixedRowVector.h"
#include "fixedMatrix.h"
#include "fixedCMatrix.h"

// Fixed Point Matrix class.

FixedMatrix::FixedMatrix (const MArray2<int> &is, const MArray2<int> &ds)
  : MArray2<FixedPoint> (is.rows(), is.cols())
{
  if ((rows() != ds.rows()) || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPoint((unsigned int)is(i,j), (unsigned int)ds(i,j));
}


FixedMatrix::FixedMatrix (const Matrix &is, const Matrix &ds)
  : MArray2<FixedPoint> (is.rows(), is.cols())
{
  if ((rows() != ds.rows()) || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPoint((unsigned int)is(i,j), (unsigned int)ds(i,j));
}

FixedMatrix::FixedMatrix (const MArray2<int> &is, const MArray2<int> &ds, 
			  const FixedMatrix& a)
  : MArray2<FixedPoint> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPoint((unsigned int)is(i,j), (unsigned int)ds(i,j), 
			       a.elem (i, j));
}

FixedMatrix::FixedMatrix (const Matrix &is, const Matrix &ds, 
			  const FixedMatrix& a)
  : MArray2<FixedPoint> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPoint((unsigned int)is(i,j), (unsigned int)ds(i,j), 
			       a.elem (i, j));
}

FixedMatrix::FixedMatrix (unsigned int is, unsigned int ds, 
			  const FixedMatrix& a)
  : MArray2<FixedPoint> (a.rows(), a.cols())
{
  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPoint(is, ds, a.elem (i, j));
}

FixedMatrix::FixedMatrix (const MArray2<int> &is, const MArray2<int> &ds, 
			  const Matrix& a)
  : MArray2<FixedPoint> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPoint((unsigned int)is(i,j), (unsigned int)ds(i,j), 
			       a.elem (i, j));
}

FixedMatrix::FixedMatrix (const Matrix &is, const Matrix &ds, 
			  const Matrix& a)
  : MArray2<FixedPoint> (a.rows(), a.cols())
{
  if ((rows() != is.rows()) || (cols() != is.cols()) || (rows() != ds.rows())
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPoint((unsigned int)is(i,j), (unsigned int)ds(i,j), 
			       a.elem (i, j));
}

FixedMatrix::FixedMatrix (unsigned int is, unsigned int ds, const Matrix& a)
  : MArray2<FixedPoint> (a.rows(), a.cols())
{
  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPoint(is, ds, a.elem (i, j));
}

FixedMatrix::FixedMatrix (unsigned int is, unsigned int ds, const Matrix& a, 
			  const Matrix& b)
  : MArray2<FixedPoint> (a.rows(), a.cols())
{
  if ((rows() != b.rows()) || (cols() != b.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPoint(is, ds, (unsigned int)a.elem (i, j), 
			       (unsigned int)b.elem (i,j));
}

FixedMatrix::FixedMatrix (const MArray2<int> &is, const MArray2<int> &ds, 
			  const Matrix& a, const Matrix& b)
  : MArray2<FixedPoint> (a.rows(), a.cols())
{
  if ((rows() != b.rows()) || (cols() != b.cols()) || (rows() != is.rows())
      || (cols() != is.cols()) || (rows() != ds.rows()) 
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPoint((unsigned int)is(i,j), (unsigned int)ds(i,j), 
			       (unsigned int)a.elem (i, j), 
			       (unsigned int)b.elem (i,j));
}

FixedMatrix::FixedMatrix (const Matrix &is, const Matrix &ds, const Matrix& a,
			  const Matrix& b)
  : MArray2<FixedPoint> (a.rows(), a.cols())
{
  if ((rows() != b.rows()) || (cols() != b.cols()) || (rows() != is.rows())
      || (cols() != is.cols()) || (rows() != ds.rows()) 
      || (cols() != ds.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch");
    return;
  }

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPoint((unsigned int)is(i,j), (unsigned int)ds(i,j), 
			       (unsigned int)a.elem (i, j), 
			       (unsigned int)b.elem (i,j));
}

FixedMatrix::FixedMatrix (const MArray2<int> &a)
  : MArray2<FixedPoint> (a.rows(), a.cols())
{

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPoint(a.elem (i, j));
}

FixedMatrix::FixedMatrix (const Matrix &a)
  : MArray2<FixedPoint> (a.rows(), a.cols())
{

  for (int j = 0; j < cols (); j++)
    for (int i = 0; i < rows (); i++)
      elem (i, j) = FixedPoint(a.elem (i, j));
}

FixedMatrix::FixedMatrix (const FixedRowVector& rv)
  : MArray2<FixedPoint> (1, rv.length (), FixedPoint())
{
  for (int i = 0; i < rv.length (); i++)
    elem (0, i) = rv.elem (i);
}

FixedMatrix::FixedMatrix (const FixedColumnVector& cv)
  : MArray2<FixedPoint> (cv.length (), 1, FixedPoint())
{
  for (int i = 0; i < cv.length (); i++)
    elem (i, 0) = cv.elem (i);
}

#define GET_FIXED_PROP(METHOD) \
  Matrix \
  FixedMatrix:: METHOD (void) const \
    { \
      int nr = rows(); \
      int nc = cols(); \
      Matrix retval(nr,nc); \
      for (int i = 0; i < nr; i++) \
        for (int j = 0; j < nc; j++) \
          retval(i,j) = (double) elem(i,j) . METHOD (); \
      return retval; \
    } \

GET_FIXED_PROP(sign);
GET_FIXED_PROP(signbit);
GET_FIXED_PROP(getdecsize);
GET_FIXED_PROP(getintsize);
GET_FIXED_PROP(getnumber);
GET_FIXED_PROP(fixedpoint);

#undef GET_FIXED_PROP

FixedMatrix 
FixedMatrix::chdecsize (const double n)
{
  int nr = rows();
  int nc = cols();
  FixedMatrix retval(nr,nc);

  for (int i = 0; i < nr; i++)
    for (int j = 0; j < nc; j++)
      retval(i,j) = FixedPoint(elem(i,j).getintsize(), (int)n, elem(i,j));

  return retval;
}

FixedMatrix 
FixedMatrix::chdecsize (const Matrix &n)
{
  int nr = rows();
  int nc = cols();

  if ((nr != n.rows()) || (nc != n.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch in chdecsize");
    return FixedMatrix();
  }

  FixedMatrix retval(nr,nc);

  for (int i = 0; i < nr; i++)
    for (int j = 0; j < nc; j++)
      retval(i,j) = FixedPoint(elem(i,j).getintsize(), (int)n(i,j), elem(i,j));

  return retval;
}

FixedMatrix 
FixedMatrix::chintsize (const double n)
{
  int nr = rows();
  int nc = cols();
  FixedMatrix retval(nr,nc);

  for (int i = 0; i < nr; i++)
    for (int j = 0; j < nc; j++)
      retval(i,j) = FixedPoint((int)n, elem(i,j).getdecsize(), elem(i,j));

  return retval;
}

FixedMatrix 
FixedMatrix::chintsize (const Matrix &n)
{
  int nr = rows();
  int nc = cols();

  if ((nr != n.rows()) || (nc != n.cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch in chintsize");
    return FixedMatrix();
  }

  FixedMatrix retval(nr,nc);

  for (int i = 0; i < nr; i++)
    for (int j = 0; j < nc; j++)
      retval(i,j) = FixedPoint((int)n(i,j), elem(i,j).getdecsize(), elem(i,j));

  return retval;
}

FixedMatrix 
FixedMatrix::incdecsize (const double n) {
  return chdecsize(n + getdecsize());
}

FixedMatrix
FixedMatrix::incdecsize (const Matrix &n) {
  if ((n.rows() != rows()) || (n.cols() != cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch in chintsize");
    return FixedMatrix();
  }
  return chdecsize(n + getdecsize());
}

FixedMatrix 
FixedMatrix::incdecsize () {
  return chdecsize(1 + getdecsize());
}

FixedMatrix 
FixedMatrix::incintsize (const double n) {
  return chintsize(n + getintsize());
}

FixedMatrix
FixedMatrix::incintsize (const Matrix &n) {
  if ((n.rows() != rows()) || (n.cols() != cols())) {
    (*current_liboctave_error_handler) ("matrix size mismatch in chintsize");
    return FixedMatrix();
  }
  return chintsize(n + getintsize());
}

FixedMatrix 
FixedMatrix::incintsize () {
  return chintsize(1 + getintsize());
}

bool
FixedMatrix::operator == (const FixedMatrix& a) const
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
FixedMatrix::operator != (const FixedMatrix& a) const
{
  return !(*this == a);
}

bool
FixedMatrix::is_symmetric (void) const
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

FixedMatrix 
FixedMatrix::concat (const FixedMatrix& rb, const Array<int>& ra_idx)
{
  if (rb.numel() > 0)
    insert (rb, ra_idx(0), ra_idx(1));
  return *this;
}

FixedComplexMatrix 
FixedMatrix::concat (const FixedComplexMatrix& rb, const Array<int>& ra_idx)
{
  FixedComplexMatrix retval (*this);
  if (rb.numel() > 0)
    retval.insert (rb, ra_idx(0), ra_idx(1));
  return retval;
}

FixedMatrix&
FixedMatrix::insert (const FixedMatrix& a, int r, int c)
{
  Array2<FixedPoint>::insert (a, r, c);
  return *this;
}

FixedMatrix&
FixedMatrix::insert (const FixedRowVector& a, int r, int c)
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

FixedMatrix&
FixedMatrix::insert (const FixedColumnVector& a, int r, int c)
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

FixedMatrix&
FixedMatrix::fill (FixedPoint val)
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

FixedMatrix&
FixedMatrix::fill (FixedPoint val, int r1, int c1, int r2, int c2)
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

FixedMatrix
FixedMatrix::append (const FixedMatrix& a) const
{
  int nr = rows ();
  int nc = cols ();
  if (nr != a.rows ())
    {
      (*current_liboctave_error_handler) ("row dimension mismatch for append");
      return FixedMatrix ();
    }

  int nc_insert = nc;
  FixedMatrix retval (nr, nc + a.cols ());
  retval.insert (*this, 0, 0);
  retval.insert (a, 0, nc_insert);
  return retval;
}

FixedMatrix
FixedMatrix::append (const FixedRowVector& a) const
{
  int nr = rows ();
  int nc = cols ();
  if (nr != 1)
    {
      (*current_liboctave_error_handler) ("row dimension mismatch for append");
      return FixedMatrix ();
    }

  int nc_insert = nc;
  FixedMatrix retval (nr, nc + a.length ());
  retval.insert (*this, 0, 0);
  retval.insert (a, 0, nc_insert);
  return retval;
}

FixedMatrix
FixedMatrix::append (const FixedColumnVector& a) const
{
  int nr = rows ();
  int nc = cols ();
  if (nr != a.length ())
    {
      (*current_liboctave_error_handler) ("row dimension mismatch for append");
      return FixedMatrix ();
    }

  int nc_insert = nc;
  FixedMatrix retval (nr, nc + 1);
  retval.insert (*this, 0, 0);
  retval.insert (a, 0, nc_insert);
  return retval;
}

FixedMatrix
FixedMatrix::stack (const FixedMatrix& a) const
{
  int nr = rows ();
  int nc = cols ();
  if (nc != a.cols ())
    {
      (*current_liboctave_error_handler)
	("column dimension mismatch for stack");
      return FixedMatrix ();
    }

  int nr_insert = nr;
  FixedMatrix retval (nr + a.rows (), nc);
  retval.insert (*this, 0, 0);
  retval.insert (a, nr_insert, 0);
  return retval;
}

FixedMatrix
FixedMatrix::stack (const FixedRowVector& a) const
{
  int nr = rows ();
  int nc = cols ();
  if (nc != a.length ())
    {
      (*current_liboctave_error_handler)
	("column dimension mismatch for stack");
      return FixedMatrix ();
    }

  int nr_insert = nr;
  FixedMatrix retval (nr + 1, nc);
  retval.insert (*this, 0, 0);
  retval.insert (a, nr_insert, 0);
  return retval;
}

FixedMatrix
FixedMatrix::stack (const FixedColumnVector& a) const
{
  int nr = rows ();
  int nc = cols ();
  if (nc != 1)
    {
      (*current_liboctave_error_handler)
	("column dimension mismatch for stack");
      return FixedMatrix ();
    }

  int nr_insert = nr;
  FixedMatrix retval (nr + a.length (), nc);
  retval.insert (*this, 0, 0);
  retval.insert (a, nr_insert, 0);
  return retval;
}

FixedMatrix
FixedMatrix::extract (int r1, int c1, int r2, int c2) const
{
  if (r1 > r2) { int tmp = r1; r1 = r2; r2 = tmp; }
  if (c1 > c2) { int tmp = c1; c1 = c2; c2 = tmp; }

  int new_r = r2 - r1 + 1;
  int new_c = c2 - c1 + 1;

  FixedMatrix result (new_r, new_c);

  for (int j = 0; j < new_c; j++)
    for (int i = 0; i < new_r; i++)
      result.xelem (i, j) = elem (r1+i, c1+j);

  return result;
}

FixedMatrix
FixedMatrix::extract_n (int r1, int c1, int nr, int nc) const
{
  FixedMatrix result (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      result.xelem (i, j) = elem (r1+i, c1+j);

  return result;
}

// extract row or column i.

FixedRowVector
FixedMatrix::row (int i) const
{
  int nc = cols ();
  if (i < 0 || i >= rows ())
    {
      (*current_liboctave_error_handler) ("invalid row selection");
      return FixedRowVector ();
    }

  FixedRowVector retval (nc);
  for (int j = 0; j < nc; j++)
    retval.xelem (j) = elem (i, j);

  return retval;
}

FixedRowVector
FixedMatrix::row (char *s) const
{
  if (! s)
    {
      (*current_liboctave_error_handler) ("invalid row selection");
      return FixedRowVector ();
    }

  char c = *s;
  if (c == 'f' || c == 'F')
    return row (0);
  else if (c == 'l' || c == 'L')
    return row (rows () - 1);
  else
    {
      (*current_liboctave_error_handler) ("invalid row selection");
      return FixedRowVector ();
    }
}

FixedColumnVector
FixedMatrix::column (int i) const
{
  int nr = rows ();
  if (i < 0 || i >= cols ())
    {
      (*current_liboctave_error_handler) ("invalid column selection");
      return FixedColumnVector ();
    }

  FixedColumnVector retval (nr);
  for (int j = 0; j < nr; j++)
    retval.xelem (j) = elem (j, i);

  return retval;
}

FixedColumnVector
FixedMatrix::column (char *s) const
{
  if (! s)
    {
      (*current_liboctave_error_handler) ("invalid column selection");
      return FixedColumnVector ();
    }

  char c = *s;
  if (c == 'f' || c == 'F')
    return column (0);
  else if (c == 'l' || c == 'L')
    return column (cols () - 1);
  else
    {
      (*current_liboctave_error_handler) ("invalid column selection");
      return FixedColumnVector ();
    }
}

// unary operations

FixedMatrix
FixedMatrix::operator ! (void) const
{
  int nr = rows ();
  int nc = cols ();

  FixedMatrix b (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      b.elem (i, j) =  ! elem (i, j) ;

  return b;
}

// column vector by row vector -> matrix operations

FixedMatrix
operator * (const FixedColumnVector& v, const FixedRowVector& a)
{
  FixedMatrix retval;

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

FixedMatrix
FixedMatrix::map (f_f_Mapper f) const
{
  FixedMatrix b (*this);
  return b.apply (f);
}

FixedMatrix&
FixedMatrix::apply (f_f_Mapper f)
{
  FixedPoint *d = fortran_vec (); // Ensures only one reference to my privates!

  for (int i = 0; i < length (); i++)
    d[i] = f (d[i]);

  return *this;
}

boolMatrix
FixedMatrix::all (int dim) const
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
FixedMatrix::any (int dim) const
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

FixedMatrix
FixedMatrix::cumprod (int dim) const
{
  MX_CUMULATIVE_OP (FixedMatrix, FixedPoint, *=);
}

FixedMatrix
FixedMatrix::cumsum (int dim) const
{
  MX_CUMULATIVE_OP (FixedMatrix, FixedPoint, +=);
}

FixedMatrix
FixedMatrix::prod (int dim) const
{
  FixedPoint one(1,0,1,0);
  MX_REDUCTION_OP (FixedMatrix, *=, one, one);
}

FixedMatrix
FixedMatrix::sum (int dim) const
{
  FixedPoint zero;
  MX_REDUCTION_OP (FixedMatrix, +=, zero, zero);
}

FixedMatrix
FixedMatrix::sumsq (int dim) const
{
  FixedPoint zero;
#define ROW_EXPR \
  FixedPoint d = elem (i, j); \
  retval.elem (i, 0) += d * d

#define COL_EXPR \
  FixedPoint d = elem (i, j); \
  retval.elem (0, j) += d * d

  MX_BASE_REDUCTION_OP (FixedMatrix, ROW_EXPR, COL_EXPR, zero, zero);

#undef ROW_EXPR
#undef COL_EXPR
}

FixedMatrix
FixedMatrix::abs (void) const
{
  int nr = rows ();
  int nc = cols ();

  FixedMatrix retval (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      retval (i, j) = ::abs(elem (i, j));

  return retval;
}

FixedColumnVector
FixedMatrix::diag (void) const
{
  return diag (0);
}

FixedColumnVector
FixedMatrix::diag (int k) const
{
  int nnr = rows ();
  int nnc = cols ();
  if (k > 0)
    nnc -= k;
  else if (k < 0)
    nnr += k;

  FixedColumnVector d;

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

FixedColumnVector
FixedMatrix::row_min (void) const
{
  Array<int> index;
  return row_min (index);
}

FixedColumnVector
FixedMatrix::row_min (Array<int>& index) const
{
  FixedColumnVector result;

  int nr = rows ();
  int nc = cols ();

  if (nr > 0 && nc > 0)
    {
      result.resize (nr);
      index.resize (nr);

      for (int i = 0; i < nr; i++)
        {
	  int idx_j = 0;

	  FixedPoint tmp_min = elem (i, idx_j);

	  for (int j = 1; j < nc; j++)
	    {
	      FixedPoint tmp = elem (i, j);
	      if (tmp < tmp_min)
		{
		  idx_j = j;
		  tmp_min = tmp;
		}
	    }
	  
	  result.elem (i) = tmp_min;
	  index.elem (i) = idx_j;
        }
    }
  
  return result;
}

FixedColumnVector
FixedMatrix::row_max (void) const
{
  Array<int> index;
  return row_max (index);
}

FixedColumnVector
FixedMatrix::row_max (Array<int>& index) const
{
  FixedColumnVector result;

  int nr = rows ();
  int nc = cols ();

  if (nr > 0 && nc > 0)
    {
      result.resize (nr);
      index.resize (nr);

      for (int i = 0; i < nr; i++)
        {
	  int idx_j = 0;

	  FixedPoint tmp_max = elem (i, idx_j);

	  for (int j = 1; j < nc; j++)
	    {
	      FixedPoint tmp = elem (i, j);
	      if (tmp > tmp_max)
		{
		  idx_j = j;
		  tmp_max = tmp;
		}
	    }

	  result.elem (i) = tmp_max;
	  index.elem (i) = idx_j;
        }
    }

  return result;
}

FixedRowVector
FixedMatrix::column_min (void) const
{
  Array<int> index;
  return column_min (index);
}

FixedRowVector
FixedMatrix::column_min (Array<int>& index) const
{
  FixedRowVector result;

  int nr = rows ();
  int nc = cols ();

  if (nr > 0 && nc > 0)
    {
      result.resize (nc);
      index.resize (nc);

      for (int j = 0; j < nc; j++)
        {
	  int idx_i = 0;

	  FixedPoint tmp_min = elem (idx_i, j);

	  for (int i = 1; i < nr; i++)
	    {
	      FixedPoint tmp = elem (i, j);
	      if (tmp < tmp_min)
		{
		  idx_i = i;
		  tmp_min = tmp;
		}
	    }

	  result.elem (j) = tmp_min;
	  index.elem (j) = idx_i;
        }
    }

  return result;
}

FixedRowVector
FixedMatrix::column_max (void) const
{
  Array<int> index;
  return column_max (index);
}

FixedRowVector
FixedMatrix::column_max (Array<int>& index) const
{
  FixedRowVector result;

  int nr = rows ();
  int nc = cols ();

  if (nr > 0 && nc > 0)
    {
      result.resize (nc);
      index.resize (nc);

      for (int j = 0; j < nc; j++)
        {
	  int idx_i = 0;

	  FixedPoint tmp_max = elem (idx_i, j);

	  for (int i = 1; i < nr; i++)
	    {
	      FixedPoint tmp = elem (i, j);

	      if (tmp > tmp_max)
		{
		  idx_i = i;
		  tmp_max = tmp;
		}
	    }

	  result.elem (j) = tmp_max;
	  index.elem (j) = idx_i;
        }
    }

  return result;
}

#define DO_FIXED_MAT_FUNC(FUNC) \
  FixedMatrix FUNC (const FixedMatrix& x) \
  {  \
    FixedMatrix retval ( x.rows(), x.cols()); \
    for (int j = 0; j < x.cols(); j++) \
      for (int i = 0; i < x.rows(); i++) \
        retval(i,j) = FUNC ( x (i,j) ); \
    return retval; \
  }

DO_FIXED_MAT_FUNC(real);
DO_FIXED_MAT_FUNC(imag);
DO_FIXED_MAT_FUNC(conj);
DO_FIXED_MAT_FUNC(abs);
DO_FIXED_MAT_FUNC(cos);
DO_FIXED_MAT_FUNC(cosh);
DO_FIXED_MAT_FUNC(sin);
DO_FIXED_MAT_FUNC(sinh);
DO_FIXED_MAT_FUNC(tan);
DO_FIXED_MAT_FUNC(tanh);
DO_FIXED_MAT_FUNC(sqrt);
DO_FIXED_MAT_FUNC(exp);
DO_FIXED_MAT_FUNC(log);
DO_FIXED_MAT_FUNC(log10);
DO_FIXED_MAT_FUNC(round);
DO_FIXED_MAT_FUNC(rint);
DO_FIXED_MAT_FUNC(floor);
DO_FIXED_MAT_FUNC(ceil);

FixedMatrix elem_pow (const FixedMatrix &a, const FixedMatrix &b)
{
  FixedMatrix retval;
  int a_nr = a.rows ();
  int a_nc = a.cols ();
  int b_nr = b.rows ();
  int b_nc = b.cols ();

  if (a_nr == 1 && a_nc == 1)
    {
      retval.resize(b_nr,b_nc);
      FixedPoint ad = a(0,0);
      for (int j = 0; j < b_nc; j++)
	for (int i = 0; i < b_nr; i++)
	  retval(i,j) = pow(ad, b(i,j));
    }
  else if (b_nr == 1 && b_nc == 1)
    {
      retval.resize(a_nr,a_nc);
      FixedPoint bd = b(0,0);
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

FixedMatrix elem_pow (const FixedMatrix &a, const FixedPoint &b)
{
  return elem_pow (a, FixedMatrix(1, 1, b));
}

FixedMatrix elem_pow (const FixedPoint &a, const FixedMatrix &b)
{
  return elem_pow (FixedMatrix(1, 1, a), b);
}

FixedMatrix pow (const FixedMatrix& a, int b)
{
  FixedMatrix retval;
  int nr = a.rows ();
  int nc = a.cols ();

  if (nr == 0 || nc == 0 || nr != nc)
    (*current_liboctave_error_handler)
      ("for A^x, A must be square and x scalar");
  else if (b == 0) 
    {
      retval = a;
      for (int j = 0; j < nc; j++)
	for (int i = 0; i < nr; i++)
	  retval(i,j) =
            FixedPoint(a(i,j).getintsize(), a(i,j).getdecsize(), 1, 0);
    }
  else
    {
      if (b < 0 ) 
	(*current_liboctave_error_handler)
	  ("can not treat matrix inversion");

      FixedMatrix atmp (a);
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

FixedMatrix pow  (const FixedMatrix &a, const double b)
{
  int bi = (int)b;
  if ((double)bi != b) {
    (*current_liboctave_error_handler)
      ("can only treat integer powers of a matrix");
    return FixedMatrix();
  }

  return pow(a, bi);
}

FixedMatrix pow  (const FixedMatrix &a, const FixedPoint &b)
{
  return pow(a, b.fixedpoint());
}

FixedMatrix pow  (const FixedMatrix &a, const FixedMatrix &b)
{
  if (a.rows() == 0 || a.rows() == 0 || a.rows() != a.rows() || 
      b.rows() != 1 || b.cols() != 1) {
    (*current_liboctave_error_handler)
      ("for A^x, A must be square and x scalar");
    return FixedMatrix();
  } else
    return pow(a, b(0,0).fixedpoint());
}

FixedMatrix atan2 (const FixedMatrix &x, const FixedMatrix &y)
{
  FixedMatrix retval;
  if ((x.rows() == y.rows()) && (x.cols() == y.cols())) {
    retval.resize(x.rows(),x.cols());
    for (int j = 0; j < x.cols(); j++)
      for (int i = 0; i < x.rows(); i++)
	retval(i,j) = atan2 ( x(i,j), y(i,j));
  } else
    (*current_liboctave_error_handler) ("matrix size mismatch");
  return retval;
}

std::ostream&
operator << (std::ostream& os, const FixedMatrix& a)
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
operator >> (std::istream& is, FixedMatrix& a)
{
  int nr = a.rows ();
  int nc = a.cols ();

  if (nr < 1 || nc < 1)
    is.clear (std::ios::badbit);
  else
    {
      FixedPoint tmp;
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

FixedMatrix
operator * (const FixedMatrix& a, const FixedMatrix& b)
{
  FixedMatrix retval;

  int a_nr = a.rows ();
  int a_nc = a.cols ();

  int b_nr = b.rows ();
  int b_nc = b.cols ();

  if (a_nc != b_nr)
    gripe_nonconformant ("operator *", a_nr, a_nc, b_nr, b_nc);
  else
    {
      retval.resize (a_nr, b_nc, FixedPoint());
      if (a_nr != 0 && a_nc != 0 && b_nc != 0)
	{
	  for (int j = 0; j <  b_nr; j++) 
	    for (int i = 0; i <  b_nc; i++) {
	      FixedPoint tmp = b.elem(j,i);
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

FixedMatrix
min (FixedPoint d, const FixedMatrix& m)
{
  int nr = m.rows ();
  int nc = m.columns ();

  EMPTY_RETURN_CHECK (FixedMatrix);

  FixedMatrix result (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      {
	OCTAVE_QUIT;
	result (i, j) = m(i,j) < d ? m(i,j) : d;
      }

  return result;
}

FixedMatrix
min (const FixedMatrix& m, FixedPoint d)
{
  int nr = m.rows ();
  int nc = m.columns ();

  EMPTY_RETURN_CHECK (FixedMatrix);

  FixedMatrix result (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      {
	OCTAVE_QUIT;
	result (i, j) = m(i,j) < d ? m(i,j) : d;
      }

  return result;
}

FixedMatrix
min (const FixedMatrix& a, const FixedMatrix& b)
{
  int nr = a.rows ();
  int nc = a.columns ();

  if (nr != b.rows () || nc != b.columns ())
    {
      (*current_liboctave_error_handler)
	("two-arg min expecting args of same size");
      return FixedMatrix ();
    }

  EMPTY_RETURN_CHECK (FixedMatrix);

  FixedMatrix result (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      {
	OCTAVE_QUIT;
	result (i, j) = a(i,j) < b(i,j) ? a(i,j) : b(i,j);
      }

  return result;
}

FixedMatrix
max (FixedPoint d, const FixedMatrix& m)
{
  int nr = m.rows ();
  int nc = m.columns ();

  EMPTY_RETURN_CHECK (FixedMatrix);

  FixedMatrix result (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      {
	OCTAVE_QUIT;
	result (i, j) = m(i,j) > d ? m(i,j) : d;
      }

  return result;
}

FixedMatrix
max (const FixedMatrix& m, FixedPoint d)
{
  int nr = m.rows ();
  int nc = m.columns ();

  EMPTY_RETURN_CHECK (FixedMatrix);

  FixedMatrix result (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      {
	OCTAVE_QUIT;
	result (i, j) = m(i,j) > d ? m(i,j) : d;
      }

  return result;
}

FixedMatrix
max (const FixedMatrix& a, const FixedMatrix& b)
{
  int nr = a.rows ();
  int nc = a.columns ();

  if (nr != b.rows () || nc != b.columns ())
    {
      (*current_liboctave_error_handler)
	("two-arg max expecting args of same size");
      return FixedMatrix ();
    }

  EMPTY_RETURN_CHECK (FixedMatrix);

  FixedMatrix result (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      {
	OCTAVE_QUIT;
	result (i, j) = a(i,j) > b(i,j) ? a(i,j) : b(i,j);
      }

  return result;
}

MS_CMP_OPS(FixedMatrix, , FixedPoint, )
MS_BOOL_OPS(FixedMatrix, FixedPoint, FixedPoint())

SM_CMP_OPS(FixedPoint, , FixedMatrix, )
SM_BOOL_OPS(FixedPoint, FixedMatrix, FixedPoint())

MM_CMP_OPS(FixedMatrix, , FixedMatrix, )
MM_BOOL_OPS(FixedMatrix, FixedMatrix, FixedPoint())

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
