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

#include <octave/oct.h>
#include <octave/lo-mappers.h>
#include <octave/config.h>
#include <octave/quit.h>
#include <octave/lo-ieee.h>
#include <octave/data-conv.h>
#include <octave/ov-cx-mat.h>
#include "oct-sort.cc"

// ======= Cruft to support ancient versions of Octave =========
#ifndef OCTAVE_LOCAL_BUFFER
#include <vector>
#define OCTAVE_LOCAL_BUFFER(T, buf, size) \
  std::vector<T> buf ## _vector (size); \
  T *buf = &(buf ## _vector[0])
#endif

#ifndef lo_ieee_signbit
#if defined (signbit)
#define lo_ieee_signbit(x) signbit (x)
#elif defined (HAVE_SIGNBIT)
#if defined (__MINGW32__)
extern int signbit (double);
#endif
#define lo_ieee_signbit(x) (x < 0 || signbit (x))
#elif defined (copysign)
#define lo_ieee_signbit(x) (copysign (1.0, x) < 0)
#elif defined (HAVE_COPYSIGN)
#define lo_ieee_signbit(x) (x < 0 || copysign (1.0, x) < 0)
#else
#define lo_ieee_signbit(x) 0
#endif
#endif

// ========= End Cruft ===================================

/* If we are IEEE 754 or IEEE 854 compliant, then we can use the trick of
 * casting doubles as unsigned eight byte integers, and with a little
 * bit of magic we can automatically sort the NaN's correctly.
 */

#if defined(HAVE_IEEE754_COMPLIANCE) && defined(EIGHT_BYTE_INT)

static inline unsigned EIGHT_BYTE_INT FloatFlip(unsigned EIGHT_BYTE_INT f)
{
  unsigned EIGHT_BYTE_INT mask = -(EIGHT_BYTE_INT)(f >> 63) | 
    0x8000000000000000ULL;
  return f ^ mask;
}

inline unsigned EIGHT_BYTE_INT IFloatFlip(unsigned EIGHT_BYTE_INT f)
{
  unsigned EIGHT_BYTE_INT mask = ((f >> 63) - 1) | 0x8000000000000000ULL;
  return f ^ mask;
}

struct vec_index
{
  unsigned EIGHT_BYTE_INT vec;
  int indx;
};

bool
ieee754_compare (vec_index *a, vec_index *b)
{
  return (a->vec < b->vec);
}

template octave_sort<unsigned EIGHT_BYTE_INT>;
template octave_sort<vec_index *>;
#else
struct vec_index
{
  double vec;
  int indx;
};

bool
double_compare (double a, double b)
{
  return (xisnan(b) || (a < b));
}

bool
double_compare (vec_index *a, vec_index *b)
{
  return (xisnan(b->vec) || (a->vec < b->vec));
}

template octave_sort<double>;
template octave_sort<vec_index *>;
#endif

struct complex_vec_index
{
  Complex vec;
  int indx;
};

bool
complex_compare (complex_vec_index *a, complex_vec_index *b)
{
  return (xisnan(b->vec) || (abs(a->vec) < abs(b->vec)));
}

template octave_sort<complex_vec_index *>;

#ifdef HAVE_ND_ARRAYS
static octave_value_list
mx_sort (NDArray &m, bool return_idx, int dim)
{
  octave_value_list retval;

  if (m.length () < 1)
    return retval;

  dim_vector dv = m.dims ();
  unsigned int ns = dv (dim);
  unsigned int iter = dv.numel () / ns;
  unsigned int stride = 1;
  for (unsigned int i = 0; i < (unsigned int)dim; i++)
    stride *= dv(i);

#if defined(HAVE_IEEE754_COMPLIANCE) && defined(EIGHT_BYTE_INT)
  double *v = m.fortran_vec ();

  unsigned EIGHT_BYTE_INT *p = (unsigned EIGHT_BYTE_INT *)v;

  if (return_idx)
    {
      octave_sort<vec_index *> indexed_ieee754_sort (ieee754_compare);

      OCTAVE_LOCAL_BUFFER (vec_index *, vi, ns);
      OCTAVE_LOCAL_BUFFER (vec_index, vix, ns);
      
      for (unsigned int i = 0; i < ns; i++)
	vi[i] = &vix[i];

      NDArray idx (dv);
      
      for (unsigned int j = 0; j < iter; j++)
	{
	  unsigned int offset = j;
	  unsigned int offset2 = 0;
	  while (offset >= stride)
	    {
	      offset -= stride;
	      offset2++;
	    }
	  offset += offset2 * stride * ns;

	  /* Flip the data in the vector so that int compares on 
	   * IEEE754 give the correct ordering
	   */
	  for (unsigned int i = 0; i < ns; i++)
	    {
	      vi[i]->vec = FloatFlip (p[i*stride + offset]);
	      vi[i]->indx = i + 1;
	    }

	  indexed_ieee754_sort.sort (vi, ns);

	  /* Flip the data out of the vector so that int compares on
	   *  IEEE754 give the correct ordering
	   */
	  for (unsigned int i = 0; i < ns; i++)
	    {
	      p[i*stride + offset] = IFloatFlip (vi[i]->vec);
	      idx(i*stride + offset) = vi[i]->indx;
	    }

	  /* There are two representations of NaN. One will be sorted to
	   * the beginning of the vector and the other to the end. If it
	   * will be sorted to the beginning, fix things up.
	   */
	  if (lo_ieee_signbit (octave_NaN))
	    {
	      unsigned int i = 0;
	      while (xisnan(v[i++*stride+offset]) && i < ns);
	      OCTAVE_LOCAL_BUFFER (double, itmp, i - 1);
	      for (unsigned int l = 0; l < i -1; l++)
		itmp[l] = idx(l*stride + offset);
	      for (unsigned int l = 0; l < ns - i + 1; l++)
		{
		  v[l*stride + offset] = v[(l+i-1)*stride + offset];
		  idx(l*stride + offset) = idx((l+i-1)*stride + offset);
		}
	      for (unsigned int k = 0, l = ns - i + 1; l < ns; l++, k++)
		{
		  v[l*stride + offset] = octave_NaN;
		  idx(l*stride + offset) = itmp[k];
		}
	    }
	}

      retval (1) = idx;
    }
  else
    {
      octave_sort<unsigned EIGHT_BYTE_INT> ieee754_sort;
 
      if (stride == 1)
	{
	  for (unsigned int j = 0; j < iter; j++)
	    {
	      /* Flip the data in the vector so that int compares on 
	       * IEEE754 give the correct ordering
	       */
	      for (unsigned int i = 0; i < ns; i++)
		p[i] = FloatFlip (p[i]);
	      
	      ieee754_sort.sort (p, ns);

	      /* Flip the data out of the vector so that int compares on
	       *  IEEE754 give the correct ordering
	       */
	      for (unsigned int i = 0; i < ns; i++)
		p[i] = IFloatFlip (p[i]);

	      /* There are two representations of NaN. One will be sorted to
	       * the beginning of the vector and the other to the end. If it
	       * will be sorted to the beginning, fix things up.
	       */
	      if (lo_ieee_signbit (octave_NaN))
		{
		  unsigned int i = 0;
		  double *vtmp = (double *)p;
		  while (xisnan(vtmp[i++]) && i < ns);
		  for (unsigned int l = 0; l < ns - i + 1; l++)
		    vtmp[l] = vtmp[l+i-1];
		  for (unsigned int l = ns - i + 1; l < ns; l++)
		    vtmp[l] = octave_NaN;
		}

	      p += ns;
	    }

	}
      else
	{
	  OCTAVE_LOCAL_BUFFER (unsigned EIGHT_BYTE_INT, vi, ns);

	  for (unsigned int j = 0; j < iter; j++)
	    {
	      unsigned int offset = j;
	      unsigned int offset2 = 0;
	      while (offset >= stride)
		{
		  offset -= stride;
		  offset2++;
		}
	      offset += offset2 * stride * ns;

	      /* Flip the data in the vector so that int compares on 
	       * IEEE754 give the correct ordering
	       */
	      for (unsigned int i = 0; i < ns; i++)
		vi[i] = FloatFlip (p[i*stride + offset]);

	      ieee754_sort.sort (vi, ns);

	      /* Flip the data out of the vector so that int compares on
	       *  IEEE754 give the correct ordering
	       */
	      for (unsigned int i = 0; i < ns; i++)
		p[i*stride + offset] = IFloatFlip (vi[i]);
	      
	      /* There are two representations of NaN. One will be sorted to
	       * the beginning of the vector and the other to the end. If it
	       * will be sorted to the beginning, fix things up.
	       */
	      if (lo_ieee_signbit (octave_NaN))
		{
		  unsigned int i = 0;
		  while (xisnan(v[i++*stride + offset]) && i < ns);
		  for (unsigned int l = 0; l < ns - i + 1; l++)
		    v[l*stride + offset] = v[(l+i-1)*stride + offset];
		  for (unsigned int l = ns - i + 1; l < ns; l++)
		    v[l*stride + offset] = octave_NaN;
		}
	    }
	}
    }
#else
  if (return_idx)
    {
      double *v = m.fortran_vec ();
      octave_sort<vec_index *> indexed_double_sort (double_compare);

      OCTAVE_LOCAL_BUFFER (vec_index *, vi, ns);
      OCTAVE_LOCAL_BUFFER (vec_index, vix, ns);

      for (unsigned int i = 0; i < ns; i++)
	vi[i] = &vix[i];

      NDArray idx (dv);
      
      if (stride == 1)
	{
	  for (unsigned int j = 0; j < iter; j++)
	    {
	      unsigned int offset = j * ns;

	      for (unsigned int i = 0; i < ns; i++)
		{
		  vi[i]->vec = v[i];
		  vi[i]->indx = i + 1;
		}

	      indexed_double_sort.sort (vi, ns);
	  
	      for (unsigned int i = 0; i < ns; i++)
		{
		  v[i] = vi[i]->vec;
		  idx(i + offset) = vi[i]->indx;
		}
	      v += ns;
	    }
	}
      else
	{
	  for (unsigned int j = 0; j < iter; j++)
	    {
	      unsigned int offset = j;
	      unsigned int offset2 = 0;
	      while (offset >= stride)
		{
		  offset -= stride;
		  offset2++;
		}
	      offset += offset2 * stride * ns;
	      
	      for (unsigned int i = 0; i < ns; i++)
		{
		  vi[i]->vec = v[i*stride + offset];
		  vi[i]->indx = i + 1;
		}

	      indexed_double_sort.sort (vi, ns);
	      
	      for (unsigned int i = 0; i < ns; i++)
		{
		  v[i*stride+offset] = vi[i]->vec;
		  idx(i*stride+offset) = vi[i]->indx;
		}
	    }
	}
      retval (1) = idx;
    }
  else
    {
      double *v = m.fortran_vec ();
      octave_sort<double> double_sort (double_compare);

      if (stride == 1)
	for (unsigned int j = 0; j < iter; j++)
	  {
	    double_sort.sort (v, ns);
	    v += ns;
	  }
      else
	{
	  OCTAVE_LOCAL_BUFFER (double, vi, ns);
	  for (unsigned int j = 0; j < iter; j++) 
	    {
	      unsigned int offset = j;
	      unsigned int offset2 = 0;
	      while (offset >= stride)
		{
		  offset -= stride;
		  offset2++;
		}
	      offset += offset2 * stride * ns;

	      for (unsigned int i = 0; i < ns; i++)
		vi[i] = v[i*stride + offset];

	      double_sort.sort (vi, ns);
	      
	      for (unsigned int i = 0; i < ns; i++)
		v[i*stride + offset] = vi[i];
	    }
	}
    }
#endif
  retval(0) = m;
  return retval;
}

static octave_value_list
mx_sort (ComplexNDArray &m, bool return_idx, int dim)
{
  octave_value_list retval;

  if (m.length () < 1)
    return retval;

  dim_vector dv = m.dims ();
  unsigned int ns = dv (dim);
  unsigned int iter = dv.numel () / ns;
  unsigned int stride = 1;
  for (unsigned int i = 0; i < (unsigned int)dim; i++)
    stride *= dv(i);

  octave_sort<complex_vec_index *> indexed_double_sort (complex_compare);

  Complex *v = m.fortran_vec ();

  OCTAVE_LOCAL_BUFFER (complex_vec_index *, vi, ns);
  OCTAVE_LOCAL_BUFFER (complex_vec_index, vix, ns);

  for (unsigned int i = 0; i < ns; i++)
    vi[i] = &vix[i];

  NDArray idx (dv);

  if (stride == 1)
    {
      for (unsigned int j = 0; j < iter; j++)
	{
	  unsigned int offset = j * ns;

	  for (unsigned int i = 0; i < ns; i++)
	    {
	      vi[i]->vec = v[i];
	      vi[i]->indx = i + 1;
	    }
      
	  indexed_double_sort.sort (vi, ns);
      
	  if (return_idx)
	    {
	      for (unsigned int i = 0; i < ns; i++)
		{
		  v[i] = vi[i]->vec;
		  idx(i + offset) = vi[i]->indx;
		}
	    }
	  else
	    {
	      for (unsigned int i = 0; i < ns; i++)
		v[i] = vi[i]->vec;
	    }
	  v += ns;
	}
    }
  else
    {
      for (unsigned int j = 0; j < iter; j++)
	{
	  unsigned int offset = j;
	  unsigned int offset2 = 0;
	  while (offset >= stride)
	    {
	      offset -= stride;
	      offset2++;
	    }
	  offset += offset2 * stride * ns;

	  for (unsigned int i = 0; i < ns; i++)
	    {
	      vi[i]->vec = v[i*stride + offset];
	      vi[i]->indx = i + 1;
	    }
      
	  indexed_double_sort.sort (vi, ns);
      
	  if (return_idx)
	    {
	      for (unsigned int i = 0; i < ns; i++)
		{
		  v[i*stride + offset] = vi[i]->vec;
		  idx(i*stride + offset) = vi[i]->indx;
		}
	    }
	  else
	    {
	      for (unsigned int i = 0; i < ns; i++)
		v[i*stride + offset] = vi[i]->vec;
	    }
	}
    }

  if (return_idx)
    retval (1) = idx;
  
  retval(0) = m;

  return retval;
}

#else

static octave_value_list
mx_sort (Matrix &m, bool return_idx, int dim)
{
  octave_value_list retval;

  int nr = m.rows ();
  int nc = m.columns ();
  bool trans = false;
  int nc2, nr2;

  if (m.length () < 1)
    return retval;

  if (dim)
    {
      nr2 = nc;
      nc2 = nr;
      if (nr != 1)
	{
	  trans = true;
	  m = m.transpose ();
	}
    }
  else
    {
      nr2 = nr;
      nc2 = nc;
    }

#if defined(HAVE_IEEE754_COMPLIANCE) && defined(EIGHT_BYTE_INT)
  double *v = m.fortran_vec ();

  unsigned EIGHT_BYTE_INT *p = (unsigned EIGHT_BYTE_INT *)v;

  if (return_idx)
    {
      octave_sort<vec_index *> indexed_ieee754_sort (ieee754_compare);

      OCTAVE_LOCAL_BUFFER (vec_index *, vi, nr2);
      OCTAVE_LOCAL_BUFFER (vec_index, vix, nr2);

      for (int i = 0; i < nr2; i++)
	vi[i] = &vix[i];

      Matrix idx (nr2, nc2);

      for (int j = 0; j < nc2; j++)
	{

	  /* Flip the data in the vector so that int compares on 
	   * IEEE754 give the correct ordering
	   */
	  for (int i = 0; i < nr2; i++)
	    {
	      vi[i]->vec = FloatFlip (p[i]);
	      vi[i]->indx = i + 1;
	    }

	  indexed_ieee754_sort.sort (vi, nr2);
	  
	  /* Flip the data out of the vector so that int compares on
	   *  IEEE754 give the correct ordering
	   */
	  for (int i = 0; i < nr2; i++)
	    {
	      p[i] = IFloatFlip (vi[i]->vec);
	      idx(i,j) = vi[i]->indx;
	    }

	  /* There are two representations of NaN. One will be sorted to
	   * the beginning of the vector and the other to the end. If it
	   * will be sorted to the beginning, fix things up.
	   */
	  if (lo_ieee_signbit (octave_NaN))
	    {
	      unsigned int i = 0;
	      double *vtmp = (double *)p;
	      while (xisnan(vtmp[i++]));
	      OCTAVE_LOCAL_BUFFER (double, itmp, i - 1);
	      for (unsigned int l = 0; l < i -1; l++)
		itmp[l] = idx(l,j);
	      for (unsigned int l = 0; l < nr2 - i + 1; l++)
		{
		  vtmp[l] = vtmp[l+i-1];
		  idx(l,j) = idx(l+i-1,j);
		}
	      for (unsigned int k = 0, l = nr2 - i + 1; l < nr2; 
		   l++, k++)
		{
		  vtmp[l] = octave_NaN;
		  idx(l,j) = itmp[k];
		}
	    }

	  p += nr2;
	}

      if (dim)
	retval (1) = idx.transpose ();
      else
	retval (1) = idx;
    }
  else
    {
      octave_sort<unsigned EIGHT_BYTE_INT> ieee754_sort;
 
      for (int j = 0; j < nc2; j++)
	{
	  /* Flip the data in the vector so that int compares on 
	   * IEEE754 give the correct ordering
	   */
	  for (int i = 0; i < nr2; i++)
	    p[i] = FloatFlip (p[i]);

	  ieee754_sort.sort (p, nr2);

	  /* Flip the data out of the vector so that int compares on
	   *  IEEE754 give the correct ordering
	   */
	  for (int i = 0; i < nr2; i++)
	    p[i] = IFloatFlip (p[i]);

	  /* There are two representations of NaN. One will be sorted to
	   * the beginning of the vector and the other to the end. If it
	   * will be sorted to the beginning, fix things up.
	   */
	  if (lo_ieee_signbit (octave_NaN))
	    {
	      unsigned int i = 0;
	      double *vtmp = (double *)p;
	      while (xisnan(vtmp[i++]));
	      for (unsigned int l = 0; l < nr2 - i + 1; l++)
		vtmp[l] = vtmp[l+i-1];
	      for (unsigned int l = nr2 - i + 1; l < nr2; l++)
		vtmp[l] = octave_NaN;
	    }

	  p += nr2;
	}
    }
#else
  if (return_idx)
    {
      double *v = m.fortran_vec ();
      octave_sort<vec_index *> indexed_double_sort (double_compare);

      OCTAVE_LOCAL_BUFFER (vec_index *, vi, nr2);
      OCTAVE_LOCAL_BUFFER (vec_index, vix, nr2);

      for (int i = 0; i < nr2; i++)
	vi[i] = &vix[i];

      Matrix idx (nr2, nc2);

      for (int j = 0; j < nc2; j++)
	{
	  for (int i = 0; i < nr2; i++)
	    {
	      vi[i]->vec = v[i];
	      vi[i]->indx = i + 1;
	    }

	  indexed_double_sort.sort (vi, nr2);

	  for (int i = 0; i < nr2; i++)
	    {
	      v[i] = vi[i]->vec;
	      idx(i,j) = vi[i]->indx;
	    }
	  v += nr2;
	}
      if (dim)
	retval (1) = idx.transpose ();
      else
	retval (1) = idx;
    }
  else
    {
      double *v = m.fortran_vec ();
      octave_sort<double> double_sort (double_compare);
      for (int j = 0; j < nc2; j++) 
	{
	  double_sort.sort (v, nr2);
	  v += nr2;
	}
    }
#endif
  if (trans)
    retval(0) = m.transpose ();
  else
    retval(0) = m;

  return retval;
}

// I don't think there is any sane way of doing this with IEEE754 integer
// compares. As the operation is fundamentally without sense, I don't
// care that its not optimized....
static octave_value_list
mx_sort (ComplexMatrix &m, bool return_idx, int dim)
{
  octave_value_list retval;
  int nr = m.rows ();
  int nc = m.columns ();
  bool trans = false;
  int nc2, nr2;

  if (m.length () < 1)
    return retval;

  if (dim)
    {
      nr2 = nc;
      nc2 = nr;
      if (nr != 1)
	{
	  trans = true;
	  m = m.transpose ();
	}
    }
  else
    {
      nr2 = nr;
      nc2 = nc;
    }

  octave_sort<complex_vec_index *> indexed_double_sort (complex_compare);

  Complex *v = m.fortran_vec ();

  OCTAVE_LOCAL_BUFFER (complex_vec_index *, vi, nr2);
  OCTAVE_LOCAL_BUFFER (complex_vec_index, vix, nr2);

  for (int i = 0; i < nr2; i++)
    vi[i] = &vix[i];

  Matrix idx (nr2, nc2);

  for (int j = 0; j < nc2; j++)
    {
      for (int i = 0; i < nr2; i++)
	{
	  vi[i]->vec = v[i];
	  vi[i]->indx = i + 1;
	}

      indexed_double_sort.sort (vi, nr2);

      if (return_idx)
	{
	  for (int i = 0; i < nr2; i++)
	    {
	      v[i] = vi[i]->vec;
	      idx(i,j) = vi[i]->indx;
	    }
	}
      else
	{
	  for (int i = 0; i < nr2; i++)
	    v[i] = vi[i]->vec;
	}
      v += nr2;
    }

  if (return_idx)
    if (dim)
      retval (1) = idx.transpose ();
    else
      retval (1) = idx;

  if (trans)
    retval(0) = m.transpose ();
  else
    retval(0) = m;

  return retval;
}
#endif

DEFUN_DLD (sort, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{s}, @var{i}] =} sort (@var{x})\n\
@deftypefnx {Loadable Function} {[@var{s}, @var{i}] =} sort (@var{x}, @var{dim})\n\
Return a copy of @var{x} with the elements elements arranged in\n\
increasing order.  For matrices, @code{sort} orders the elements in each\n\
column.\n\
\n\
For example,\n\
\n\
@example\n\
@group\n\
sort ([1, 2; 2, 3; 3, 1])\n\
     @result{}  1  1\n\
         2  2\n\
         3  3\n\
@end group\n\
@end example\n\
\n\
The @code{sort} function may also be used to produce a matrix\n\
containing the original row indices of the elements in the sorted\n\
matrix.  For example,\n\
\n\
@example\n\
@group\n\
[s, i] = sort ([1, 2; 2, 3; 3, 1])\n\
     @result{} s = 1  1\n\
            2  2\n\
            3  3\n\
     @result{} i = 1  3\n\
            2  1\n\
            3  2\n\
@end group\n\
@end example\n\
\n\
If the optional argument @var{dim} is given, then the matrix is sorted\n\
along the dimension defined by @var{dim}.\n\
\n\
For equal elements, the indices are such that the equal elements\n\
are listed in the order that appeared in the original list.\n\
\n\
The algorithm used in @code{sort} is optimized for the sorting of partially\n\
ordered lists.\n\
@end deftypefn")
{
  octave_value_list retval;

  int nargin = args.length ();

  if (nargin != 1 && nargin != 2)
    {
      print_usage ("sort");
      return retval;
    }

  bool return_idx = nargout > 1;

  octave_value arg = args(0);

  int dim = 0;
  if (nargin == 2)
    dim = args(1).nint_value () - 1;

#ifdef HAVE_ND_ARRAYS
  dim_vector dv = ((const octave_complex_matrix&) arg) .dims ();
  if (error_state)
    {
      gripe_wrong_type_arg ("sort", arg);
      return retval;
    }
  if (nargin != 2)
    {
      // Find first non singleton dimension
      for (int i = 0; i < dv.length (); i++)
	if (dv(i) > 1)
	  {
	    dim = i;
	    break;
	  }
    }
  else
    {
      if (dim < 0 || dim > dv.length () - 1)
	{
	  error ("sort: dim must be a valid dimension");
	  return retval;
	}
    }
#else
  int nr = ((const octave_complex_matrix&) arg) .rows ();
  if (error_state)
    {
      gripe_wrong_type_arg ("sort", arg);
      return retval;
    }
  if (nargin != 2)
    dim = (nr == 1 ? 1 : 0);
  else
    {
      if (dim < 0 || dim > 1)
	{
	  error ("sort: dim must be a valid dimension");
	  return retval;
	}
    }
#endif

  if (arg.is_real_type ())
    {
#ifdef HAVE_ND_ARRAYS
      NDArray m = arg.array_value ();
#else
      Matrix m = arg.matrix_value ();
#endif

      if (! error_state)
	retval = mx_sort (m, return_idx, dim);
    }
  else if (arg.is_complex_type ())
    {
#ifdef HAVE_ND_ARRAYS
      ComplexNDArray cm = arg.complex_array_value ();
#else      
      ComplexMatrix cm = arg.complex_matrix_value ();
#endif
      if (! error_state)
	retval = mx_sort (cm, return_idx, dim);
    }
  else
    gripe_wrong_type_arg ("sort", arg);

  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
