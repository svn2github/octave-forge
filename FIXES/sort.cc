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

static octave_value_list
vec_sort (RowVector &vec, bool return_idx)
{

  octave_value_list retval;
  int elements = vec.capacity ();
  if (elements == 1)
    {
      if (return_idx)
	retval(1) = RowVector (elements, 1.0);
      retval(0) = vec;
      return retval;
    }
  else if (elements > 1)
    {
#if defined(HAVE_IEEE754_COMPLIANCE) && defined(EIGHT_BYTE_INT)
      double *v = vec.fortran_vec ();

      unsigned EIGHT_BYTE_INT *p = (unsigned EIGHT_BYTE_INT *)v;

      if (return_idx)
	{
	  octave_sort<vec_index *> indexed_ieee754_sort (ieee754_compare);

	  OCTAVE_LOCAL_BUFFER (vec_index *, vi, elements);
	  OCTAVE_LOCAL_BUFFER (vec_index, vix, elements);

	  /* Flip the data in the vector so that int compares on 
	   * IEEE754 give the correct ordering
	   */
	  for (int i = 0; i < elements; i++)
	    {
	      vi[i] = & vix[i];
	      vi[i]->vec = FloatFlip (p[i]);
	      vi[i]->indx = i + 1;
	    }

	  indexed_ieee754_sort.sort (vi, elements);

	  RowVector idx (elements);

	  for (int i = 0; i < elements; i++)
	    {
	      p[i] = IFloatFlip (vi[i]->vec);
	      idx(i) = vi[i]->indx;
	    }

	  /* There are two representations of NaN. One will be sorted to the
	   * beginning of the vector and the other to the end. If it will be
	   * sorted to the beginning, fix things up.
	   */
	  if (lo_ieee_signbit (octave_NaN))
	    {
	      unsigned int i = 0;
	      while (xisnan(v[i++]));
	      OCTAVE_LOCAL_BUFFER (double, itmp, i - 1);
	      for (unsigned int l = 0; l < i -1; l++)
		itmp[l] = idx(l);
	      for (unsigned int l = 0; l < elements - i + 1; l++)
		{
		  v[l] = v[l+i-1];
		  idx(l) = idx(l+i-1);
		}
	      for (unsigned int k = 0, l = elements - i + 1; l < elements; 
		   l++, k++)
		{
		  v[l] = octave_NaN;
		  idx(l) = itmp[k];
		}
	    }
	  retval (1) = idx;
	}
      else
	{
	  octave_sort<unsigned EIGHT_BYTE_INT> ieee754_sort;
 
	  /* Flip the data in the vector so that int compares on 
	   * IEEE754 give the correct ordering
	   */
	  for (int i = 0; i < elements; i++)
	    p[i] = FloatFlip (p[i]);

	  ieee754_sort.sort (p, elements);

	  /* Flip the data out of the vector so that int compares on
	   *  IEEE754 give the correct ordering
	   */
	  for (int i = 0; i < elements; i++)
	    p[i] = IFloatFlip (p[i]);

	  /* There are two representations of NaN. One will be sorted to the
	   * beginning of the vector and the other to the end. If it will be
	   * sorted to the beginning, fix things up.
	   */
	  if (lo_ieee_signbit (octave_NaN))
	    {
	      unsigned int i = 0;
	      double *v = vec.fortran_vec ();
	      while (xisnan(v[i++]));
	      for (unsigned int j = 0; j < elements - i + 1; j++)
		v[j] = v[j+i-1];
	      for (unsigned int j = elements - i + 1; j < elements; j++)
		v[j] = octave_NaN;
	    }
	}
#else
      if (return_idx)
	{
	  octave_sort<vec_index *> indexed_double_sort (double_compare);

	  OCTAVE_LOCAL_BUFFER (vec_index *, vi, elements);
	  OCTAVE_LOCAL_BUFFER (vec_index, vix, elements);

	  for (int i = 0; i < elements; i++)
	    {
	      vi[i] = &vix[i];
	      vi[i]->vec = vec(i);
	      vi[i]->indx = i + 1;
	    }

	  indexed_double_sort.sort (vi, elements);

	  RowVector idx (elements);

	  for (int i = 0; i < elements; i++)
	    {
	      vec(i) = vi[i]->vec;
	      idx(i) = vi[i]->indx;
	    }

	  retval (1) = idx;

	}
      else
	{
	  double *v = vec.fortran_vec ();
	  octave_sort<double> double_sort (double_compare);
	  double_sort.sort (v, elements);
	}
#endif

      retval(0) = vec;
    }

  return retval;
}

// I don't think there is any sane way of doing this with IEEE754 integer
// compares. As the operation is fundamentally without sense, I don't
// care that its not optimized....
static octave_value_list
vec_sort (ComplexRowVector &vec, bool return_idx)
{

  octave_value_list retval;
  int elements = vec.capacity ();
  if (elements == 1)
    {
      if (return_idx)
	retval(1) = RowVector (elements, 1.0);
      retval(0) = vec;
      return retval;
    }
  else if (elements > 1)
    {
      octave_sort<complex_vec_index *> indexed_double_sort (complex_compare);

      OCTAVE_LOCAL_BUFFER (complex_vec_index *, vi, elements);
      OCTAVE_LOCAL_BUFFER (complex_vec_index, vix, elements);

      for (int i = 0; i < elements; i++)
	{
	  vi[i] = &vix[i];
	  vi[i]->vec = vec(i);
	  vi[i]->indx = i + 1;
	}

      indexed_double_sort.sort (vi, elements);


      if (return_idx)
	{
	  RowVector idx (elements);

	  for (int i = 0; i < elements; i++)
	    {
	      vec(i) = vi[i]->vec;
	      idx(i) = vi[i]->indx;
	    }

	  retval (1) = idx;
	}
      else
	{
	  for (int i = 0; i < elements; i++)
	    vec(i) = vi[i]->vec;
	}
      retval(0) = vec;
    }

  return retval;
}

static octave_value_list
mx_sort (Matrix &m, bool return_idx)
{
  octave_value_list retval;
  int nr = m.rows ();
  int nc = m.columns ();

  if (nr == 1 && nc > 0)
    {
      if (return_idx)
	retval(1) = Matrix (nr, nc, 1.0);
      retval(0) = m;
      return retval;
    }
  else if (nr > 1 && nc > 0)
    {

#if defined(HAVE_IEEE754_COMPLIANCE) && defined(EIGHT_BYTE_INT)
      double *v = m.fortran_vec ();

      unsigned EIGHT_BYTE_INT *p = (unsigned EIGHT_BYTE_INT *)v;

      if (return_idx)
	{
	  octave_sort<vec_index *> indexed_ieee754_sort (ieee754_compare);

	  OCTAVE_LOCAL_BUFFER (vec_index *, vi, nr);
	  OCTAVE_LOCAL_BUFFER (vec_index, vix, nr);

	  for (int i = 0; i < nr; i++)
	    vi[i] = &vix[i];

	  Matrix idx (nr, nc);

	  for (int j = 0; j < nc; j++)
	    {

	      /* Flip the data in the vector so that int compares on 
	       * IEEE754 give the correct ordering
	       */
	      for (int i = 0; i < nr; i++)
		{
		  vi[i]->vec = FloatFlip (p[i]);
		  vi[i]->indx = i + 1;
		}

	      indexed_ieee754_sort.sort (vi, nr);

	      /* Flip the data out of the vector so that int compares on
	       *  IEEE754 give the correct ordering
	       */
	      for (int i = 0; i < nr; i++)
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
		  for (unsigned int l = 0; l < nr - i + 1; l++)
		    {
		      vtmp[l] = vtmp[l+i-1];
		      idx(l,j) = idx(l+i-1,j);
		    }
		  for (unsigned int k = 0, l = nr - i + 1; l < nr; 
		       l++, k++)
		    {
		      vtmp[l] = octave_NaN;
		      idx(l,j) = itmp[k];
		    }
		}

	      p += nr;
	    }

	  retval (1) = idx;
	}
      else
	{
	  octave_sort<unsigned EIGHT_BYTE_INT> ieee754_sort;
 
	  for (int j = 0; j < nc; j++)
	    {
	      /* Flip the data in the vector so that int compares on 
	       * IEEE754 give the correct ordering
	       */
	      for (int i = 0; i < nr; i++)
		p[i] = FloatFlip (p[i]);

	      ieee754_sort.sort (p, nr);

	      /* Flip the data out of the vector so that int compares on
	       *  IEEE754 give the correct ordering
	       */
	      for (int i = 0; i < nr; i++)
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
		  for (unsigned int l = 0; l < nr - i + 1; l++)
		    vtmp[l] = vtmp[l+i-1];
		  for (unsigned int l = nr - i + 1; l < nr; l++)
		    vtmp[l] = octave_NaN;
		}

	      p += nr;
	    }
	}
#else
      if (return_idx)
	{
	  octave_sort<vec_index *> indexed_double_sort (double_compare);

	  OCTAVE_LOCAL_BUFFER (vec_index *, vi, nr);
	  OCTAVE_LOCAL_BUFFER (vec_index, vix, nr);

	  for (int i = 0; i < nr; i++)
	    vi[i] = &vix[i];

	  Matrix idx (nr, nc);

	  for (int j = 0; j < nc; j++)
	    {
	      for (int i = 0; i < nr; i++)
		{
		  vi[i]->vec = m(i,j);
		  vi[i]->indx = i + 1;
		}

	      indexed_double_sort.sort (vi, nr);

	      for (int i = 0; i < nr; i++)
		{
		  m(i,j) = vi[i]->vec;
		  idx(i,j) = vi[i]->indx;
		}
	    }
	  retval (1) = idx;
	}
      else
	{
	  double *v = m.fortran_vec ();
	  octave_sort<double> double_sort (double_compare);
	  for (int j = 0; j < nc; j++) 
	    {
	      double_sort.sort (v, nr);
	      v += nr;
	    }
	}
#endif
      retval(0) = m;
    }

  return retval;
}

// I don't think there is any sane way of doing this with IEEE754 integer
// compares. As the operation is fundamentally without sense, I don't
// care that its not optimized....
static octave_value_list
mx_sort (ComplexMatrix &m, bool return_idx)
{
  octave_value_list retval;
  int nr = m.rows ();
  int nc = m.columns ();

  if (nr == 1 && nc > 0)
    {
      if (return_idx)
	retval(1) = Matrix (nr, nc, 1.0);
      retval(0) = m;
      return retval;
    }
  else if (nr > 1 && nc > 0)
    {
      octave_sort<complex_vec_index *> indexed_double_sort (complex_compare);

      OCTAVE_LOCAL_BUFFER (complex_vec_index *, vi, nr);
      OCTAVE_LOCAL_BUFFER (complex_vec_index, vix, nr);

      for (int i = 0; i < nr; i++)
	vi[i] = &vix[i];

      Matrix idx (nr, nc);

      for (int j = 0; j < nc; j++)
	{
	  for (int i = 0; i < nr; i++)
	    {
	      vi[i]->vec = m(i,j);
	      vi[i]->indx = i + 1;
	    }

	  indexed_double_sort.sort (vi, nr);

	  if (return_idx)
	    {
	      for (int i = 0; i < nr; i++)
		{
		  m(i,j) = vi[i]->vec;
		  idx(i,j) = vi[i]->indx;
		}
	    }
	  else
	    {
	      for (int i = 0; i < nr; i++)
		m(i,j) = vi[i]->vec;
	    }
	}

      if (return_idx)
	  retval (1) = idx;

      retval(0) = m;
    }

  return retval;
}

DEFUN_DLD (sort, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {[@var{s}, @var{i}] =} sort (@var{x})\n\
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
The for equal elements, the indices are such that the equal elements\n\
are listed in the order that appeared in the original list.\n\
\n\
The algorithm used in @code{sort} is optimized for the sorting of partially\n\
ordered lists.\n\
@end deftypefn")
{
  octave_value_list retval;

  int nargin = args.length ();

  if (nargin != 1)
    {
      print_usage ("sort");
      return retval;
    }

  bool return_idx = nargout > 1;

  octave_value arg = args(0);

  if (arg.is_real_type ())
    {
      Matrix m = arg.matrix_value ();

      if (! error_state)
	{
	  if (m.rows () == 1)
	    {
	      int nc = m.columns ();
	      RowVector v (nc);
	      for (int i = 0; i < nc; i++)
		v(i) = m(0,i);

	      retval = vec_sort (v, return_idx);
	    }
	  else
	    retval = mx_sort (m, return_idx);
	}
    }
  else if (arg.is_complex_type ())
    {
      ComplexMatrix cm = arg.complex_matrix_value ();

      if (! error_state)
	{
	  if (cm.rows () == 1)
	    {
	      int nc = cm.columns ();
	      ComplexRowVector cv (nc);
	      for (int i = 0; i < nc; i++)
		cv(i) = cm(0,i);

	      retval = vec_sort (cv, return_idx);
	    }
	  else
	    retval = mx_sort (cm, return_idx);
	}
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
