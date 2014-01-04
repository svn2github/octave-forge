/*
Copyright (C) 2006, 2007 Thomas Kasper, <thomaskasper@gmx.net>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; If not, see <http://www.gnu.org/licenses/>. 
*/

#include "ov-grad.h"
#include <complex>
#include <octave/ov-complex.h>
#include <octave/ov-re-sparse.h>
#include <octave/ov-cx-sparse.h>
#include <octave/xpow.h>
#include <octave/symtab.h>
#include <octave/parse.h>
#include <octave/utils.h>
#include <octave/error.h>
#include <octave/ops.h>

/* macros */

#define DEFBOP_GX(o, t, f) \
	DEFBINOP (o ## _g_ ## t, gradient, t) \
	{ \
		CAST_BINOP_ARGS (const octave_gradient&, const octave_ ## t &);\
		return f (v1, v2.clone ()); \
	}

#define DEFBOP_XG(o, t, f) \
	DEFBINOP (o ## _ ## t ## _g, t, gradient) \
	{ \
		CAST_BINOP_ARGS (const octave_ ## t &, const octave_gradient &);\
		return f (v1.clone (), v2); \
	}

#define FORW_BOOL_OP(t, o) \
	DEFBINOP (o ## _g_ ## t, gradient, t) \
	{ \
		CAST_BINOP_ARGS (const octave_gradient&, const octave_ ## t &); \
		return op_ ## o (v1.x (), v2.clone ()); \
	} \
	DEFBINOP (o ## _ ## t ## _g, t, gradient) \
	{ \
		CAST_BINOP_ARGS (const octave_ ## t &, const octave_gradient &); \
		return op_ ## o (v1.clone (), v2.x()); \
	}

#define FORWARD_ALL_BOOLEAN_OPS(t) \
	FORW_BOOL_OP (t, lt) \
	FORW_BOOL_OP (t, le) \
	FORW_BOOL_OP (t, eq) \
	FORW_BOOL_OP (t, ge) \
	FORW_BOOL_OP (t, gt) \
	FORW_BOOL_OP (t, ne) \

#define ASSIGNOP(t) \
	DEFASSIGNOP (g_ ## t, gradient, t) \
	{ \
		CAST_BINOP_ARGS (octave_gradient&, const octave_ ## t &); \
		v1.assign (idx, v2); \
		return octave_value (); \
	}

#define CONCAT_GX(t) \
	DEFCATOP (g_ ## t, octave_gradient, octave_ ## t) \
	{ \
		CAST_BINOP_ARGS (octave_gradient&, const octave_ ## t &); \
		return new octave_gradient (do_cat_op (v1.x (), octave_value (v2.clone ()), ra_idx), v1.dx ()); \
	}

/* error messages */

static const char * mismatching_ops =
	"AD: operands differ in number of derivatives";

static const char * op_pow_restriction =
	"AD ^: both operands must be scalar or, if op1 is square, op2 must be a non-negative integer";

static const char * op_div_restriction =
	"AD /: operand 2 must have maximal rank";

static const char * op_ldiv_restriction =
	"AD \\: operand 1 must have maximal rank";

/* static variables and auxiliary functions */

// [:, x] used for column indexing
static octave_value_list cperm =
	octave_value_list(2, octave_value::magic_colon_t);

// [x, :] used for row indexing
static octave_value_list rperm =
	octave_value_list(2, octave_value::magic_colon_t);

static
octave_value diag_mx_mul (const octave_value& m, const octave_value& v)
{
	if (v.is_scalar_type ())
		return v * m;
	const dim_vector& dv = m.dims ();
	if (dv(1) == 1)
		return m * v.reshape (dim_vector (1, v.numel ()));
	rperm(0) = NDArray (dim_vector (1, dv(0)), 1.0);
	return op_el_mul (m, 
		v.reshape (dim_vector (1, v.numel ())).do_index_op (rperm));
}

static inline 
octave_value resh (const octave_value& v, const dim_vector& dv)
	{ return v.is_scalar_type () ? v : v.reshape (dv); }

static inline
octave_value cj (const octave_value& v)
	{ return v.is_real_type () ? v : feval ("conj", v, 1)(0); }

static inline 
octave_value re (const octave_value& v)
	{ return v.is_real_type () ? v : feval ("real", v, 1)(0); }

static inline
octave_value sigma (octave_idx_type nr, octave_idx_type nc)
{
  if (nr == 1 || nc == 1)
    return octave_value::magic_colon_t;

  ColumnVector a (nr*nc);

  octave_idx_type k, v, i, j;
  k = 0;
  for (i = 1; i <= nr; i++)
    {
      v = i;
      for (j = 0; j < nc; j++)
        {
          a(k++) = v;
          v += nr;
        }
    }
  return octave_value (a);
}

/* unary gradient ops */

DEFUNOP (uminus, gradient)
{
	CAST_UNOP_ARG (const octave_gradient&);
	return new octave_gradient (op_uminus (v.x ()), op_uminus (v.dx ()));
}

DEFUNOP (transpose, gradient)
{
	CAST_UNOP_ARG (const octave_gradient&);
	const octave_value& tmp = op_transpose (v.x ());
	if (!error_state)
	{
		// op is 2d
		const dim_vector& dv = v.dims ();
		cperm(1) = sigma (dv(0), dv(1));
		return new octave_gradient (tmp,
			octave_value (v.dx ()).do_index_op (cperm));
	}
	return octave_value ();
}

DEFUNOP (hermitian, gradient)
{
	CAST_UNOP_ARG (const octave_gradient&);
	const octave_value& tmp = op_hermitian (v.x ());
	if (!error_state)
	{
		// op is 2d
		const dim_vector& dv = v.dims ();
		cperm(1) = sigma (dv(0), dv(1));
		return new octave_gradient (tmp, cj (v.dx ()).do_index_op (cperm));
	}
	return octave_value ();
}

DEFUNOP (not, gradient)
{
  CAST_UNOP_ARG (const octave_gradient&);
  return op_not (v.x ());
}

/* gradient by scalar ops */

static inline
octave_value add_g_s (const octave_gradient& g, const octave_value& s)
	{	return new octave_gradient (g.x () + s, g.dx ()); }

static inline
octave_value add_s_g (const octave_value& s, const octave_gradient& g)
	{	return new octave_gradient (s + g.x (), g.dx ()); }

static inline
octave_value sub_g_s (const octave_gradient& g, const octave_value& s)
	{	return new octave_gradient (g.x () - s, g.dx ()); }

static inline
octave_value sub_s_g (const octave_value& s, const octave_gradient& g)
	{	return new octave_gradient (s - g.x (), - g.dx ()); }

DEFBOP_GX (add, scalar, add_g_s)
DEFBOP_GX (add, complex, add_g_s)
DEFBOP_XG (add, scalar, add_s_g)
DEFBOP_XG (add, complex, add_s_g)
DEFBOP_GX (sub, scalar, sub_g_s)
DEFBOP_GX (sub, complex, sub_g_s)
DEFBOP_XG (sub, scalar, sub_s_g)
DEFBOP_XG (sub, complex, sub_s_g)

static inline
octave_value mul_g_s (const octave_gradient& g, const octave_value& s)
	{	return new octave_gradient (g.x () * s, g.dx () * s); }

static inline 
octave_value mul_s_g (const octave_value& s, const octave_gradient& g)
	{	return new octave_gradient (s * g.x (), s * g.dx ()); }

static inline
octave_value div_g_s (const octave_gradient& g, const octave_value& s)
	{	return new octave_gradient (g.x () / s, g.dx () / s); }

static inline 
octave_value div_s_g (const octave_value& s, const octave_gradient& g)
{
	const octave_value& cx = s / g.x ();
	if (!error_state)
	{
		if (g.is_scalar_type ())
			return new octave_gradient (cx, (-cx / g.x ()) * g.dx ());
	
		const octave_value& tmp1 = 
			re (g.dx () * (2 * cj (g.x ())));
		const octave_value& tmp2 = 
			op_hermitian (g.x ());

		double  d = (tmp2 * g.x ()).scalar_value ();
		Complex c = s.complex_value () / d;
		const octave_value& tmp3 = (-c / d) * tmp1;
		return new octave_gradient (cx,	tmp3 * tmp2 + cj (g.dx ()) * c);
	}
	return octave_value (); 
}

static inline 
octave_value ldiv_g_s (const octave_gradient& g, const octave_value& s)
{
	const octave_value& cx = op_ldiv (g.x (), s);
	if (!error_state)
	{
		if (g.is_scalar_type ())
			return new octave_gradient (cx, (-cx / g.x ()) * g.dx ());

		const octave_value& tmp1 = op_hermitian (g.x ());
		const octave_value& tmp2 = re (g.dx () * (2 * tmp1));

		double  d = (g.x () * tmp1).scalar_value ();
		Complex c = s.complex_value () / d;
		const octave_value& tmp3 = (-c / d) * tmp2;
		return new octave_gradient (cx, cj (g.dx ()) * c + tmp3 * cj (g.x ()));
	}
	return octave_value (); 
}

static inline 
octave_value ldiv_s_g (const octave_value& s, const octave_gradient& g)
	{	return new octave_gradient (op_ldiv (s, g.x ()), op_ldiv (s, g.dx ())); }

DEFBOP_GX (mul, scalar, mul_g_s)
DEFBOP_GX (mul, complex, mul_g_s)
DEFBOP_XG (mul, scalar, mul_s_g)
DEFBOP_XG (mul, complex, mul_s_g)
DEFBOP_GX (div, scalar, div_g_s)
DEFBOP_GX (div, complex, div_g_s)
DEFBOP_XG (div, scalar, div_s_g)
DEFBOP_XG (div, complex, div_s_g)
DEFBOP_GX (ldiv, scalar, ldiv_g_s)
DEFBOP_GX (ldiv, complex, ldiv_g_s)
DEFBOP_XG (ldiv, scalar, ldiv_s_g)
DEFBOP_XG (ldiv, complex, ldiv_s_g)

DEFBINOPX (mul_g_g, gradient, gradient);

static inline 
octave_value pow_g_s (const octave_gradient& g, const octave_value& s)
{
	if (g.is_scalar_type ())
	{
		const octave_value& cx = op_pow (g.x (), s);
		if (!error_state)
		{
			return new octave_gradient (cx,
				g.dx () * (s * op_pow (g.x (), s.complex_value () - 1.0)));
		}
		return octave_value ();
	}
	// allow gradient ^ non-negative integer
	// poor performance
	
	const dim_vector& dv = g.dims ();
	if (dv(0) == dv(1) && dv(0) * dv(1) == dv.numel () && s.is_real_type ())
	{
		double d = s.scalar_value ();
		octave_idx_type val = static_cast<octave_idx_type>(d);
		if (val == d && val >= 0)
		{
			if (val == 0)
				return identity_matrix (dv(0), dv(0));
			if (val == 1)
				return new octave_gradient (g);

			octave_value tmp = g.clone ();
			octave_value ret = g.clone ();
			val--;
			while (1)
			{
				if (val & 1)
					ret = oct_binop_mul_g_g (ret.get_rep (), tmp.get_rep ());
				if (!(val >>= 1))
					break;
				tmp = oct_binop_mul_g_g (tmp.get_rep (), tmp.get_rep ());
			}
			return ret;
		}
	}
	error (op_pow_restriction);
	return octave_value ();
}

static inline 
octave_value pow_s_g (const octave_value& s, const octave_gradient& g)
{
	const octave_value& cx = op_pow (s, g.x ());
	if (!error_state)
	{
		if (g.is_scalar_type ())
		{
			return new octave_gradient (cx,
				(cx.complex_value () * log (s.complex_value ())) * g.dx ());
		}
		else error (op_pow_restriction);
	}
	return octave_value (); 
}

DEFBOP_GX (pow, scalar, pow_g_s)
DEFBOP_GX (pow, complex, pow_g_s)
DEFBOP_XG (pow, scalar, pow_s_g)
DEFBOP_XG (pow, complex, pow_s_g)

static inline 
octave_value el_div_s_g (const octave_value& s, const octave_gradient& g)
{
	const octave_value& cx = op_el_div (s, g.x ());
	if (!error_state)
	{
		return new octave_gradient (cx,
			diag_mx_mul (g.dx (), op_el_div (-cx, g.x ())));
	}
	return octave_value ();
}

static inline 
octave_value el_pow_g_s (const octave_gradient& g, const octave_value& s)
{
	const octave_value& cx = op_el_pow (g.x (), s);
	if (!error_state)
	{
		return new octave_gradient (cx,
			diag_mx_mul (g.dx (), s * op_el_pow (g.x (), s.complex_value () - 1.0)));
	}
	return octave_value ();
}

static inline 
octave_value el_pow_s_g (const octave_value& s, const octave_gradient& g)
{
	const octave_value& cx = op_el_pow (s, g.x ());
	if (!error_state)
	{
		return new octave_gradient (cx,
			diag_mx_mul (g.dx (), log (s.complex_value ()) * cx));
	}
	return octave_value ();
}

DEFBOP_XG (el_div, scalar, el_div_s_g)
DEFBOP_XG (el_div, complex, el_div_s_g)
DEFBOP_GX (el_pow, scalar, el_pow_g_s)
DEFBOP_GX (el_pow, complex, el_pow_g_s)
DEFBOP_XG (el_pow, scalar, el_pow_s_g)
DEFBOP_XG (el_pow, complex, el_pow_s_g)

/* boolean operators */

FORWARD_ALL_BOOLEAN_OPS (scalar)
FORWARD_ALL_BOOLEAN_OPS (complex)

/* non-dependent assignment*/

ASSIGNOP (scalar)
ASSIGNOP (complex)

/* concatenation */

CONCAT_GX (scalar)
CONCAT_GX (complex)

/* type conversion */

#define CONV_XG_TYPE(t) \
  DEFCONV (g_ ## t, t, gradient) \
  { \
    CAST_CONV_ARG (const octave_ ## t &); \
    return new octave_gradient (v.clone (), octave_gradient::constant); \
  }

CONV_XG_TYPE (scalar)
CONV_XG_TYPE (complex)
CONV_XG_TYPE (matrix)
CONV_XG_TYPE (complex_matrix)
CONV_XG_TYPE (sparse_matrix)
CONV_XG_TYPE (sparse_complex_matrix)

static
void install_grs_ops (void)
{
	INSTALL_BINOP (op_lt, octave_gradient, octave_scalar, lt_g_scalar);
	INSTALL_BINOP (op_le, octave_gradient, octave_scalar, le_g_scalar);
	INSTALL_BINOP (op_eq, octave_gradient, octave_scalar, eq_g_scalar);
	INSTALL_BINOP (op_ge, octave_gradient, octave_scalar, ge_g_scalar);
	INSTALL_BINOP (op_gt, octave_gradient, octave_scalar, gt_g_scalar);
	INSTALL_BINOP (op_ne, octave_gradient, octave_scalar, ne_g_scalar);

	INSTALL_BINOP (op_add, octave_gradient, octave_scalar, add_g_scalar);
	INSTALL_BINOP (op_sub, octave_gradient, octave_scalar, sub_g_scalar);
	INSTALL_BINOP (op_mul, octave_gradient, octave_scalar, mul_g_scalar);
	INSTALL_BINOP (op_div, octave_gradient, octave_scalar, div_g_scalar);
	INSTALL_BINOP (op_ldiv, octave_gradient, octave_scalar, ldiv_g_scalar);
	INSTALL_BINOP (op_pow, octave_gradient, octave_scalar, pow_g_scalar);
	INSTALL_BINOP (op_el_mul, octave_gradient, octave_scalar, mul_g_scalar);
	INSTALL_BINOP (op_el_div, octave_gradient, octave_scalar, div_g_scalar);
	INSTALL_BINOP (op_el_pow, octave_gradient, octave_scalar, el_pow_g_scalar);

	INSTALL_BINOP (op_lt, octave_scalar, octave_gradient, lt_scalar_g);
	INSTALL_BINOP (op_le, octave_scalar, octave_gradient, le_scalar_g);
	INSTALL_BINOP (op_eq, octave_scalar, octave_gradient, eq_scalar_g);
	INSTALL_BINOP (op_ge, octave_scalar, octave_gradient, ge_scalar_g);
	INSTALL_BINOP (op_gt, octave_scalar, octave_gradient, gt_scalar_g);
	INSTALL_BINOP (op_ne, octave_scalar, octave_gradient, ne_scalar_g);

	INSTALL_BINOP (op_add, octave_scalar, octave_gradient, add_scalar_g);
	INSTALL_BINOP (op_sub, octave_scalar, octave_gradient, sub_scalar_g);
	INSTALL_BINOP (op_mul, octave_scalar, octave_gradient, mul_scalar_g);
	INSTALL_BINOP (op_div, octave_scalar, octave_gradient, div_scalar_g);
	INSTALL_BINOP (op_ldiv, octave_scalar, octave_gradient, ldiv_scalar_g);
	INSTALL_BINOP (op_pow, octave_scalar, octave_gradient, pow_scalar_g);
	INSTALL_BINOP (op_el_mul, octave_scalar, octave_gradient, mul_scalar_g);
	INSTALL_BINOP (op_el_div, octave_scalar, octave_gradient, el_div_scalar_g);
	INSTALL_BINOP (op_el_pow, octave_scalar, octave_gradient, el_pow_scalar_g);

	INSTALL_ASSIGNOP (op_asn_eq, octave_gradient, octave_scalar, g_scalar); 
	INSTALL_CATOP (octave_gradient, octave_scalar, g_scalar);

	INSTALL_ASSIGNCONV (octave_scalar, octave_gradient, octave_gradient);
	INSTALL_WIDENOP (octave_scalar, octave_gradient, g_scalar);
}

static
void install_gcs_ops (void)
{
	INSTALL_BINOP (op_lt, octave_gradient, octave_complex, lt_g_complex);
	INSTALL_BINOP (op_le, octave_gradient, octave_complex, le_g_complex);
	INSTALL_BINOP (op_eq, octave_gradient, octave_complex, eq_g_complex);
	INSTALL_BINOP (op_ge, octave_gradient, octave_complex, ge_g_complex);
	INSTALL_BINOP (op_gt, octave_gradient, octave_complex, gt_g_complex);
	INSTALL_BINOP (op_ne, octave_gradient, octave_complex, ne_g_complex);

	INSTALL_BINOP (op_add, octave_gradient, octave_complex, add_g_complex);
	INSTALL_BINOP (op_sub, octave_gradient, octave_complex, sub_g_complex);
	INSTALL_BINOP (op_mul, octave_gradient, octave_complex, mul_g_complex);
	INSTALL_BINOP (op_div, octave_gradient, octave_complex, div_g_complex);
	INSTALL_BINOP (op_ldiv, octave_gradient, octave_complex, ldiv_g_complex);
	INSTALL_BINOP (op_pow, octave_gradient, octave_complex, pow_g_complex);
	INSTALL_BINOP (op_el_mul, octave_gradient, octave_complex, mul_g_complex);
	INSTALL_BINOP (op_el_div, octave_gradient, octave_complex, div_g_complex);
	INSTALL_BINOP (op_el_pow, octave_gradient, octave_complex, el_pow_g_complex);

	INSTALL_BINOP (op_lt, octave_complex, octave_gradient, lt_complex_g);
	INSTALL_BINOP (op_le, octave_complex, octave_gradient, le_complex_g);
	INSTALL_BINOP (op_eq, octave_complex, octave_gradient, eq_complex_g);
	INSTALL_BINOP (op_ge, octave_complex, octave_gradient, ge_complex_g);
	INSTALL_BINOP (op_gt, octave_complex, octave_gradient, gt_complex_g);
	INSTALL_BINOP (op_ne, octave_complex, octave_gradient, ne_complex_g);

	INSTALL_BINOP (op_add, octave_complex, octave_gradient, add_complex_g);
	INSTALL_BINOP (op_sub, octave_complex, octave_gradient, sub_complex_g);
	INSTALL_BINOP (op_mul, octave_complex, octave_gradient, mul_complex_g);
	INSTALL_BINOP (op_div, octave_complex, octave_gradient, div_complex_g);
	INSTALL_BINOP (op_ldiv, octave_complex, octave_gradient, ldiv_complex_g);
	INSTALL_BINOP (op_pow, octave_complex, octave_gradient, pow_complex_g);
	INSTALL_BINOP (op_el_mul, octave_complex, octave_gradient, mul_complex_g);
	INSTALL_BINOP (op_el_div, octave_complex, octave_gradient, el_div_complex_g);
	INSTALL_BINOP (op_el_pow, octave_complex, octave_gradient, el_pow_complex_g);

	INSTALL_ASSIGNOP (op_asn_eq, octave_gradient, octave_complex, g_complex);
	INSTALL_CATOP (octave_gradient, octave_complex, g_complex);

	INSTALL_ASSIGNCONV (octave_complex, octave_gradient, octave_gradient);
	INSTALL_WIDENOP (octave_complex, octave_gradient, g_scalar);
}

/* gradient by matrix ops */

static inline
octave_value add_g_mx (const octave_gradient& g, const octave_value& m)
{
  if (g.is_scalar_type ())
    {
      cperm(1) = ColumnVector (m.numel (), 1.0);
      return new octave_gradient (
        g.x () + m, octave_value (g.dx ()).do_index_op (cperm));
    }
  return new octave_gradient (g.x () + m, g.dx ());
}

static inline 
octave_value add_mx_g (const octave_value& m, const octave_gradient& g) 
{
  if (g.is_scalar_type ())
    {
      cperm(1) = ColumnVector (m.numel (), 1.0);
      return new octave_gradient (
        m + g.x (), octave_value (g.dx ()).do_index_op (cperm));
    }
  return new octave_gradient (m + g.x (), g.dx ());
}

static inline
octave_value sub_g_mx (const octave_gradient& g, const octave_value& m)
{
  if (g.is_scalar_type ())
    {
      cperm(1) = ColumnVector (m.numel (), 1.0);
      return new octave_gradient (
        g.x () - m, octave_value (g.dx ()).do_index_op (cperm));
    }
  return new octave_gradient (g.x () - m, g.dx ());
}

static inline 
octave_value sub_mx_g (const octave_value& m, const octave_gradient& g) 
{
  if (g.is_scalar_type ())
    {
      cperm(1) = ColumnVector (m.numel (), 1.0);
      return new octave_gradient (
        m - g.x (), octave_value (- g.dx ()).do_index_op (cperm));
    }
  return new octave_gradient (m - g.x (), - g.dx ());
}

DEFBOP_GX (add, matrix, add_g_mx)
DEFBOP_GX (sub, matrix, sub_g_mx)
DEFBOP_GX (add, complex_matrix, add_g_mx)
DEFBOP_GX (sub, complex_matrix, sub_g_mx)
DEFBOP_XG (add, matrix, add_mx_g)
DEFBOP_XG (sub, matrix, sub_mx_g)
DEFBOP_XG (add, complex_matrix, add_mx_g)
DEFBOP_XG (sub, complex_matrix, sub_mx_g)

DEFBOP_GX (add, sparse_matrix, add_g_mx)
DEFBOP_GX (sub, sparse_matrix, sub_g_mx)
DEFBOP_GX (add, sparse_complex_matrix, add_g_mx)
DEFBOP_GX (sub, sparse_complex_matrix, sub_g_mx)
DEFBOP_XG (add, sparse_matrix, add_mx_g)
DEFBOP_XG (sub, sparse_matrix, sub_mx_g)
DEFBOP_XG (add, sparse_complex_matrix, add_mx_g)
DEFBOP_XG (sub, sparse_complex_matrix, sub_mx_g)

static
octave_value mul_g_mx (const octave_gradient& g, const octave_value& m)
{
	const octave_value& cx = g.x () * m;
	if (!error_state)
	{
		if (g.is_scalar_type ())
		{
			return new octave_gradient (cx,
				g.dx () * m.reshape (dim_vector (1, m.numel ())));
		}
		const dim_vector& dv1 = g.dims ();
		const dim_vector& dv2 = m.dims ();

		octave_idx_type nd = g.nderv ();
		octave_idx_type ar = dv1(0);
		octave_idx_type ac = dv1(1);
		octave_idx_type bc = dv2(1);

		return new octave_gradient (cx,
			(g.dx ().reshape (dim_vector (nd*ar, ac)) * m).reshape (dim_vector (nd, ar*bc)));
	}
	return octave_value ();
}

static
octave_value mul_mx_g (const octave_value& m, const octave_gradient& g)
{
	const octave_value& cx = m * g.x ();
	if (!error_state)
	{
		if (g.is_scalar_type ())
		{
			return new octave_gradient (cx,
				g.dx () * m.reshape (dim_vector (1, m.numel ())));
		}
		const dim_vector& dv1 = m.dims ();
		const dim_vector& dv2 = g.dims ();

		octave_idx_type nd = g.nderv ();
		octave_idx_type ar = dv1(0);
		octave_idx_type ac = dv1(1);
		octave_idx_type bc = dv2(1);

		rperm(0) = sigma (nd, ac);
		const octave_value& tmp =
			m * g.dx ().reshape (dim_vector (nd*ac, bc)).do_index_op (rperm).
			reshape (dim_vector (ac, nd*bc));

		rperm(0) = sigma (ar, nd);
		return new octave_gradient (cx,
			tmp.reshape (dim_vector (ar*nd, bc)).do_index_op (rperm).reshape (dim_vector (nd, ar*bc)));
	}
	return octave_value ();
}

DEFBOP_GX (mul, matrix, mul_g_mx)
DEFBOP_GX (mul, complex_matrix, mul_g_mx)
DEFBOP_XG (mul, matrix, mul_mx_g)
DEFBOP_XG (mul, complex_matrix, mul_mx_g)

DEFBOP_GX (mul, sparse_matrix, mul_g_mx)
DEFBOP_GX (mul, sparse_complex_matrix, mul_g_mx)
DEFBOP_XG (mul, sparse_matrix, mul_mx_g)
DEFBOP_XG (mul, sparse_complex_matrix, mul_mx_g)

static
octave_value div_g_mx (const octave_gradient& g, const octave_value& m)
{
	int old_wstate, new_wstate;
	old_wstate = warning_state;
	warning_state = 0;
	const octave_value& cx = g.x () / m;
	new_wstate = warning_state;
	warning_state |= old_wstate;

	if (!error_state)
	{
		if (g.is_scalar_type () && m.ndims () > 2)
		{	
			// e.g rand () / rand ([4,3,2]), instead of ./
			// this is currently (speaking of 2.9.19) not supported 
			// by octave, but may be so in the future for consistency 
			// with matlab (R2007b)
			const octave_value& tmp = op_el_div (1.0, m);
			return new octave_gradient (cx, diag_mx_mul (g.dx (), tmp));
		}
		if (!new_wstate)
		{
			const dim_vector dv1 = g.dims ();
			const dim_vector dv2 = m.dims ();

			octave_idx_type nd = g.nderv ();
			octave_idx_type ar = dv1(0);
			octave_idx_type br = dv2(0);
			octave_idx_type nc = dv2(1);
		
			if (br < nc)
			{
				// overdetermined case
				// c = (a*b') / (b*b')
				const octave_value& tmp1 = op_hermitian (m);

				rperm(0) = sigma (nd, ar);
				const octave_value& tmp2 = 
					(g.dx ().reshape (dim_vector (nd*ar, nc)) * tmp1).do_index_op (rperm);

				rperm(0) = sigma (ar, nd);
				return new octave_gradient (cx,
					(tmp2 / (m * tmp1)).do_index_op (rperm).reshape (dim_vector (nd, ar*br)));
			}
			if (br > nc)
			{
				// underdetermined case
				// c = (a / (b'*b)) * b'
				const octave_value& tmp1 = op_hermitian (m);

				rperm(0) = sigma (nd, ar);
				const octave_value& tmp2 =
					g.dx ().reshape (dim_vector (nd*ar, nc)).do_index_op (rperm);

				rperm(0) = sigma (ar, nd);
				return new octave_gradient (cx,
					((tmp2 / (tmp1 * m)).do_index_op (rperm) * tmp1).reshape (dim_vector (nd, ar*br)));
			}
			// op2 is square
			rperm(0) = sigma (nd, ar);
			const octave_value& tmp =
				g.dx ().reshape (dim_vector (nd*ar, nc)).do_index_op (rperm);

			rperm(0) = sigma (ar, nd);
			return new octave_gradient (cx,
				(tmp / m).do_index_op (rperm).reshape (dim_vector (nd, ar*br)));
		}
		error (op_div_restriction);
	}
	return octave_value ();
}

static
octave_value div_mx_g (const octave_value& m, const octave_gradient& g)
{
	int old_wstate, new_wstate;
	old_wstate = warning_state;
	warning_state = 0;
	const octave_value& cx = m / g.x ();
	new_wstate = warning_state;
	warning_state |= old_wstate;

	if (!error_state)
	{	
		if (!new_wstate)
		{
			const dim_vector dv1 = m.dims ();
			const dim_vector dv2 = g.dims ();

			octave_idx_type nd = g.nderv ();
			octave_idx_type ar = dv1(0);
			octave_idx_type br = dv2(0);
			octave_idx_type nc = dv2(1);

			if (br * nc == 1)
			{
				// op2 is scalar
				return new octave_gradient (cx, 
					((g.dx () / (-g.x ())) * resh (cx, dim_vector (1, cx.numel ()))));
			}
			if (br < nc)
			{
				// overdetermined case
				// c = (a*b') / (b*b')
				const octave_value& tmp1 = g.dx ().reshape (dim_vector (nd*br, nc));
				const octave_value& tmp2 = op_hermitian (g.x ());
				const octave_value& tmp3 = (tmp1 * tmp2).reshape (dim_vector (nd, br*br));

				// (b*b').dx
				cperm(1) = sigma (br, br);
				const octave_value& tmp4 =
					tmp3 + cj (tmp3).do_index_op (cperm);

				// (a*b').dx
				cperm(1) = sigma (br, ar);
				const octave_value& tmp5 =
					(cj (tmp1) * op_transpose (m)).reshape (dim_vector (nd, br*ar)).do_index_op (cperm);

				cperm(1) = sigma (br, nd);
				const octave_value& tmp6 =
					(op_transpose (tmp5).reshape (dim_vector (ar, nd*br)) -
					cx * op_transpose (tmp4).reshape (dim_vector (br, br*nd))).do_index_op (cperm);

				rperm(0) = sigma (ar, nd);
				return new octave_gradient (cx,
					(tmp6.reshape (dim_vector (ar*nd, br)) / (g.x () * tmp2)).
					do_index_op (rperm).reshape (dim_vector (nd, ar*br)));
			}
			if (br > nc)
			{
				// underdetermined case
				// (b'*b).dx
				cperm(1) = sigma (br, nc);
				const octave_value& tmp1 =
					cj (g.dx ()).do_index_op (cperm).reshape (dim_vector (nd*nc, br));

				const octave_value& tmp2 =
					(tmp1 * g.x ()).reshape (dim_vector (nd, nc*nc));

				cperm(1) = sigma (nc, nc);
				const octave_value& tmp3 =
					tmp2 + cj (tmp2).do_index_op (cperm);

				// (a / (b*b')).dx
				const octave_value& tmp0 = op_hermitian (g.x ());
				const octave_value& tmp4 = tmp0 * g.x ();
				const octave_value& tmp5 = m / tmp4;

				cperm(1) = sigma (nc, nd);
				const octave_value& tmp6 =
					((-tmp5) * op_transpose (tmp3).reshape (dim_vector (nc, nc*nd))).
					do_index_op (cperm);

				rperm(0) = sigma (ar, nd);
				const octave_value& tmp7 =
					(tmp6.reshape (dim_vector (ar*nd, nc)) / tmp4).do_index_op (rperm);

				// (a / (b'*b)) * b'
				cperm(1) = sigma (br, ar);
				return new octave_gradient (cx,
					(tmp7 * tmp0).reshape (dim_vector (nd, ar*br)) + 
					(cj (g.dx ()).reshape (dim_vector (nd*br, nc)) * op_transpose (tmp5)).
					reshape (dim_vector (nd, br*ar)).do_index_op (cperm));
			}
			// op2 is square
			cperm(1) = sigma (nc, nd);
			const octave_value& tmp =
				(-cx * op_transpose (g.dx ()).reshape (dim_vector (br, nc*nd))).
				do_index_op (cperm);

			rperm(0) = sigma (ar, nd);
			return new octave_gradient (cx,
				(tmp.reshape (dim_vector (ar*nd, nc)) / g.x ()).
				do_index_op (rperm).reshape (dim_vector (nd, ar*br)));
		}
		error (op_div_restriction);
    }
    return octave_value ();
}

static 
octave_value ldiv_g_mx (const octave_gradient& g, const octave_value& m)
{
	int old_wstate, new_wstate;
	old_wstate = warning_state;
    warning_state = 0;
    const octave_value& cx = op_ldiv (g.x (), m);
    new_wstate = warning_state;
    warning_state |= old_wstate;
   
    if (!error_state)
    {
		if (!new_wstate)
		{
			const dim_vector dv1 = g.dims ();
			const dim_vector dv2 = m.dims ();

			octave_idx_type nd = g.nderv ();
			octave_idx_type nr = dv1(0);
			octave_idx_type ac = dv1(1);
			octave_idx_type bc = dv2(1);
		
			if (nr * ac == 1)
			{
				// gradient is scalar
				return new octave_gradient (cx, ((g.dx () / (-g.x ())) *
					resh (cx, dim_vector (1, cx.numel ()))));
			}
			if (nr > ac)
			{
				// overdetermined case
				cperm(1) = sigma (nr, ac);
				const octave_value& tmp1 =
					cj (g.dx ()).do_index_op (cperm).reshape (dim_vector (nd*ac, nr));

				const octave_value& tmp2 =
					(tmp1 * g.x ()).reshape (dim_vector (nd, ac*ac));
		
				cperm(1) = sigma (ac, ac);
				const octave_value& tmp3 =
					tmp2 + cj (tmp2).do_index_op (cperm);
	
				rperm(0) = sigma (nd, ac);
				const octave_value& tmp4 =
					tmp3.reshape (dim_vector (nd*ac, ac)).do_index_op (rperm) * cx;
		
				cperm(1) = sigma (nd, bc);
				return new octave_gradient (cx,
					op_transpose (op_ldiv (op_hermitian (g.x ()) * g.x (),
					op_transpose ((tmp1 * m).reshape (dim_vector (nd, ac*bc))).reshape (dim_vector (ac, nd*bc)) -
					tmp4.reshape (dim_vector (ac, nd*bc)).do_index_op (cperm)).reshape (dim_vector (ac*bc, nd))));
			}
			if (nr < ac)
			{
				// underdetermined case
				const octave_value& tmp1 = op_hermitian (g.x ());
				const octave_value& tmp2 = g.x () * tmp1;
				const octave_value& tmp5 = op_ldiv (tmp2, m);

				const octave_value& tmp3 =
					(g.dx ().reshape (dim_vector (nd*nr, ac)) * tmp1).reshape (dim_vector (nd, nr*nr));

				cperm(1) = sigma (nr, nr);
				const octave_value& tmp4 =
					tmp3 + cj (tmp3).do_index_op (cperm);

				rperm(0) = sigma (nd, nr);
				const octave_value& tmp6 =
					tmp4.reshape (dim_vector (nd*nr, nr)).do_index_op (rperm) * tmp5;

				cperm(1) = sigma (nd, bc);
				const octave_value& tmp7 =
					op_transpose (op_ldiv (tmp2, -tmp6.reshape (dim_vector (nr, nd*bc)).
					do_index_op (cperm)).reshape (dim_vector (nr*bc, nd)));

				cperm(1) = sigma (nr, bc);
				const octave_value& tmp8 = 
					octave_value (tmp7).do_index_op (cperm).reshape (dim_vector (nd*bc, nr)) * cj (g.x ());
				
				cperm(1) = sigma (bc, ac);
				const octave_value& tmp9 =
					tmp8.reshape (dim_vector (nd, bc*ac)).do_index_op (cperm);

				cperm(1) = sigma (nr, ac);
				return new octave_gradient (cx, 
					(cj (g.dx ()).do_index_op (cperm).reshape (dim_vector (nd*ac, nr)) * tmp5).
					reshape (dim_vector (nd, ac*bc)) + tmp9);
			}
			// gradient is square (but not scalar)
			rperm(0) = sigma (nd, nr);
			const octave_value& tmp =
				g.dx ().reshape (dim_vector (nd*nr, ac)).do_index_op (rperm) * cx;

			cperm(1) = sigma (nd, bc);
			return new octave_gradient (cx,
				op_transpose (op_ldiv (g.x (), -tmp.reshape (dim_vector (nr, nd*bc)).
				do_index_op (cperm)).reshape (dim_vector (nr*bc, nd))));
		}
		error (op_ldiv_restriction);
	}
	return octave_value ();
}

static
octave_value ldiv_mx_g (const octave_value& m, const octave_gradient& g)
{
    int old_wstate, new_wstate;
	old_wstate = warning_state;
    warning_state = 0;
    const octave_value& cx = op_ldiv (m, g.x ());
    new_wstate = warning_state;
    warning_state |= old_wstate;
    
	if (!error_state)
    {
		if (g.is_scalar_type () && m.ndims () > 2)
		{	
			// e.g rand ([4,3,2]) \ rand (), instead of .\
			// this is currently (speaking of 2.9.19) not supported 
			// by octave, but may be so in the future for consistency 
			// with matlab (R2007b)
			const octave_value& tmp = op_el_div (1.0, m);
			return new octave_gradient (cx, diag_mx_mul (g.dx (), tmp));
		}
		if (!new_wstate)
		{
			const dim_vector dv1 = m.dims ();
			const dim_vector dv2 = g.dims ();

			octave_idx_type nd = g.nderv ();
			octave_idx_type nr = dv1(0);
			octave_idx_type ac = dv1(1);
			octave_idx_type bc = dv2(1);

			if (nr > ac)
			{
				// overdetermined case
				cperm(1) = sigma (nr, bc);
				const octave_value& tmp =
					cj (g.dx ()).do_index_op (cperm).
					reshape (dim_vector (nd*bc, nr)) * m;

				rperm(0) = sigma (nd, bc);
				return new octave_gradient (cx,
					op_hermitian (op_div (octave_value (tmp).do_index_op (rperm), 
					op_hermitian (m) * m).reshape (dim_vector (bc, nd*ac))).
					reshape (dim_vector (nd, ac*bc)));
			}
			if (nr < ac)
			{
				// underdetermined case
				cperm(1) = sigma (nr, bc);
				const octave_value& tmp =
					op_transpose (op_ldiv (m * op_hermitian (m), op_transpose (g.dx ()).
					reshape (dim_vector (nr, nd*bc))).reshape (dim_vector (nr*bc, nd))).
					do_index_op (cperm).reshape (dim_vector (nd*bc, nr)) * cj (m);

				cperm(1) = sigma (bc, ac);
				return new octave_gradient (cx,
					tmp.reshape (dim_vector (nd, bc*ac)).do_index_op (cperm));
			}
			// matrix is square
			return new octave_gradient (cx,
				op_transpose (op_ldiv (m, op_transpose (g.dx ()).
				reshape (dim_vector (nr, bc*nd))).reshape (dim_vector (nr*bc, nd))));
		}
		error (op_ldiv_restriction);
	}
    return octave_value ();
}

DEFBOP_GX (div, matrix, div_g_mx)
DEFBOP_GX (div, complex_matrix, div_g_mx)
DEFBOP_XG (div, matrix, div_mx_g)
DEFBOP_XG (div, complex_matrix, div_mx_g)
DEFBOP_GX (ldiv, matrix, ldiv_g_mx)
DEFBOP_GX (ldiv, complex_matrix, ldiv_g_mx)
DEFBOP_XG (ldiv, matrix, ldiv_mx_g)
DEFBOP_XG (ldiv, complex_matrix, ldiv_mx_g)

DEFBOP_GX (div, sparse_matrix, div_g_mx)
DEFBOP_GX (div, sparse_complex_matrix, div_g_mx)
DEFBOP_XG (div, sparse_matrix, div_mx_g)
DEFBOP_XG (div, sparse_complex_matrix, div_mx_g)
DEFBOP_GX (ldiv, sparse_matrix, ldiv_g_mx)
DEFBOP_GX (ldiv, sparse_complex_matrix, ldiv_g_mx)
DEFBOP_XG (ldiv, sparse_matrix, ldiv_mx_g)
DEFBOP_XG (ldiv, sparse_complex_matrix, ldiv_mx_g)

static inline
octave_value prod_g_mx (const octave_gradient& g, const octave_value& m)
{
	const octave_value& cx = op_el_mul (g.x (), m);
	if (!error_state)
		return new octave_gradient (cx, diag_mx_mul (g.dx (), m));
	return octave_value ();
}

static inline
octave_value prod_mx_g (const octave_value& m, const octave_gradient& g) 
{ 
	const octave_value& cx = op_el_mul (m, g.x ());
	if (!error_state)
		return new octave_gradient (cx, diag_mx_mul (g.dx (), m));
	return octave_value ();
}

DEFBOP_GX (el_mul, matrix, prod_g_mx)
DEFBOP_GX (el_mul, complex_matrix, prod_g_mx)
DEFBOP_XG (el_mul, matrix, prod_mx_g)
DEFBOP_XG (el_mul, complex_matrix, prod_mx_g)

DEFBOP_GX (el_mul, sparse_matrix, prod_g_mx)
DEFBOP_GX (el_mul, sparse_complex_matrix, prod_g_mx)
DEFBOP_XG (el_mul, sparse_matrix, prod_mx_g)
DEFBOP_XG (el_mul, sparse_complex_matrix, prod_mx_g)

static
octave_value quot_g_mx (const octave_gradient& g, const octave_value& m)
{
	const octave_value& cx = op_el_div (g.x (), m);
	if (!error_state)
	{
		const octave_value& tmp = op_el_div (1.0, m);
		return new octave_gradient (cx, diag_mx_mul (g.dx (), tmp));
	}
	return octave_value ();
}

static
octave_value quot_mx_g (const octave_value& m, const octave_gradient& g)
{
	const octave_value& cx = op_el_div (m, g.x ());
	if (!error_state)
	{
		return new octave_gradient (cx,
			diag_mx_mul (g.dx (), op_el_div (-cx, g.x ())));
	}
	return octave_value ();
}

DEFBOP_GX (el_div, matrix, quot_g_mx)
DEFBOP_GX (el_div, complex_matrix, quot_g_mx)
DEFBOP_XG (el_div, matrix, quot_mx_g)
DEFBOP_XG (el_div, complex_matrix, quot_mx_g)

DEFBOP_GX (el_div, sparse_matrix, quot_g_mx)
DEFBOP_GX (el_div, sparse_complex_matrix, quot_g_mx)
DEFBOP_XG (el_div, sparse_matrix, quot_mx_g)
DEFBOP_XG (el_div, sparse_complex_matrix, quot_mx_g)

static
octave_value el_pow_g_mx (const octave_gradient& g, const octave_value& m)
{
	const octave_value& cx = op_el_pow (g.x (), m);
	if (!error_state)
	{
		const octave_value& tmp = 
			op_el_mul (m, op_el_pow (g.x (), m - 1.0));
		return new octave_gradient (cx, diag_mx_mul (g.dx (), tmp));
	}
	return octave_value ();
}

static
octave_value el_pow_mx_g (const octave_value& m, const octave_gradient& g)
{
	const octave_value& cx = op_el_pow (m, g.x ());
	if (!error_state)
	{
		const octave_value_list& tmp = feval ("log", m, 1);
		return new octave_gradient (cx,
			diag_mx_mul (g.dx (), op_el_mul (cx, tmp(0))));
	}
	return octave_value ();
}

DEFBOP_GX (el_pow, matrix, el_pow_g_mx)
DEFBOP_GX (el_pow, complex_matrix, el_pow_g_mx)
DEFBOP_XG (el_pow, matrix, el_pow_mx_g)
DEFBOP_XG (el_pow, complex_matrix, el_pow_mx_g)

DEFBOP_GX (el_pow, sparse_matrix, el_pow_g_mx)
DEFBOP_GX (el_pow, sparse_complex_matrix, el_pow_g_mx)
DEFBOP_XG (el_pow, sparse_matrix, el_pow_mx_g)
DEFBOP_XG (el_pow, sparse_complex_matrix, el_pow_mx_g)

/* boolean operators */

FORWARD_ALL_BOOLEAN_OPS (matrix)
FORWARD_ALL_BOOLEAN_OPS (complex_matrix)
FORWARD_ALL_BOOLEAN_OPS (sparse_matrix)
FORWARD_ALL_BOOLEAN_OPS (sparse_complex_matrix)

/* non dependent assigment*/

ASSIGNOP (matrix)
ASSIGNOP (complex_matrix)
ASSIGNOP (sparse_matrix)
ASSIGNOP (sparse_complex_matrix)

/* concatenation */

CONCAT_GX (matrix)
CONCAT_GX (complex_matrix)
CONCAT_GX (sparse_matrix)
CONCAT_GX (sparse_complex_matrix)

DEFCATOPX(g_g, octave_gradient, octave_gradient);
#define CONCAT_MG(t) \
  DEFCATOP (t ## _g, octave_ ## t, octave_gradient) \
  { \
    CAST_BINOP_ARGS (const octave_ ## t &, const octave_gradient&); \
	octave_gradient tmp (v1.clone (), octave_gradient::constant); \
    return oct_catop_g_g (tmp, v2, ra_idx); \
  }

CONCAT_MG (matrix)
CONCAT_MG (complex_matrix)
CONCAT_MG (sparse_matrix)
CONCAT_MG (sparse_complex_matrix)

static
void install_grm_ops (void)
{
	INSTALL_BINOP (op_lt, octave_gradient, octave_matrix, lt_g_matrix);
	INSTALL_BINOP (op_le, octave_gradient, octave_matrix, le_g_matrix);
	INSTALL_BINOP (op_eq, octave_gradient, octave_matrix, eq_g_matrix);
	INSTALL_BINOP (op_ge, octave_gradient, octave_matrix, ge_g_matrix);
	INSTALL_BINOP (op_gt, octave_gradient, octave_matrix, gt_g_matrix);
	INSTALL_BINOP (op_ne, octave_gradient, octave_matrix, ne_g_matrix);

	INSTALL_BINOP (op_add, octave_gradient, octave_matrix, add_g_matrix);
	INSTALL_BINOP (op_sub, octave_gradient, octave_matrix, sub_g_matrix);
	INSTALL_BINOP (op_mul, octave_gradient, octave_matrix, mul_g_matrix);
	INSTALL_BINOP (op_div, octave_gradient, octave_matrix, div_g_matrix);
	INSTALL_BINOP (op_ldiv, octave_gradient, octave_matrix, ldiv_g_matrix);
	INSTALL_BINOP (op_el_mul, octave_gradient, octave_matrix, el_mul_g_matrix);
	INSTALL_BINOP (op_el_div, octave_gradient, octave_matrix, el_div_g_matrix);
	INSTALL_BINOP (op_el_pow, octave_gradient, octave_matrix, el_pow_g_matrix);

	INSTALL_BINOP (op_lt, octave_matrix, octave_gradient, lt_matrix_g);
	INSTALL_BINOP (op_le, octave_matrix, octave_gradient, le_matrix_g);
	INSTALL_BINOP (op_eq, octave_matrix, octave_gradient, eq_matrix_g);
	INSTALL_BINOP (op_ge, octave_matrix, octave_gradient, ge_matrix_g);
	INSTALL_BINOP (op_gt, octave_matrix, octave_gradient, gt_matrix_g);
	INSTALL_BINOP (op_ne, octave_matrix, octave_gradient, ne_matrix_g);

	INSTALL_BINOP (op_add, octave_matrix, octave_gradient, add_matrix_g);
	INSTALL_BINOP (op_sub, octave_matrix, octave_gradient, sub_matrix_g);
	INSTALL_BINOP (op_mul, octave_matrix, octave_gradient, mul_matrix_g);
	INSTALL_BINOP (op_div, octave_matrix, octave_gradient, div_matrix_g);
	INSTALL_BINOP (op_ldiv, octave_matrix, octave_gradient, ldiv_matrix_g);
	INSTALL_BINOP (op_el_mul, octave_matrix, octave_gradient, el_mul_matrix_g);
	INSTALL_BINOP (op_el_div, octave_matrix, octave_gradient, el_div_matrix_g);
	INSTALL_BINOP (op_el_pow, octave_matrix, octave_gradient, el_pow_matrix_g);

	INSTALL_ASSIGNOP (op_asn_eq, octave_gradient, octave_matrix, g_matrix);
	INSTALL_CATOP (octave_gradient, octave_matrix, g_matrix);
	INSTALL_CATOP (octave_matrix, octave_gradient, matrix_g);

	INSTALL_ASSIGNCONV (octave_matrix, octave_gradient, octave_gradient);
	INSTALL_WIDENOP (octave_matrix, octave_gradient, g_matrix);
}

static
void install_gcm_ops (void)
{
	  INSTALL_BINOP (op_lt, octave_gradient, octave_complex_matrix, lt_g_complex_matrix);
	  INSTALL_BINOP (op_le, octave_gradient, octave_complex_matrix, le_g_complex_matrix);
	  INSTALL_BINOP (op_eq, octave_gradient, octave_complex_matrix, eq_g_complex_matrix);
	  INSTALL_BINOP (op_ge, octave_gradient, octave_complex_matrix, ge_g_complex_matrix);
	  INSTALL_BINOP (op_gt, octave_gradient, octave_complex_matrix, gt_g_complex_matrix);
	  INSTALL_BINOP (op_ne, octave_gradient, octave_complex_matrix, ne_g_complex_matrix);

	  INSTALL_BINOP (op_add, octave_gradient, octave_complex_matrix, add_g_complex_matrix);
	  INSTALL_BINOP (op_sub, octave_gradient, octave_complex_matrix, sub_g_complex_matrix);
	  INSTALL_BINOP (op_mul, octave_gradient, octave_complex_matrix, mul_g_complex_matrix);
	  INSTALL_BINOP (op_div, octave_gradient, octave_complex_matrix, div_g_complex_matrix);
	  INSTALL_BINOP (op_ldiv, octave_gradient, octave_complex_matrix, ldiv_g_complex_matrix);
	  INSTALL_BINOP (op_el_mul, octave_gradient, octave_complex_matrix, el_mul_g_complex_matrix);
	  INSTALL_BINOP (op_el_div, octave_gradient, octave_complex_matrix, el_div_g_complex_matrix);
	  INSTALL_BINOP (op_el_pow, octave_gradient, octave_complex_matrix, el_pow_g_complex_matrix);

	  INSTALL_BINOP (op_lt, octave_complex_matrix, octave_gradient, lt_complex_matrix_g);
	  INSTALL_BINOP (op_le, octave_complex_matrix, octave_gradient, le_complex_matrix_g);
	  INSTALL_BINOP (op_eq, octave_complex_matrix, octave_gradient, eq_complex_matrix_g);
	  INSTALL_BINOP (op_ge, octave_complex_matrix, octave_gradient, ge_complex_matrix_g);
	  INSTALL_BINOP (op_gt, octave_complex_matrix, octave_gradient, gt_complex_matrix_g);
	  INSTALL_BINOP (op_ne, octave_complex_matrix, octave_gradient, ne_complex_matrix_g);

	  INSTALL_BINOP (op_add, octave_complex_matrix, octave_gradient, add_complex_matrix_g);
	  INSTALL_BINOP (op_sub, octave_complex_matrix, octave_gradient, sub_complex_matrix_g);
	  INSTALL_BINOP (op_mul, octave_complex_matrix, octave_gradient, mul_complex_matrix_g);
	  INSTALL_BINOP (op_div, octave_complex_matrix, octave_gradient, div_complex_matrix_g);
	  INSTALL_BINOP (op_ldiv, octave_complex_matrix, octave_gradient, ldiv_complex_matrix_g);
	  INSTALL_BINOP (op_el_mul, octave_complex_matrix, octave_gradient, el_mul_complex_matrix_g);
	  INSTALL_BINOP (op_el_div, octave_complex_matrix, octave_gradient, el_div_complex_matrix_g);
	  INSTALL_BINOP (op_el_pow, octave_complex_matrix, octave_gradient, el_pow_complex_matrix_g);

	  INSTALL_ASSIGNOP (op_asn_eq, octave_gradient, octave_complex_matrix, g_complex_matrix);
	  INSTALL_CATOP (octave_gradient, octave_complex_matrix, g_complex_matrix);
	  INSTALL_CATOP (octave_complex_matrix, octave_gradient, complex_matrix_g);

	  INSTALL_ASSIGNCONV (octave_complex_matrix, octave_gradient, octave_gradient);
	  INSTALL_WIDENOP (octave_complex_matrix, octave_gradient, g_complex_matrix);
}

static
void install_gsrm_ops (void)
{
	INSTALL_BINOP (op_lt, octave_gradient, octave_sparse_matrix, lt_g_sparse_matrix);
	INSTALL_BINOP (op_le, octave_gradient, octave_sparse_matrix, le_g_sparse_matrix);
	INSTALL_BINOP (op_eq, octave_gradient, octave_sparse_matrix, eq_g_sparse_matrix);
	INSTALL_BINOP (op_ge, octave_gradient, octave_sparse_matrix, ge_g_sparse_matrix);
	INSTALL_BINOP (op_gt, octave_gradient, octave_sparse_matrix, gt_g_sparse_matrix);
	INSTALL_BINOP (op_ne, octave_gradient, octave_sparse_matrix, ne_g_sparse_matrix);

	INSTALL_BINOP (op_add, octave_gradient, octave_sparse_matrix, add_g_sparse_matrix);
	INSTALL_BINOP (op_sub, octave_gradient, octave_sparse_matrix, sub_g_sparse_matrix);
	INSTALL_BINOP (op_mul, octave_gradient, octave_sparse_matrix, mul_g_sparse_matrix);
	INSTALL_BINOP (op_div, octave_gradient, octave_sparse_matrix, div_g_sparse_matrix);
	INSTALL_BINOP (op_ldiv, octave_gradient, octave_sparse_matrix, ldiv_g_sparse_matrix);
	INSTALL_BINOP (op_el_mul, octave_gradient, octave_sparse_matrix, el_mul_g_sparse_matrix);
	INSTALL_BINOP (op_el_div, octave_gradient, octave_sparse_matrix, el_div_g_sparse_matrix);
	INSTALL_BINOP (op_el_pow, octave_gradient, octave_sparse_matrix, el_pow_g_sparse_matrix);

	INSTALL_BINOP (op_lt, octave_sparse_matrix, octave_gradient, lt_sparse_matrix_g);
	INSTALL_BINOP (op_le, octave_sparse_matrix, octave_gradient, le_sparse_matrix_g);
	INSTALL_BINOP (op_eq, octave_sparse_matrix, octave_gradient, eq_sparse_matrix_g);
	INSTALL_BINOP (op_ge, octave_sparse_matrix, octave_gradient, ge_sparse_matrix_g);
	INSTALL_BINOP (op_gt, octave_sparse_matrix, octave_gradient, gt_sparse_matrix_g);
	INSTALL_BINOP (op_ne, octave_sparse_matrix, octave_gradient, ne_sparse_matrix_g);

	INSTALL_BINOP (op_add, octave_sparse_matrix, octave_gradient, add_sparse_matrix_g);
	INSTALL_BINOP (op_sub, octave_sparse_matrix, octave_gradient, sub_sparse_matrix_g);
	INSTALL_BINOP (op_mul, octave_sparse_matrix, octave_gradient, mul_sparse_matrix_g);
	INSTALL_BINOP (op_div, octave_sparse_matrix, octave_gradient, div_sparse_matrix_g);
	INSTALL_BINOP (op_ldiv, octave_sparse_matrix, octave_gradient, ldiv_sparse_matrix_g);
	INSTALL_BINOP (op_el_mul, octave_sparse_matrix, octave_gradient, el_mul_sparse_matrix_g);
	INSTALL_BINOP (op_el_div, octave_sparse_matrix, octave_gradient, el_div_sparse_matrix_g);
	INSTALL_BINOP (op_el_pow, octave_sparse_matrix, octave_gradient, el_pow_sparse_matrix_g);

	INSTALL_ASSIGNOP (op_asn_eq, octave_gradient, octave_sparse_matrix, g_sparse_matrix);
	INSTALL_CATOP (octave_gradient, octave_sparse_matrix, g_sparse_matrix);
	INSTALL_CATOP (octave_sparse_matrix, octave_gradient, sparse_matrix_g);

	INSTALL_ASSIGNCONV (octave_sparse_matrix, octave_gradient, octave_gradient);
	INSTALL_WIDENOP (octave_sparse_matrix, octave_gradient, g_sparse_matrix);
}

static
void install_gscm_ops (void)
{
	  INSTALL_BINOP (op_lt, octave_gradient, octave_sparse_complex_matrix, lt_g_sparse_complex_matrix);
	  INSTALL_BINOP (op_le, octave_gradient, octave_sparse_complex_matrix, le_g_sparse_complex_matrix);
	  INSTALL_BINOP (op_eq, octave_gradient, octave_sparse_complex_matrix, eq_g_sparse_complex_matrix);
	  INSTALL_BINOP (op_ge, octave_gradient, octave_sparse_complex_matrix, ge_g_sparse_complex_matrix);
	  INSTALL_BINOP (op_gt, octave_gradient, octave_sparse_complex_matrix, gt_g_sparse_complex_matrix);
	  INSTALL_BINOP (op_ne, octave_gradient, octave_sparse_complex_matrix, ne_g_sparse_complex_matrix);

	  INSTALL_BINOP (op_add, octave_gradient, octave_sparse_complex_matrix, add_g_sparse_complex_matrix);
	  INSTALL_BINOP (op_sub, octave_gradient, octave_sparse_complex_matrix, sub_g_sparse_complex_matrix);
	  INSTALL_BINOP (op_mul, octave_gradient, octave_sparse_complex_matrix, mul_g_sparse_complex_matrix);
	  INSTALL_BINOP (op_div, octave_gradient, octave_sparse_complex_matrix, div_g_sparse_complex_matrix);
	  INSTALL_BINOP (op_ldiv, octave_gradient, octave_sparse_complex_matrix, ldiv_g_sparse_complex_matrix);
	  INSTALL_BINOP (op_el_mul, octave_gradient, octave_sparse_complex_matrix, el_mul_g_sparse_complex_matrix);
	  INSTALL_BINOP (op_el_div, octave_gradient, octave_sparse_complex_matrix, el_div_g_sparse_complex_matrix);
	  INSTALL_BINOP (op_el_pow, octave_gradient, octave_sparse_complex_matrix, el_pow_g_sparse_complex_matrix);

	  INSTALL_BINOP (op_lt, octave_sparse_complex_matrix, octave_gradient, lt_sparse_complex_matrix_g);
	  INSTALL_BINOP (op_le, octave_sparse_complex_matrix, octave_gradient, le_sparse_complex_matrix_g);
	  INSTALL_BINOP (op_eq, octave_sparse_complex_matrix, octave_gradient, eq_sparse_complex_matrix_g);
	  INSTALL_BINOP (op_ge, octave_sparse_complex_matrix, octave_gradient, ge_sparse_complex_matrix_g);
	  INSTALL_BINOP (op_gt, octave_sparse_complex_matrix, octave_gradient, gt_sparse_complex_matrix_g);
	  INSTALL_BINOP (op_ne, octave_sparse_complex_matrix, octave_gradient, ne_sparse_complex_matrix_g);

	  INSTALL_BINOP (op_add, octave_sparse_complex_matrix, octave_gradient, add_sparse_complex_matrix_g);
	  INSTALL_BINOP (op_sub, octave_sparse_complex_matrix, octave_gradient, sub_sparse_complex_matrix_g);
	  INSTALL_BINOP (op_mul, octave_sparse_complex_matrix, octave_gradient, mul_sparse_complex_matrix_g);
	  INSTALL_BINOP (op_div, octave_sparse_complex_matrix, octave_gradient, div_sparse_complex_matrix_g);
	  INSTALL_BINOP (op_ldiv, octave_sparse_complex_matrix, octave_gradient, ldiv_sparse_complex_matrix_g);
	  INSTALL_BINOP (op_el_mul, octave_sparse_complex_matrix, octave_gradient, el_mul_sparse_complex_matrix_g);
	  INSTALL_BINOP (op_el_div, octave_sparse_complex_matrix, octave_gradient, el_div_sparse_complex_matrix_g);
	  INSTALL_BINOP (op_el_pow, octave_sparse_complex_matrix, octave_gradient, el_pow_sparse_complex_matrix_g);

	  INSTALL_ASSIGNOP (op_asn_eq, octave_gradient, octave_sparse_complex_matrix, g_sparse_complex_matrix);
	  INSTALL_CATOP (octave_gradient, octave_sparse_complex_matrix, g_sparse_complex_matrix);
	  INSTALL_CATOP (octave_sparse_complex_matrix, octave_gradient, sparse_complex_matrix_g);

	  INSTALL_ASSIGNCONV (octave_sparse_complex_matrix, octave_gradient, octave_gradient);
	  INSTALL_WIDENOP (octave_sparse_complex_matrix, octave_gradient, g_sparse_complex_matrix);
}

/* gradient by gradient ops */

DEFBINOP (mul_g_g, gradient, gradient) 
{
	CAST_BINOP_ARGS (const octave_gradient&, const octave_gradient&);
	const octave_value& cx = v1.x () * v2.x ();
	if (!error_state)
	{
		if (v1.nderv () == v2.nderv ())
		{
			// one op may be n-d
			if (v1.is_scalar_type ())
			{
				return new octave_gradient (cx,
					v1.dx () * resh (v2.x (), dim_vector (1, v2.numel ())) + 
					op_el_mul (v1.x (), v2.dx ()));
			}
			if (v2.is_scalar_type ())
			{
				return new octave_gradient (cx,
					v2.dx () * resh (v1.x (), dim_vector (1, v1.numel ())) + 
					op_el_mul (v2.x (), v1.dx ()));
			}
			// ops are 2d
			const dim_vector& dv1 = v1.dims ();
			const dim_vector& dv2 = v2.dims ();

			octave_idx_type nd = v1.nderv ();
			octave_idx_type ar = dv1(0);
			octave_idx_type ac = dv1(1);
			octave_idx_type bc = dv2(1);

			if (ar == 1 && bc == 1)
			{
				//  scalar product
				return new octave_gradient (cx,
					v1.dx () * v2.x () + v2.dx () * resh (v1.x (), dim_vector (ac, 1)));
			}
			// general case

#if defined(PREFER_COLPERM)
			// (1) implementation with column-permutations

			 cperm(1) = sigma (ac, bc);
			 const octave_value& tmp =
					octave_value (v2.dx ()).do_index_op (cperm).
					reshape (dim_vector (nd*bc, ac)) * op_transpose (v1.x ());

			 cperm(1) = sigma (bc, ar);
			 return new octave_gradient (cx,
					(v1.dx ().reshape (dim_vector (nd*ar, ac)) * v2.x ()).reshape (dim_vector (nd, ar*bc)) +
					tmp.reshape (dim_vector (nd, bc*ar)).do_index_op (cperm));
#else
			// (2) alternative implementation with row-permutations
			// - saving one transposal at the expense of two additional reshapes
			// - reshape is done in constant time for dense matrices, but not for sparse ones
			// tradeoff?
			
			rperm(0) = sigma (nd, ac);
			const octave_value& tmp =
				v1.x () * v2.dx ().reshape (dim_vector (nd*ac, bc)).do_index_op (rperm).
				reshape (dim_vector (ac, nd*bc));

			rperm(0) = sigma (ar, nd);
			return new octave_gradient (cx,
				(v1.dx ().reshape (dim_vector (nd*ar, ac)) * v2.x ()).reshape (dim_vector (nd, ar*bc)) +
				tmp.reshape (dim_vector (ar*nd, bc)).do_index_op (rperm).reshape (dim_vector (nd, ar*bc)));
#endif
		}
		else error (mismatching_ops);
	}
	return octave_value ();
}

DEFBINOP (el_mul_g_g, gradient, gradient)
{
	CAST_BINOP_ARGS (const octave_gradient&, const octave_gradient&);
	const octave_value& tmp = op_el_mul (v1.x (), v2.x ());
	if (!error_state)
	{
		if (v1.nderv () == v2.nderv ())
		{
			return new octave_gradient (tmp,
				diag_mx_mul (v1.dx (), v2.x ()) + diag_mx_mul (v2.dx (), v1.x ()));
		}
		else error (mismatching_ops);
	}
	return octave_value ();
}

DEFBINOP (div_g_g, gradient, gradient)
{
	CAST_BINOP_ARGS (const octave_gradient&, const octave_gradient&);
	int old_wstate, new_wstate;
	old_wstate = warning_state;
	warning_state = 0;
	const octave_value& cx = v1.x () / v2.x ();
	new_wstate = warning_state;
	warning_state |= old_wstate;

	if (!error_state)
	{
		octave_idx_type nd = v1.nderv ();
		if (nd == v2.nderv ())
		{
			if (!new_wstate)
			{
				const dim_vector& dv1 = v1.dims ();
				const dim_vector& dv2 = v2.dims ();
				octave_idx_type ar = dv1(0);
				octave_idx_type br = dv2(0);
				octave_idx_type nc = dv2(1);

				if (br * nc == 1)
				{
					// op2 is scalar
					return new octave_gradient (cx,
						(v1.dx () - v2.dx () * resh (cx, dim_vector (1, cx.numel ()))) / v2.x ());
				}
				if (br < nc)
				{
					// overdetermined case
					// C = (a*b') / (b*b')
					const octave_value& tmp1 = v2.dx ().reshape (dim_vector (nd*br, nc));
					const octave_value& tmp2 = op_hermitian (v2.x ());
					const octave_value& tmp3 = (tmp1 * tmp2).reshape (dim_vector (nd, br*br));

					// (b*b').dx
					cperm(1) = sigma (br, br);
					const octave_value& tmp4 =
						tmp3 + cj (tmp3).do_index_op (cperm);

					// (a*b').dx
					cperm(1) = sigma (br, ar);
					const octave_value& tmp5 =
						(v1.dx ().reshape (dim_vector (nd*ar, nc)) * tmp2).reshape (dim_vector (nd, ar*br)) + 
						(cj (tmp1) * op_transpose (v1.x ())).reshape (dim_vector (nd, br*ar)).do_index_op (cperm);

					cperm(1) = sigma (br, nd);
					const octave_value& tmp6 =
						(op_transpose (tmp5).reshape (dim_vector (ar, nd*br)) -
						cx * op_transpose (tmp4).reshape (dim_vector (br, br*nd))).do_index_op (cperm);

					rperm(0) = sigma (ar, nd);
					return new octave_gradient (cx,
						(tmp6.reshape (dim_vector (ar*nd, br)) / (v2.x () * tmp2)).
						do_index_op (rperm).reshape (dim_vector (nd, ar*br)));
				}
				if (br > nc)
				{
					// underdetermined case
					// (b'*b).dx
					cperm(1) = sigma (br, nc);
					const octave_value& tmp1 =
						cj (v2.dx ()).do_index_op (cperm).reshape (dim_vector (nd*nc, br));

					const octave_value& tmp2 =
						(tmp1 * v2.x ()).reshape (dim_vector (nd, nc*nc));

					cperm(1) = sigma (nc, nc);
					const octave_value& tmp3 =
						tmp2 + cj (tmp2).do_index_op (cperm);

					// (a / b'*b).dx
					const octave_value& tmp0 = op_hermitian (v2.x ());
					const octave_value& tmp4 = tmp0 * v2.x ();
					const octave_value& tmp5 = v1.x () / tmp4;

					cperm(1) = sigma (nc, nd);
					const octave_value& tmp6 =
						(op_transpose (v1.dx ()).reshape (dim_vector (ar, nc*nd)) -
						tmp5 * op_transpose (tmp3).reshape (dim_vector (nc, nc*nd))).
						do_index_op (cperm);

					rperm(0) = sigma (ar, nd);
					const octave_value& tmp7 =
						(tmp6.reshape (dim_vector (ar*nd, nc)) / tmp4).do_index_op (rperm);

					// (a / b'*b) * b'
					cperm(1) = sigma (br, ar);
					return new octave_gradient (cx,
						(tmp7 * tmp0).reshape (dim_vector (nd, ar*br)) + 
						(cj (v2.dx ()).reshape (dim_vector (nd*br, nc)) * op_transpose (tmp5)).
						reshape (dim_vector (nd, br*ar)).do_index_op (cperm));
				}
				// op2 is square
				cperm(1) = sigma (nc, nd);
				const octave_value& tmp =
					(op_transpose (v1.dx ()).reshape (dim_vector (ar, nc*nd)) -
					cx * op_transpose (v2.dx ()).reshape (dim_vector (br, nc*nd))).
					do_index_op (cperm);

				rperm(0) = sigma (ar, nd);
				return new octave_gradient (cx,
					(tmp.reshape (dim_vector (ar*nd, nc)) / v2.x ()).
					do_index_op (rperm).reshape (dim_vector (nd, ar*br)));
			}
			else error (op_div_restriction);
		}
		else error (mismatching_ops);
	}
	return octave_value();
}

DEFBINOP (ldiv_g_g, gradient, gradient)
{
	CAST_BINOP_ARGS (const octave_gradient&, const octave_gradient&);
	int old_wstate, new_wstate;
	old_wstate = warning_state;
	warning_state = 0;
	const octave_value& cx = op_ldiv (v1.x (), v2.x ());
	new_wstate = warning_state;
	warning_state |= old_wstate;

	if (!error_state)
	{
		octave_idx_type nd = v1.nderv ();
		if (nd == v2.nderv ())
		{
			if (!new_wstate)
			{
				const dim_vector& dv1 = v1.dims ();
				const dim_vector& dv2 = v2.dims ();
				octave_idx_type nr = dv1(0);
				octave_idx_type ac = dv1(1);
				octave_idx_type bc = dv2(1);

				if (nr * ac == 1)
				{
					// op1 is scalar
					return new octave_gradient (cx,
						(v2.dx () - v1.dx () * resh (cx, dim_vector (1, cx.numel ()))) / v1.x ());
				}
				if (nr > ac)
				{
					// overdetermined case
					cperm(1) = sigma (nr, ac);
					const octave_value& tmp1 =
						cj (v1.dx ()).do_index_op (cperm).reshape (dim_vector (nd*ac, nr));

					const octave_value& tmp2 =
						(tmp1 * (v1.x ())).reshape (dim_vector (nd, ac*ac));

					cperm(1) = sigma (ac, ac);
					const octave_value& tmp3 =
						tmp2 + cj (tmp2).do_index_op (cperm);

					rperm(0) = sigma (nd, ac);
					const octave_value& tmp4 =
						tmp3.reshape (dim_vector (nd*ac, ac)).do_index_op (rperm) * cx;

					cperm(1) = sigma (nr, bc);
					const octave_value& tmp5 =
						octave_value (v2.dx ()).do_index_op (cperm).
						reshape (dim_vector (nd*bc, nr)) * cj (v1.x ());

					cperm(1) = sigma (bc, ac);
					const octave_value& tmp6 =
						(tmp1 * v2.x ()).reshape (dim_vector (nd, ac*bc)) + 
					     tmp5.reshape (dim_vector (nd, bc*ac)).do_index_op (cperm);

					cperm(1) = sigma (nd, bc);
					return new octave_gradient (cx,
						op_transpose (op_ldiv (op_hermitian (v1.x ()) * v1.x (), op_transpose (tmp6).
						reshape (dim_vector (ac, nd*bc)) - tmp4.reshape (dim_vector (ac, nd*bc)).
						do_index_op (cperm)).reshape (dim_vector (ac*bc, nd))));
				}
				if (nr < ac)
				{
					// underdetermined case
					const octave_value& tmp1 = op_hermitian (v1.x ());
					const octave_value& tmp2 = v1.x () * tmp1;
					const octave_value& tmp5 = op_ldiv (tmp2, v2.x ());

					const octave_value& tmp3 =
						(v1.dx ().reshape (dim_vector (nd*nr, ac)) * tmp1).reshape (dim_vector (nd, nr*nr));

					cperm(1) = sigma (nr, nr);
					const octave_value& tmp4 =
						tmp3 + cj (tmp3).do_index_op (cperm);

					rperm(0) = sigma (nd, nr);
					const octave_value& tmp6 =
						tmp4.reshape (dim_vector (nd*nr, nr)).do_index_op (rperm) * tmp5;

					cperm(1) = sigma (nd, bc);
					const octave_value& tmp7 =
						op_transpose (op_ldiv (tmp2, op_transpose (v2.dx ()).reshape (dim_vector (nr, bc*nd)) -
						tmp6.reshape (dim_vector (nr, nd*bc)).do_index_op (cperm)).reshape (dim_vector (nr*bc, nd)));

					cperm(1) = sigma (nr, bc);
					const octave_value& tmp8 = 
						octave_value (tmp7).do_index_op (cperm).reshape (dim_vector (nd*bc, nr)) * cj (v1.x ());
					
					cperm(1) = sigma (bc, ac);
					const octave_value& tmp9 =
						tmp8.reshape (dim_vector (nd, bc*ac)).do_index_op (cperm);

					cperm(1) = sigma (nr, ac);
					return new octave_gradient (cx, 
						(cj (v1.dx ()).do_index_op (cperm).reshape (dim_vector (nd*ac, nr)) * tmp5).
						reshape (dim_vector (nd, ac*bc)) + tmp9);
				}
				// op1 is square (but not scalar)
				rperm(0) = sigma (nd, nr);
				const octave_value& tmp =
					v1.dx ().reshape (dim_vector (nd*nr, ac)).do_index_op (rperm) * cx;		

				cperm(1) = sigma (nd, bc);
				return new octave_gradient (cx,
					op_transpose (op_ldiv (v1.x (), op_transpose (v2.dx ()).reshape (dim_vector (nr, bc*nd)) - 
					tmp.reshape (dim_vector (nr, nd*bc)).do_index_op (cperm)).reshape (dim_vector (nr*bc, nd))));
			}
			error (op_ldiv_restriction);
		}
		else error (mismatching_ops);
	}
	return octave_value ();
}

DEFBINOP (add_g_g, gradient, gradient)
{
	CAST_BINOP_ARGS (const octave_gradient&, const octave_gradient&);
	const octave_value& cx = v1.x () + v2.x ();
	if (!error_state)
	{
		if (v1.nderv () == v2.nderv ())
		{
			if (v1.is_scalar_type () && !v2.is_scalar_type ())
			{
				cperm(1) = NDArray (dim_vector(1, v2.numel ()), 1.0);
  				return new octave_gradient (
					cx,
					octave_value (v1.dx ()).do_index_op (cperm) + v2.dx ());
			}
			if (!v1.is_scalar_type () && v2.is_scalar_type ())
			{
				cperm(1) = NDArray (dim_vector (1, v1.numel ()), 1.0);
  				return new octave_gradient (
					cx,
					v1.dx () + octave_value (v2.dx ()).do_index_op (cperm));
			}
			return new octave_gradient (cx, v1.dx () + v2.dx ());
		}
		else error (mismatching_ops);
	}
	return octave_value ();
}

DEFBINOP (sub_g_g, gradient, gradient)
{
	CAST_BINOP_ARGS (const octave_gradient&, const octave_gradient&);
	const octave_value& cx = v1.x () - v2.x ();
	if (!error_state)
	{
		if (v1.nderv () == v2.nderv ())
		{
			if (v1.is_scalar_type () && !v2.is_scalar_type ())
			{
				cperm(1) = NDArray (dim_vector(1, v2.numel ()), 1.0);
  				return new octave_gradient (
					cx,
					octave_value (v1.dx ()).do_index_op (cperm) - v2.dx ());
			}
			if (!v1.is_scalar_type () && v2.is_scalar_type ())
			{
				cperm(1) = NDArray (dim_vector (1, v1.numel ()), 1.0);
  				return new octave_gradient (
					cx,
					v1.dx () - octave_value (v2.dx ()).do_index_op (cperm));
			}
			return new octave_gradient (cx, v1.dx () - v2.dx ());
		}
		else error (mismatching_ops);
	}
	return octave_value ();
}

DEFBINOP (el_div_g_g, gradient, gradient)
{
	CAST_BINOP_ARGS (const octave_gradient&, const octave_gradient&);
	const octave_value& cx = op_el_div (v1.x (), v2.x ());
	if (!error_state)
	{
		if (v1.nderv () == v2.nderv ())
		{
			if (v2.is_scalar_type ())
			{
				return new octave_gradient (cx,
					(v1.dx () - v2.dx () * resh (cx, dim_vector (1, cx.numel ()))) / v2.x ());
			}
			const octave_value& aux = op_el_div (1.0, v2.x ());
			if (v1.is_scalar_type ())
			{
				cperm(1) = NDArray (dim_vector (1, v2.numel ()), 1.0);
				return new octave_gradient (cx,
					diag_mx_mul (octave_value (v1.dx ()).do_index_op (cperm) - 
					diag_mx_mul (v2.dx (), cx), aux));
			}
			return new octave_gradient (cx,
				diag_mx_mul (v1.dx () - diag_mx_mul (v2.dx (), cx), aux));
		}
		else error (mismatching_ops);
	}
	return octave_value ();
}

DEFBINOP (pow_g_g, gradient, gradient)
{
	CAST_BINOP_ARGS (const octave_gradient&, const octave_gradient&);
	const octave_value& cx = op_pow (v1.x (), v2.x ());
	if (!error_state)
	{
		if (v1.nderv () == v2.nderv ())
		{
			if (v1.is_scalar_type () && v2.is_scalar_type ())
			{
				return new octave_gradient (cx, 
					(v2.x () * op_pow (v1.x (), v2.x () - 1.0)) * v1.dx () +
					(cx.complex_value () * log (v1.x ().complex_value ())) * v2.dx ());
			}
			error (op_pow_restriction);
		}
		else error (mismatching_ops);
	}
	return octave_value ();
}

DEFBINOP (el_pow_g_g, gradient, gradient)
{
	CAST_BINOP_ARGS (const octave_gradient&, const octave_gradient&);
	const octave_value& cx = op_el_pow (v1.x (), v2.x ());
	if (!error_state)
	{
		if (v1.nderv () == v2.nderv ())
		{
			if (v1.is_scalar_type () && v2.is_scalar_type ())
			{
				return new octave_gradient (cx, 
					(v2.x () * op_pow (v1.x (), v2.x () - 1.0)) * v1.dx () +
					(cx.complex_value () * log (v1.x ().complex_value ())) * v2.dx ());
			}
			const octave_value_list& retv =
				feval ("log", v1.x (), 1);
			const octave_value& aux1 =
				op_el_mul (v2.x (), op_el_pow (v1.x (), v2.x () - 1.0));
			const octave_value& aux2 =
				op_el_mul (cx, retv(0));

			return new octave_gradient (cx,
				diag_mx_mul (v1.dx (), aux1) + 
				diag_mx_mul (v2.dx (), aux2));
		}
		else error (mismatching_ops);
	}
	return octave_value();
}

/* boolean operators */

#undef FORW_BOOL_OP
#define FORW_BOOL_OP(t, o) \
	DEFBINOP (o ## _g_g, gradient, gradient) \
	{ \
		CAST_BINOP_ARGS (const octave_gradient&, const octave_gradient&); \
		return op_ ## o (v1.x(), v2.x()); \
	}

FORWARD_ALL_BOOLEAN_OPS ()

/* dependent assignment */

ASSIGNOP (gradient)

/* concatenation */

DEFCATOP (g_g, octave_gradient, octave_gradient)
{
  CAST_BINOP_ARGS (const octave_gradient&, const octave_gradient&);
  const octave_value& cx = do_cat_op (v1.x (), v2.x (), ra_idx);
  if (! error_state)
    {
      octave_idx_type nd = v1.nderv ();
      if (nd == v2.nderv ())
        {
          Array<octave_idx_type> idx (dim_vector (2, 1));
          const dim_vector& dv1 = v1.dims ();
          const dim_vector& dv2 = v2.dims ();
          octave_idx_type c = 1;
          octave_idx_type v = 0;
          for (octave_idx_type k = 1; k < ra_idx.length (); k++)
            {
              v += ra_idx(k) * c;
              c *= dv1(k);
            }
          idx(0) = ra_idx(0) * nd;
          idx(1) = v;
          return new octave_gradient (cx, do_cat_op (
            resh (v1.dx (), dim_vector (nd * dv1(0), dv1.numel () / dv1(0))),
            resh (v2.dx (), dim_vector (nd * dv2(0), dv2.numel () / dv2(0))), idx).
            reshape (dim_vector (nd, dv1.numel ())));
        }
      else
        error (mismatching_ops);
    }
  return octave_value ();
}

void install_gradient_ops (void)
{
	install_grs_ops ();
	install_gcs_ops ();
	install_grm_ops ();
	install_gcm_ops ();
	install_gsrm_ops ();
	install_gscm_ops ();

	INSTALL_UNOP (op_uminus, octave_gradient, uminus);
	INSTALL_UNOP (op_transpose, octave_gradient, transpose);
	INSTALL_UNOP (op_hermitian, octave_gradient, hermitian);
	INSTALL_UNOP (op_not, octave_gradient, not);

	INSTALL_BINOP (op_lt, octave_gradient, octave_gradient, lt_g_g);
	INSTALL_BINOP (op_le, octave_gradient, octave_gradient, le_g_g);
	INSTALL_BINOP (op_eq, octave_gradient, octave_gradient, eq_g_g);
	INSTALL_BINOP (op_ge, octave_gradient, octave_gradient, ge_g_g);
	INSTALL_BINOP (op_gt, octave_gradient, octave_gradient, gt_g_g);
	INSTALL_BINOP (op_ne, octave_gradient, octave_gradient, ne_g_g);

	INSTALL_BINOP (op_add, octave_gradient, octave_gradient, add_g_g);
	INSTALL_BINOP (op_sub, octave_gradient, octave_gradient, sub_g_g);
	INSTALL_BINOP (op_mul, octave_gradient, octave_gradient, mul_g_g);
	INSTALL_BINOP (op_div, octave_gradient, octave_gradient, div_g_g);
	INSTALL_BINOP (op_ldiv, octave_gradient, octave_gradient, ldiv_g_g);
	INSTALL_BINOP (op_pow, octave_gradient, octave_gradient, pow_g_g);
	INSTALL_BINOP (op_el_mul, octave_gradient, octave_gradient, el_mul_g_g);
	INSTALL_BINOP (op_el_div, octave_gradient, octave_gradient, el_div_g_g);
	INSTALL_BINOP (op_el_pow, octave_gradient, octave_gradient, el_pow_g_g);

	INSTALL_ASSIGNOP (op_asn_eq, octave_gradient, octave_gradient, g_gradient);
	INSTALL_CATOP (octave_gradient, octave_gradient, g_g);
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
