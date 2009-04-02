/*

Copyright (C) 2009  Jaroslav Hajek

This file is part of Octave.

Octave is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 3 of the License, or (at your
option) any later version.

Octave is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

*/
#include <octave/oct.h>
#include <f77-fcn.h>

extern "C"
{
  F77_RET_T
  F77_FUNC (dgemm, DGEMM) (F77_CONST_CHAR_ARG_DECL,
			   F77_CONST_CHAR_ARG_DECL,
			   const octave_idx_type&, const octave_idx_type&, const octave_idx_type&,
			   const double&, const double*, const octave_idx_type&,
			   const double*, const octave_idx_type&, const double&,
			   double*, const octave_idx_type&
			   F77_CHAR_ARG_LEN_DECL
			   F77_CHAR_ARG_LEN_DECL);

  F77_RET_T
  F77_FUNC (dgemv, DGEMV) (F77_CONST_CHAR_ARG_DECL,
			   const octave_idx_type&, const octave_idx_type&, const double&,
			   const double*, const octave_idx_type&, const double*,
			   const octave_idx_type&, const double&, double*,
			   const octave_idx_type&
			   F77_CHAR_ARG_LEN_DECL);

  F77_RET_T
  F77_FUNC (xddot, XDDOT) (const octave_idx_type&, const double*, const octave_idx_type&,
			   const double*, const octave_idx_type&, double&);

  F77_RET_T
  F77_FUNC (sgemm, SGEMM) (F77_CONST_CHAR_ARG_DECL,
			   F77_CONST_CHAR_ARG_DECL,
			   const octave_idx_type&, const octave_idx_type&, const octave_idx_type&,
			   const float&, const float*, const octave_idx_type&,
			   const float*, const octave_idx_type&, const float&,
			   float*, const octave_idx_type&
			   F77_CHAR_ARG_LEN_DECL
			   F77_CHAR_ARG_LEN_DECL);

  F77_RET_T
  F77_FUNC (sgemv, SGEMV) (F77_CONST_CHAR_ARG_DECL,
			   const octave_idx_type&, const octave_idx_type&, const float&,
			   const float*, const octave_idx_type&, const float*,
			   const octave_idx_type&, const float&, float*,
			   const octave_idx_type&
			   F77_CHAR_ARG_LEN_DECL);

  F77_RET_T
  F77_FUNC (xsdot, XSDOT) (const octave_idx_type&, const float*, const octave_idx_type&,
			   const float*, const octave_idx_type&, float&);

  F77_RET_T
  F77_FUNC (zgemm, ZGEMM) (F77_CONST_CHAR_ARG_DECL,
			   F77_CONST_CHAR_ARG_DECL,
			   const octave_idx_type&, const octave_idx_type&, const octave_idx_type&,
			   const Complex&, const Complex*, const octave_idx_type&,
			   const Complex*, const octave_idx_type&, const Complex&,
			   Complex*, const octave_idx_type&
			   F77_CHAR_ARG_LEN_DECL
			   F77_CHAR_ARG_LEN_DECL);

  F77_RET_T
  F77_FUNC (zgemv, ZGEMV) (F77_CONST_CHAR_ARG_DECL,
                           const octave_idx_type&, const octave_idx_type&, const Complex&,
                           const Complex*, const octave_idx_type&, const Complex*,
                           const octave_idx_type&, const Complex&, Complex*, const octave_idx_type&
                           F77_CHAR_ARG_LEN_DECL);

  F77_RET_T
  F77_FUNC (xzdotu, XZDOTU) (const octave_idx_type&, const Complex*, const octave_idx_type&,
			     const Complex*, const octave_idx_type&, Complex&);

  F77_RET_T
  F77_FUNC (cgemm, CGEMM) (F77_CONST_CHAR_ARG_DECL,
			   F77_CONST_CHAR_ARG_DECL,
			   const octave_idx_type&, const octave_idx_type&, const octave_idx_type&,
			   const FloatComplex&, const FloatComplex*, const octave_idx_type&,
			   const FloatComplex*, const octave_idx_type&, const FloatComplex&,
			   FloatComplex*, const octave_idx_type&
			   F77_CHAR_ARG_LEN_DECL
			   F77_CHAR_ARG_LEN_DECL);

  F77_RET_T
  F77_FUNC (cgemv, CGEMV) (F77_CONST_CHAR_ARG_DECL,
                           const octave_idx_type&, const octave_idx_type&, const FloatComplex&,
                           const FloatComplex*, const octave_idx_type&, const FloatComplex*,
                           const octave_idx_type&, const FloatComplex&, FloatComplex*, const octave_idx_type&
                           F77_CHAR_ARG_LEN_DECL);

  F77_RET_T
  F77_FUNC (xcdotu, XCDOTU) (const octave_idx_type&, const FloatComplex*, const octave_idx_type&,
			     const FloatComplex*, const octave_idx_type&, FloatComplex&);

}

#define DEFINE_DO_XDOT(T, name, NAME) \
  static void \
  do_xdot(const T *a, const T *b, T *c, \
          octave_idx_type n, octave_idx_type rep) \
{ \
  BEGIN_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE; \
  for (octave_idx_type i = 0; i < rep; i++) \
    F77_FUNC (name, NAME) (n, a + i*n, 1, b + i*n, 1, c[i]); \
  END_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE; \
}

#define DEFINE_DO_GEMV(T, name, NAME) \
  static void \
  do_gemv(const T *a, const T *b, T *c, \
          octave_idx_type m, octave_idx_type n, octave_idx_type rep) \
{ \
  const T one = 1, zero = 0; \
  octave_idx_type mn = m*n; \
  BEGIN_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE; \
  for (octave_idx_type i = 0; i < rep; i++) \
    F77_FUNC (name, NAME) (F77_CONST_CHAR_ARG2 ("N", 1), \
                           m, n, one,  a + mn*i, m, \
                           b + n * i, 1, zero, c + m*i, 1 \
                           F77_CHAR_ARG_LEN (1)); \
  END_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE; \
}

#define DEFINE_DO_GEMVT(T, name, NAME) \
  static void \
  do_gemvt(const T *a, const T *b, T *c, \
           octave_idx_type m, octave_idx_type n, octave_idx_type rep) \
{ \
  const T one = 1, zero = 0; \
  octave_idx_type mn = m*n; \
  BEGIN_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE; \
  for (octave_idx_type i = 0; i < rep; i++) \
    F77_FUNC (name, NAME) (F77_CONST_CHAR_ARG2 ("T", 1), \
                           m, n, one,  a + mn*i, m, \
                           b + m * i, 1, zero, c + n*i, 1 \
                           F77_CHAR_ARG_LEN (1)); \
  END_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE; \
}

#define DEFINE_DO_GEMM(T, name, NAME) \
  void do_gemm(const T *a, const T *b, T *c, \
               octave_idx_type m, octave_idx_type n, \
               octave_idx_type k, octave_idx_type rep) \
{ \
  const T one = 1, zero = 0; \
  octave_idx_type mn = m*n, mk = m*k, kn = k*n; \
  BEGIN_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE; \
  for (octave_idx_type i = 0; i < rep; i++) \
    F77_FCN (name, NAME) (F77_CONST_CHAR_ARG2 ("N", 1), \
                          F77_CONST_CHAR_ARG2 ("N", 1), \
                          m, n, k, one, a + i*mk, m, \
                          b + i*kn, k, zero, c + i*mn, m \
                          F77_CHAR_ARG_LEN (1) \
                          F77_CHAR_ARG_LEN (1)); \
  END_INTERRUPT_IMMEDIATELY_IN_FOREIGN_CODE; \
}

DEFINE_DO_XDOT (double, xddot, XDDOT)
DEFINE_DO_XDOT (float, xsdot, XSDOT)
DEFINE_DO_XDOT (Complex, xzdotu, XZDOTU)
DEFINE_DO_XDOT (FloatComplex, xcdotu, XCDOTU)

DEFINE_DO_GEMV (double, dgemv, DGEMV)
DEFINE_DO_GEMV (float, sgemv, SGEMV)
DEFINE_DO_GEMV (Complex, zgemv, ZGEMV)
DEFINE_DO_GEMV (FloatComplex, cgemv, CGEMV)

DEFINE_DO_GEMVT (double, dgemv, DGEMV)
DEFINE_DO_GEMVT (float, sgemv, SGEMV)
DEFINE_DO_GEMVT (Complex, zgemv, ZGEMV)
DEFINE_DO_GEMVT (FloatComplex, cgemv, CGEMV)

DEFINE_DO_GEMM (double, dgemm, DGEMM)
DEFINE_DO_GEMM (float, sgemm, SGEMM)
DEFINE_DO_GEMM (Complex, zgemm, ZGEMM)
DEFINE_DO_GEMM (FloatComplex, cgemm, CGEMM)

template <class NDA>
NDA do_arraymm (const NDA& a, const NDA& b)
{
  NDA c;
  dim_vector dv = a.dims ();
  bool match = dv(1) == b.dims ()(0) && dv.length () == b.ndims ();
  for (int i = 2; i < dv.length (); i++)
    match = match && dv(i) == b.dims ()(i);

  if (match)
    {
      octave_idx_type m = dv(0), n = b.dims ()(1), k = dv(1);
      dv(1) = n;
      c = NDA (dv);
      octave_idx_type rep = dv.numel (2);
      if (m == 1)
        {
          if (n == 1)
            do_xdot (a.data (), b.data (), c.fortran_vec (), k, rep);
          else
            do_gemvt (a.data (), b.data (), c.fortran_vec (), k, n, rep);
        }
      else
        {
          if (n == 1)
            do_gemv (a.data (), b.data (), c.fortran_vec (), m, k, rep);
          else
            do_gemm (a.data (), b.data (), c.fortran_vec (), m, n, k, rep);
        }
    }
  else
    error ("arraymm: dimensions mismatch");

  return c;
}

DEFUN_DLD (arraymm, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{c} =} arraymm (a, b)\n\
Multiplies two chains of matrix blocks. Specifically, @code{c = arraymm (a, b)}\n\
is equivalent to the following code (but much faster):\n\
@example\n\
  for i = 1:n\n\
    c(:,:,i) = a(:,:,i) * b(:,:,i); \n\
  endfor\n\
@end example\n\
The second dimension of @var{a} must match the first dimension of @var{b},\n\
and starting with the third dimension all dimensions must also match.\n\
The first dimension of @var{a} and the second dimension of @var{b} determine\n\
the first two dimensions of @var{c}.\n\
@end deftypefn")
{
  int nargin = args.length ();
  octave_value retval;

  if (nargin == 2 && args(0).is_numeric_type () && args(1).is_numeric_type ())
    {
      octave_value a = args(0), b = args(1);
      if (a.is_complex_type () || b.is_complex_type ())
        {
          if (a.is_single_type () || b.is_single_type ())
            {
              retval = do_arraymm (a.float_complex_array_value (),
                                 b.float_complex_array_value ());
            }
          else
            {
              retval = do_arraymm (a.complex_array_value (),
                                 b.complex_array_value ());
            }
        }
      else
        {
          if (a.is_single_type () || b.is_single_type ())
            {
              retval = do_arraymm (a.float_array_value (),
                                 b.float_array_value ());
            }
          else
            {
              retval = do_arraymm (a.array_value (),
                                 b.array_value ());
            }
        }
    }
  else
    print_usage ();

  return retval;
}
