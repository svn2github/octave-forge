/*

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

#if defined (__GNUG__) && defined (USE_PRAGMA_INTERFACE_IMPLEMENTATION)
#pragma implementation
#endif

#include <iostream>

#include "galois.h"
#include "galoisfield.h"
#include "galois-def.h"

galois_field_list stored_galois_fields;

// galois class

galois::galois (const MArray2<int>& a, const int& _m, const int& _primpoly) : MArray2<int> (a.rows(), a.cols()), field (NULL) {
  int _n = (1<<_m) - 1;

  // Check the validity of the data in the matrix
  for (int i=0; i<rows(); i++) {
    for (int j=0; j<columns(); j++) {
      if ((a(i,j) < 0) || (a(i,j) > _n)) {
	gripe_range_galois(_m);
	return;
      }
      if ((a(i,j) - (double)((int)a(i,j))) != 0.) {
	gripe_integer_galois();
	return;
      }
      elem(i,j) = (int)a(i,j);
    }
  }

  field = stored_galois_fields.create_galois_field(_m, _primpoly);
}

galois::galois (const Matrix& a, const int& _m, const int& _primpoly) : MArray2<int> (a.rows(), a.cols()), field (NULL) {
  int _n = (1<<_m) - 1;

  // Check the validity of the data in the matrix
  for (int i=0; i<rows(); i++) {
    for (int j=0; j<columns(); j++) {
      if ((a(i,j) < 0) || (a(i,j) > _n)) {
	gripe_range_galois(_m);
	return;
      }
      if ((a(i,j) - (double)((int)a(i,j))) != 0.) {
	gripe_integer_galois();
	return;
      }
      elem(i,j) = (int)a(i,j);
    }
  }

  field = stored_galois_fields.create_galois_field(_m, _primpoly);
}

galois::galois (int nr, int nc, const int& val, const int& _m, const int& _primpoly) : MArray2<int> (nr, nc, val), field (NULL) {
  int _n = (1<<_m) - 1;

  // Check the validity of the data in the matrix
  if ((val < 0) || (val > _n)) {
    gripe_range_galois(_m);
    return;
  }

  for (int i=0; i<rows(); i++)
    for (int j=0; j<columns(); j++)
      elem(i,j) = val;

  field = stored_galois_fields.create_galois_field(_m, _primpoly);
}

galois::galois (int nr, int nc, double val, const int& _m, const int& _primpoly) : MArray2<int> (nr, nc, (int)val), field (NULL) {
  int _n = (1<<_m) - 1;

  // Check the validity of the data in the matrix
  if ((val < 0) || (val > _n)) {
    gripe_range_galois(_m);
    return;
  }

  if ((val - (double)((int)val)) != 0.) {
    gripe_integer_galois();
    return;
  }

  for (int i=0; i<rows(); i++)
    for (int j=0; j<columns(); j++)
      elem(i,j) = (int)val;

  field = stored_galois_fields.create_galois_field(_m, _primpoly);
}

galois :: galois (const galois& a) :
  MArray2<int>(a) {

  if (!a.have_field()) {
    gripe_copy_invalid_galois();
    field = NULL;
    return;
  }

  // This call to create_galois_field will just increment the usage counter
  field = stored_galois_fields.create_galois_field(a.m(), a.primpoly());

}

galois :: ~galois (void)
{
  stored_galois_fields.delete_galois_field (field);
  field = NULL;
}

galois & galois::operator = (const galois& t)
{ 
  if (!t.have_field()) {
    gripe_copy_invalid_galois();
    if (have_field())
      stored_galois_fields.delete_galois_field (field);
    field = NULL;
    return *this;
  }

  if (have_field()) {
    if ((m() != t.m()) || (primpoly() != t.primpoly())) {
      gripe_differ_galois ();
      return *this;
    }
  } else 
    field = stored_galois_fields.create_galois_field(t.m(), t.primpoly());

  // Copy the data
  MArray2<int>::operator = (t);

  return *this;
}

galois&
galois::operator += (const galois& a)
{
  int nr = rows ();
  int nc = cols ();

  int a_nr = a.rows ();
  int a_nc = a.cols ();

  if (have_field() && a.have_field()) {
    if ((m() != a.m()) || (primpoly() != a.primpoly())) {
      gripe_differ_galois ();
      return *this;
    }
  } else {
    gripe_invalid_galois ();
    return *this;
  }

  if (nr != a_nr || nc != a_nc)
    {
      gripe_nonconformant ("operator +=", nr, nc, a_nr, a_nc);
      return *this;
    }

  for (int i = 0; i < a.length (); i++)
    elem (i, i) ^= a.elem (i, i);

  return *this;
}

galois&
galois::operator -= (const galois& a)
{
  int nr = rows ();
  int nc = cols ();

  int a_nr = a.rows ();
  int a_nc = a.cols ();

  if (have_field() && a.have_field()) {
    if ((m() != a.m()) || (primpoly() != a.primpoly())) {
      gripe_differ_galois ();
      return *this;
    }
  } else {
    gripe_invalid_galois ();
    return *this;
  }

  if (nr != a_nr || nc != a_nc)
    {
      gripe_nonconformant ("operator -=", nr, nc, a_nr, a_nc);
      return *this;
    }

  for (int i = 0; i < a.length (); i++)
    elem (i, i) ^= a.elem (i, i);

  return *this;
}

galois galois::index (idx_vector& i, int resize_ok, const int& rfv) const
{
  galois retval(MArray2<int>::index(i, resize_ok, rfv), m(), primpoly());

  return retval;
}

galois  galois::index (idx_vector& i, idx_vector& j, int resize_ok,
		   const int& rfv) const
{
  galois retval(MArray2<int>::index(i, j, resize_ok, rfv), m(), primpoly());

  return retval;
}

galois galois::diag (void) const
{
  return diag(0);
}

galois galois::diag (int k) const
{
  int nnr = rows ();
  int nnc = cols ();
  galois retval(0, 0, 0, m(), primpoly());

  if (k > 0)
    nnc -= k;
  else if (k < 0)
    nnr += k;

  if (nnr > 0 && nnc > 0)
    {
      int ndiag = (nnr < nnc) ? nnr : nnc;
      retval.resize(ndiag, 1);

      if (k > 0)
	{
	  for (int i = 0; i < ndiag; i++)
	    retval.elem (i,0) = elem (i, i+k);
	}
      else if ( k < 0)
	{
	  for (int i = 0; i < ndiag; i++)
	    retval.elem (i,0) = elem (i-k, i);
	}
      else
	{
	  for (int i = 0; i < ndiag; i++)
	    retval.elem (i,0) = elem (i, i);
	}
    }
  else 
    error("diag: requested diagonal out of range");

  return retval;
}

// unary operations

boolMatrix
galois::operator ! (void) const
{
  int nr = rows ();
  int nc = cols ();

  boolMatrix b (nr, nc);

  for (int j = 0; j < nc; j++)
    for (int i = 0; i < nr; i++)
      b.elem (i, j) = ! elem (i, j);

  return b;
}

galois
galois :: transpose (void) const
{
  galois a(Matrix(0,0), m(), primpoly());

  a.resize(d2,d1);
  for (int j = 0; j < d2; j++)
    for (int i = 0; i < d1; i++)
      a.xelem (j, i) = xelem (i, j);
  
  return a;
}

static inline int modn(int x, int m, int n)
{
  while (x >= n) {
    x -= n;
    x = (x >> m) + (x & n);
  }
  return x;
}

galois elem_pow (const galois& a, const galois& b)
{
  galois result(a);
  int a_nr = a.rows ();
  int a_nc = a.cols ();

  int b_nr = b.rows ();
  int b_nc = b.cols ();

  if (a.have_field() && b.have_field()) {
    if ((a.m() != b.m()) || (a.primpoly() != b.primpoly())) {
      gripe_differ_galois ();
      return galois ();
    }
  } else {
    gripe_invalid_galois ();
    return galois ();
  }

  if (a_nr == 1 && a_nc == 1)
    {
      result.resize(b_nr,b_nc);
      for (int j = 0; j < b_nc; j++)
	for (int i = 0; i < b_nr; i++)
	  if (b.elem(i,j) == 0)
	    result (i,j) = 1;
	  else if (a.elem(0,0) == 0)
	    result (i,j) = 0;
	  else
	    result (i,j) = a.alpha_to(modn(a.index_of(a.elem(0,0)) * 
					b.elem(i,j), a.m(),a.n()));
    }
  else if (b_nr == 1 && b_nc == 1)
    {
      for (int j = 0; j < a_nc; j++)
	for (int i = 0; i < a_nr; i++)
	  if (b.elem(0,0) == 0)
	    result (i,j) = 1;
	  else if (a.elem(i,j) == 0)
	    result (i,j) = 0;
	  else
	    result (i,j) = a.alpha_to(modn(a.index_of(a.elem(i,j)) * 
					 b.elem(0,0),a.m(),a.n()));
    }
  else 
    {
      if (a_nr != b_nr || a_nc != b_nc)
	{
	  gripe_nonconformant ("operator .^", a_nr, a_nc, a_nr, a_nc);
	  return galois ();
	}

      for (int j = 0; j < a_nc; j++)
	for (int i = 0; i < a_nr; i++)
	  if (b.elem(i,j) == 0)
	    result (i,j) = 1;
	  else if (a.elem(i,j) == 0)
	    result (i,j) = 0;
	  else
	    result (i,j) = a.alpha_to(modn(a.index_of(a.elem(i,j)) * 
					 b.elem(i,j),a.m(),a.n()));
    }

  return result;
}

galois elem_pow (const galois& a, const Matrix& b)
{
  galois result(a);
  int a_nr = a.rows ();
  int a_nc = a.cols ();

  int b_nr = b.rows ();
  int b_nc = b.cols ();

  if (b_nr == 1 && b_nc == 1)
    return elem_pow(a, b.elem(0,0));
  
  if (a_nr != b_nr || a_nc != b_nc)
    {
      gripe_nonconformant ("operator .^", a_nr, a_nc, b_nr, b_nc);
      return galois ();
    }

  for (int j = 0; j < a_nc; j++)
    for (int i = 0; i < a_nr; i++)
      {
	int tmp = (int)b.elem(i,j);
	while (tmp < 0)
	  tmp += a.n();
	if (tmp == 0)
	  result (i,j) = 1;
	else if (a.elem(i,j) == 0)
	  result (i,j) = 0;
	else
	  result (i,j) = a.alpha_to(modn(a.index_of(a.elem(i,j)) * tmp,
					a.m(),a.n()));
      }
  return result;
}

galois elem_pow (const galois& a, double b)
{
  galois result(a);
  int a_nr = a.rows ();
  int a_nc = a.cols ();
  int bi = (int) b;

  if ((double)bi != b) {
    gripe_integer_galois ();
    return galois ();
  }

  while (bi < 0)
    bi += a.n();

  for (int j = 0; j < a_nc; j++)
    for (int i = 0; i < a_nr; i++)
      {
	if (bi == 0)
	  result (i,j) = 1;
	else if (a.elem(i,j) == 0)
	  result (i,j) = 0;
	else
	  result (i,j) = a.alpha_to(modn(a.index_of(a.elem(i,j)) * 
				bi,a.m(),a.n()));
      }
  return result;
}

galois elem_pow (const galois &a, int b)
{
  galois result(a);
  int a_nr = a.rows ();
  int a_nc = a.cols ();

  while (b < 0)
    b += a.n();

  for (int j = 0; j < a_nc; j++)
    for (int i = 0; i < a_nr; i++)
      {
	if (b == 0)
	  result (i,j) = 1;
	else if (a.elem(i,j) == 0)
	  result (i,j) = 0;
	else
	  result (i,j) = a.alpha_to(modn(a.index_of(a.elem(i,j)) * b,
				a.m(),a.n()));
      }
  return result;
}

galois pow (const galois& a, double b)
{
  int bi = (int)b;
  if ((double)bi != b) {
    gripe_integer_power_galois ();
    return galois ();
  }

  return pow(a, bi);
}

galois pow  (const galois& a, const galois& b)
{
  int nr = b.rows ();
  int nc = b.cols ();

  if (a.have_field() && b.have_field()) {
    if ((a.m() != b.m()) || (a.primpoly() != b.primpoly())) {
      gripe_differ_galois ();
      return galois ();
    }
  } else {
    gripe_invalid_galois ();
    return galois ();
  }

  if (nr != 1 || nc != 1) {
    gripe_square_galois();
    return galois ();
  } else
    return pow (a, b.elem(0,0));
}

galois pow (const galois& a, int b)
{
  galois retval;
  int nr = a.rows ();
  int nc = a.cols ();

  if (!a.have_field()) {
    gripe_invalid_galois ();
    return retval;
  }

  if (nr == 0 || nc == 0 || nr != nc)
      gripe_square_galois();
  else if (b == 0) 
    {
      retval = galois(nr, nc, 0, a.m(), a.primpoly());
      for (int i =0; i<nr; i++)
	retval.elem(i,i) = 1;
    } 
  else
    {
      galois atmp;

      if (b < 0 ) 
	atmp = a.inverse();
      else
	atmp = a;

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

galois
operator * (const Matrix& a, const galois& b)
{
  galois tmp (a, b.m(), b.primpoly());

  OCTAVE_QUIT;

  return tmp * b;
}

galois
operator * (const galois& a, const Matrix& b) 
{
  galois tmp (b, a.m(), a.primpoly());

  OCTAVE_QUIT;

  return a * tmp;
}

galois
operator * (const galois& a, const galois& b)
{
  if (a.have_field() && b.have_field()) {
    if ((a.m() != b.m()) || (a.primpoly() != b.primpoly())) {
      gripe_differ_galois ();
      return galois ();
    }
  } else {
    gripe_invalid_galois ();
    return galois ();
  }

  int a_nr = a.rows ();
  int a_nc = a.cols ();

  int b_nr = b.rows ();
  int b_nc = b.cols ();

  if ((a_nr == 1 && a_nc == 1) || (b_nr == 1 && b_nc == 1))
    return product (a, b);
  else if (a_nc != b_nr)
    {
      gripe_nonconformant ("operator *", a_nr, a_nc, b_nr, b_nc);
      return galois();
    }
  else
    {
      galois retval(a_nr, b_nc, 0, a.m(), a.primpoly());
      if (a_nr != 0 && a_nc != 0 && b_nc != 0)
	{
	  for (int i=0; i<b_nc; i++)
	    for (int j=0; j<b_nr; j++)
	      if (b.elem(j,i) != 0) {
		int temp = b.elem(j, i);
		for (int k=0; k<a_nr; k++) {
		  if (a.elem(k,j) != 0)
		    retval(k,i) = retval(k,i) ^ a.alpha_to(
			  modn(a.index_of(temp) + 
			  a.index_of(a.elem(k,j)),a.m(),a.n()));
		}
	      }
	}
      return retval;
    }
}

// Other operators 
boolMatrix
galois::all (int dim) const
{
  MX_ALL_OP (dim);
}

boolMatrix
galois::any (int dim) const
{
  MX_ANY_OP (dim);
}

galois
galois::prod (int dim) const
{
  if (!have_field()) {
    gripe_invalid_galois ();
    return galois();
  }

  galois retval (0, 0, 0, m(), primpoly());

#define ROW_EXPR \
  if ((retval.elem (i, 0) == 0) || (elem(i,j) == 0)) \
    retval.elem (i, 0) = 0; \
  else \
    retval.elem (i, 0) = alpha_to(modn(index_of(retval.elem(i,0)) + \
				      index_of(elem(i,j)),m(),n()));

#define COL_EXPR \
  if ((retval.elem (0, j) == 0) || (elem(i,j) == 0)) \
    retval.elem (0, j) = 0; \
  else \
    retval.elem (0, j) = alpha_to(modn(index_of(retval.elem(0,j)) + \
				      index_of(elem(i,j)),m(),n()));

  GALOIS_REDUCTION_OP(retval, ROW_EXPR, COL_EXPR, 1, 1);
  return retval;

#undef ROW_EXPR
#undef COL_EXPR
}

galois
galois::sum (int dim) const
{
  if (!have_field()) {
    gripe_invalid_galois ();
    return galois();
  }

  galois retval (0, 0, 0, m(), primpoly());


#define ROW_EXPR \
  retval.elem (i, 0) ^=  elem(i,j);

#define COL_EXPR \
  retval.elem (0, j) ^= elem(i,j);

  GALOIS_REDUCTION_OP (retval, ROW_EXPR, COL_EXPR, 0, 0);
  return retval;

#undef ROW_EXPR
#undef COL_EXPR
}

galois
galois::sumsq (int dim) const
{
  if (!have_field()) {
    gripe_invalid_galois ();
    return galois();
  }

  galois retval (0, 0, 0, m(), primpoly());

#define ROW_EXPR \
  if (elem(i,j) != 0) \
    retval.elem (i, 0) ^= alpha_to(modn(2*index_of(elem(i,j)),m(),n()));

#define COL_EXPR \
  if (elem(i,j) != 0) \
    retval.elem (0, j) ^= alpha_to(modn(2*index_of(elem(i,j)),m(),n()));

  GALOIS_REDUCTION_OP (retval, ROW_EXPR, COL_EXPR, 0, 0);
  return retval;

#undef ROW_EXPR
#undef COL_EXPR
}

galois
galois::log (void) const
{
  bool warned = false; 
  if (!have_field()) {
    gripe_invalid_galois ();
    return galois();
  }

  galois retval (*this);
  int nr = rows ();
  int nc = cols ();

  for (int i=0; i<nr; i++)
    for (int j=0; j<nc; j++) {
      if (retval.elem(i,j) == 0) { 
	if (!warned) {
	  warning("log of zero undefined in Galois field");
	  warned = true;
	}
	// How do I flag a NaN without either
	// 1) Having to check everytime that the data is valid
	// 2) Causing overflow in alpha_to or index_of!!
	retval.elem(i,j) = retval.index_of(retval.elem(i,j));
      } else
	retval.elem(i,j) = retval.index_of(retval.elem(i,j));
    }
  return retval;
}

galois
galois::exp (void) const
{
  bool warned = false; 
  if (!have_field()) {
    gripe_invalid_galois ();
    return galois();
  }

  galois retval (*this);
  int nr = rows ();
  int nc = cols ();

  for (int i=0; i<nr; i++)
    for (int j=0; j<nc; j++) {
      if (retval.elem(i,j) ==  n()) {
	if (!warned) {
	  warning("warning: exp of 2^m-1 undefined in Galois field");
	  warned = true;
	}
	// How do I flag a NaN without either
	// 1) Having to check everytime that the data is valid
	// 2) Causing overflow in alpha_to or index_of!!
	retval.elem(i,j) = retval.alpha_to(retval.elem(i,j));
      } else
	retval.elem(i,j) = retval.alpha_to(retval.elem(i,j));
    }
  return retval;
}

template class base_lu <galois, int, Matrix, double>;

void
LU::factor (const galois& a, const pivot_type& typ)
{
  int a_nr = a.rows ();
  int a_nc = a.cols ();
  int mn = (a_nr > a_nc ? a_nc : a_nr);

  ptype = typ;
  info = 0;
  ipvt.resize (mn);

  a_fact = a;

  for (int j = 0; j < mn; j++) {
    int jp = j;


    // Find the pivot and test for singularity
    if (ptype == LU::ROW) { 
      for (int i = j+1; i < a_nr; i++)
	if (a_fact.elem(i,j) > a_fact.elem(jp,j))
	  jp = i;
    } else {
      for (int i = j+1; i < a_nc; i++)
	if (a_fact.elem(j,i) > a_fact.elem(j,jp))
	  jp = i;
    }

    ipvt.elem(j) = jp;

    if (a_fact.elem(jp,j) != 0) {
      if (ptype == LU::ROW) { 
	// Apply the interchange to columns 1:NC.
	if (jp != j)
	  for (int i = 0; i < a_nc; i++) {
	    int tmp = a_fact.elem(j,i);
	    a_fact.elem(j,i) = a_fact.elem(jp,i);
	    a_fact.elem(jp,i) = tmp;
	  }
      } else {
	// Apply the interchange to rows 1:NR.
	if (jp != j)
	  for (int i = 0; i < a_nr; i++) {
	    int tmp = a_fact.elem(i,j);
	    a_fact.elem(i,j) = a_fact.elem(i,jp);
	    a_fact.elem(i,jp) = tmp;
	  }
      }

      // Compute elements J+1:M of J-th column.
      if ( j < a_nr-1) {
	int idxj = a_fact.index_of(a_fact.elem(j,j)); 
	for (int i = j+1; i < a_nr; i++) {
	  if (a_fact.elem(i,j) == 0)
	    a_fact.elem(i,j) = 0;
	  else
	    a_fact.elem(i,j) = a_fact.alpha_to(modn(a_fact.index_of(
		a_fact.elem(i,j)) - idxj + a_fact.n(), a_fact.m(), 
		a_fact.n()));
	}
      }
    } else {
      info += 1;
    }
    
    if (j < mn-1) {
      // Update trailing submatrix.
      for (int i=j+1; i < a_nr; i++) {
	if (a_fact.elem(i,j) != 0) {
	  int idxi = a_fact.index_of(a_fact.elem(i,j)); 
	  for (int k=j+1; k < a_nc; k++) {
	    if (a_fact.elem(j,k) != 0)
	      a_fact.elem(i,k) ^= a_fact.alpha_to(modn(a_fact.index_of(
			a_fact.elem(j,k)) + idxi, a_fact.m(), a_fact.n()));
	  }
	}
      }
    }
  }
}

galois
LU::L (void) const
{
  int a_nr = a_fact.rows ();
  int a_nc = a_fact.cols ();
  int mn = (a_nr < a_nc ? a_nr : a_nc);

  galois l (a_nr, mn, 0, a_fact.m(), a_fact.primpoly());

  for (int i = 0; i < a_nr; i++)
    {
      l.xelem (i, i) = 1;
      for (int j = 0; j < (i > a_nc ? a_nc : i); j++)
	l.xelem (i, j) = a_fact.xelem (i, j);
    }

  return l;
}

galois
LU::U (void) const
{
  int a_nr = a_fact.rows ();
  int a_nc = a_fact.cols ();
  int mn = (a_nr < a_nc ? a_nr : a_nc);

  galois u (mn, a_nc, 0, a_fact.m(), a_fact.primpoly());

  for (int i = 0; i < mn; i++)
    {
      for (int j = i; j < a_nc; j++)
	u.xelem (i, j) = a_fact.xelem (i, j);
    }

  return u;
}

Matrix
LU::P (void) const
{
  int a_nr = a_fact.rows ();
  int a_nc = a_fact.cols ();
  int n = (ptype == LU::ROW ? a_nr : a_nc);

  Array<int> pvt (n);
  
  for (int i = 0; i < n; i++)
    pvt.xelem (i) = i;

  for (int i = 0; i < ipvt.length(); i++)
    {
      int k = ipvt.xelem (i);

      if (k != i)
	{
	  int tmp = pvt.xelem (k);
	  pvt.xelem (k) = pvt.xelem (i);
	  pvt.xelem (i) = tmp;
	}
    }

  Matrix p(n, n, 0.0);

  for (int i = 0; i < n; i++)
    p.xelem (i, pvt.xelem (i)) = 1.0;

  return p;
}

Array<int>
LU::IP (void) const
{
  return Array<int> (ipvt);
}

galois
LU::A (void) const
{
  return galois (a_fact);
}

galois
galois::inverse (void) const
{
  int info;
  return inverse(info);
}

galois
galois::inverse (int& info, int force) const
{
  int nr = rows ();
  int nc = cols ();
  info = 0;

  if (nr != nc || nr == 0 || nc == 0) {
    (*current_liboctave_error_handler) ("inverse requires square matrix");
    return galois ();
  } else { 
    int info = 0;

    // Solve with identity matrix to find the inverse. 
    galois btmp(nr, nr, 0, m(), primpoly());
    for (int i=0; i < nr; i++)
      btmp.elem(i,i) = 1;

    galois retval = solve(btmp, info, 0);

    if (info == 0) 
      return retval;
    else
      return galois();
  }
}

galois
galois::determinant (void) const
{
  int info;
  return determinant (info);
}

galois
galois::determinant (int& info) const
{
  galois retval(1, 1, 0, m(), primpoly());

  int nr = rows ();
  int nc = cols ();
  info = -1;

  if (nr == 0 || nc == 0) {
    info = 0;
    retval.elem(0,0) = 1;
  } else {
    LU fact (*this);

    if ( ! fact.singular()) {
      galois A (fact.A());
      info = 0;

      retval.elem(0,0) = A.elem(0,0);
      for (int i=1; i<nr; i++) {
	if ((retval.elem (0, 0) == 0) || (A.elem(i,i) == 0)) {
	  retval.elem (0,0) = 0;
	  error("What the hell are we doing here!!!");
	} else 
	  retval.elem (0,0) = alpha_to(modn(index_of(retval.elem(0,0)) + \
					     index_of(A.elem(i,i)),m(),n()));
      }
    }    
  }

  return retval;
}

galois
galois::solve (const galois& b) const
{
  int info;
  return solve (b, info);
}

galois
galois::solve (const galois& b, int& info) const
{
  return solve (b, info, 0);
}

galois
galois::solve (const galois& b, int& info,
	       solve_singularity_handler sing_handler) const
{
  galois retval (b);

  if (!have_field() || !b.have_field()) {
    gripe_invalid_galois ();
    return galois();
  } else if ((m() != b.m()) || (primpoly() != b.primpoly())) {
    gripe_differ_galois ();
    return galois();
  }

  int nr = rows ();
  int nc = cols ();
  int b_nr = b.rows ();
  int b_nc = b.cols ();

  //  if (nr == 0 || nc == 0 || nr != nc || nr != b_nr) {
  if (nr == 0 || nc == 0 || nr != b_nr) {
    (*current_liboctave_error_handler)
      ("matrix dimension mismatch solution of linear equations");
    return galois();
  } else if (nc > nr) {
    // Under-determined system, use column interchanges.
    LU fact ((*this), LU::COL);

    if (fact.singular()) {
      info = -1;
      if (sing_handler)
	sing_handler (0.0);
      else
	(*current_liboctave_error_handler)("galois matrix singular");

      return galois();
    } else {
      galois A (fact.A());
      Array<int> IP (fact.IP());

      // Resize the number of solution rows if needed
      if (nc > nr)
	retval.resize(b_nr+nc-nr,b_nc,0);

      //Solve L*X = B, overwriting B with X.
      for (int j=0; j<b_nc; j++)
	for (int k=0; k<(nc < nr ? nc : nr); k++)
	  if (retval.elem(k,j) != 0) {
	    int idx = index_of(retval.elem(k,j));
	    for (int i=k+1; i<nr; i++)
	      if (A.elem(i,k) != 0)
		retval.elem(i,j) ^= alpha_to(modn(index_of(A.elem(i,k)) + idx, 
					      m(), n()));
	  }

      // Solve U*X = B, overwriting B with X.
      for (int j=0; j<b_nc; j++)
	for (int k=(nc < nr ? nc-1 : nr-1); k>=0; k--)
	  if (retval.elem(k,j) != 0) {
	    retval.elem(k,j) = alpha_to(modn(index_of(retval.elem(k,j)) -
				     index_of(A.elem(k,k)) + n(), m(), n()));
	    int idx = index_of(retval.elem(k,j));
	    for (int i=0; i<(k < nr ? k : nr); i++)
	      if (A.elem(i,k) != 0)
		retval.elem(i,j) ^= alpha_to(modn(index_of(A.elem(i,k)) + idx, 
					      m(), n()));
	  }

      // Apply row interchanges to the right hand sides.
      //for (int j=0; j<IP.length(); j++) {
      for (int j=IP.length()-1; j>=0; j--) {
	int piv = IP(j);
	for (int i=0; i<b_nc; i++) {
	  int tmp = retval.elem(j,i);
	  retval.elem(j,i) = retval.elem(piv,i);
	  retval.elem(piv,i) = tmp;
	}
      }
    }
    
  } else {
    LU fact (*this);

    if (fact.singular()) {
      info = -1;
      if (sing_handler)
	sing_handler (0.0);
      else
	(*current_liboctave_error_handler)("galois matrix singular");

      return galois();
    } else {
      galois A (fact.A());
      Array<int> IP (fact.IP());

      // Apply row interchanges to the right hand sides.
      for (int j=0; j<IP.length(); j++) {
	int piv = IP(j);
	for (int i=0; i<b_nc; i++) {
	  int tmp = retval.elem(j,i);
	  retval.elem(j,i) = retval.elem(piv,i);
	  retval.elem(piv,i) = tmp;
	}
      }

      //Solve L*X = B, overwriting B with X.
      for (int j=0; j<b_nc; j++)
	for (int k=0; k<(nc < nr ? nc : nr); k++)
	  if (retval.elem(k,j) != 0) {
	    int idx = index_of(retval.elem(k,j));
	    for (int i=k+1; i<nr; i++)
	      if (A.elem(i,k) != 0)
		retval.elem(i,j) ^= alpha_to(modn(index_of(A.elem(i,k)) + idx, 
					      m(), n()));
	  }

      // Solve U*X = B, overwriting B with X.
      for (int j=0; j<b_nc; j++)
	for (int k=(nc < nr ? nc-1 : nr-1); k>=0; k--)
	  if (retval.elem(k,j) != 0) {
	    retval.elem(k,j) = alpha_to(modn(index_of(retval.elem(k,j)) -
				     index_of(A.elem(k,k)) + n(), m(), n()));
	    int idx = index_of(retval.elem(k,j));
	    for (int i=0; i<(k < nr ? k : nr); i++)
	      if (A.elem(i,k) != 0)
		retval.elem(i,j) ^= alpha_to(modn(index_of(A.elem(i,k)) + idx, 
					      m(), n()));
	  }

      // Resize the number of solution rows if needed
      if (nc < nr)
	retval.resize(b_nr+nc-nr,b_nc);

    }
  }

  return retval;
}

galois
xdiv (const galois& a, const Matrix& b)
{
  galois btmp(b, a.m(), a.primpoly());

  return xdiv(a, btmp);
}

galois
xdiv (const Matrix& a, const galois& b)
{
  galois atmp(a, b.m(), b.primpoly());

  return xdiv(atmp, b);
}

galois
xdiv (const galois& a, const galois& b)
{
  int info = 0;
  int a_nc = a.cols ();
  int b_nc = b.cols ();

  //  if ((a_nc != b_nc) || (b.rows () != b.cols ()))
  if (a_nc != b_nc)
    {
      int a_nr = a.rows ();
      int b_nr = b.rows ();

      gripe_nonconformant ("operator /", a_nr, a_nc, b_nr, b_nc);
      return galois();
    }

  galois atmp = a.transpose ();
  galois btmp = b.transpose ();
  galois result = btmp.solve (atmp, info, 0);

  if (info == 0) 
    return galois (result.transpose ());
  else
    return galois();
}


galois
xleftdiv (const galois& a, const Matrix& b)
{
  galois btmp(b, a.m(), a.primpoly());

  return xleftdiv(a, btmp);
}

galois
xleftdiv (const Matrix& a, const galois& b)
{
  galois atmp(a, b.m(), b.primpoly());

  return xleftdiv(atmp, b);
}

galois
xleftdiv (const galois& a, const galois& b)
{
  int info = 0;
  int a_nr = a.rows ();
  int b_nr = b.rows ();

  //  if ((a_nr != b_nr) || (a.rows () != a.columns ()))
  if (a_nr != b_nr)
    {
      int a_nc = a.cols ();
      int b_nc = b.cols ();

      gripe_nonconformant ("operator \\", a_nr, a_nc, b_nr, b_nc);
      return galois();
    }

  galois result = a.solve (b, info, 0);

  if (info == 0)
    return result;
  else
    return galois();
}

MM_BIN_OPS1(galois, galois, galois, 1, 2, GALOIS)
MM_BIN_OPS1(galois, galois, Matrix, 1, 2, MATRIX)
MM_BIN_OPS1(galois, Matrix, galois, 2, 1, MATRIX)

MM_CMP_OPS1(galois,  , galois,  , 1, 2, GALOIS)
MM_CMP_OPS1(galois,  , Matrix,  , 1, 2, MATRIX)
MM_CMP_OPS1(Matrix,  , galois,  , 2, 1, MATRIX)

MM_BOOL_OPS1(galois, galois, 0.0, 1, 2, GALOIS)
MM_BOOL_OPS1(galois, Matrix, 0.0, 1, 2, MATRIX)
MM_BOOL_OPS1(Matrix, galois, 0.0, 2, 1, MATRIX)

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
