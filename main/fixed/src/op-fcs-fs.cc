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
#include <octave/gripes.h>
#include <octave/oct-obj.h>
#include <octave/ov.h>
#include <octave/ov-re-mat.h>
#include <octave/ov-typeinfo.h>
#include <octave/ops.h>

#include "int/fixed.h"
#include "ov-fixed.h"
#include "ov-fixed-complex.h"
#include "fixed-def.h"

// fixed complex scalar by fixed scalar ops.

FIXED_DEFBINOP_OP (add, fixed_complex, fixed, fixed_complex, +)
FIXED_DEFBINOP_OP (sub, fixed_complex, fixed, fixed_complex, -)
FIXED_DEFBINOP_OP (mul, fixed_complex, fixed, fixed_complex, *)

DEFBINOP (div, fixed_complex, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_complex&, const octave_fixed&);

  FixedPoint d = v2.fixed_value ();

  if (d.fixedpoint() == 0.0)
    gripe_divide_by_zero ();

  return new octave_fixed_complex (v1.fixed_complex_value () / d);
}

FIXED_DEFBINOP_FN (pow, fixed_complex, fixed, fixed_complex, pow)

DEFBINOP (ldiv, fixed_complex, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_complex&, const octave_fixed&);

  FixedPointComplex d = v1.fixed_complex_value ();

  if (d.fixedpoint() == 0.0)
    gripe_divide_by_zero ();

  return new octave_fixed_complex (v2.fixed_value () / d);
}


DEFBINOP (lt, fixed_complex, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_complex&, const octave_fixed&);

  return real (v1.fixed_complex_value ()) < v2.fixed_value ();
}

DEFBINOP (le, fixed_complex, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_complex&, const octave_fixed&);

  return real (v1.fixed_complex_value ()) <= v2.fixed_value ();
}

DEFBINOP (eq, fixed_complex, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_complex&, const octave_fixed&);

  return v1.fixed_complex_value () == v2.fixed_value ();
}

DEFBINOP (ge, fixed_complex, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_complex&, const octave_fixed&);

  return real (v1.fixed_complex_value ()) >= v2.fixed_value ();
}

DEFBINOP (gt, fixed_complex, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_complex&, const octave_fixed&);

  return real (v1.fixed_complex_value ()) > v2.fixed_value ();
}

DEFBINOP (ne, fixed_complex, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_complex&, const octave_fixed&);

  return v1.fixed_complex_value () != v2.fixed_value ();
}

FIXED_DEFBINOP_OP (el_mul, fixed_complex, fixed, fixed_complex, *)

DEFBINOP (el_div, fixed_complex, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_complex&, const octave_fixed&);

  FixedPoint d = v2.fixed_value ();

  if (d.fixedpoint() == 0.0)
    gripe_divide_by_zero ();

  return new octave_fixed_complex (v1.fixed_complex_value () / d);
}

FIXED_DEFBINOP_FN (el_pow, fixed_complex, fixed, fixed_complex, pow)

DEFBINOP (el_ldiv, fixed_complex, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_complex&, const octave_fixed&);

  FixedPointComplex d = v1.fixed_complex_value ();

  if (d.fixedpoint() == 0.0)
    gripe_divide_by_zero ();

  return new octave_fixed_complex (v2.fixed_value () / d);
}


DEFBINOP (el_and, fixed_complex, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_complex&, const octave_fixed&);
  FixedPointComplex d1 = v1.fixed_complex_value ();
  FixedPoint d2 = v2.fixed_value ();
  return octave_value ((d1.fixedpoint() != 0.0  && d2.fixedpoint () != 0.0));
}

DEFBINOP (el_or, fixed_complex, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_complex&, const octave_fixed&);
  FixedPointComplex d1 = v1.fixed_complex_value ();
  FixedPoint d2 = v2.fixed_value ();
  return octave_value ((d1.fixedpoint() != 0.0 || d2.fixedpoint () != 0.0));
}

FIXED_DEFCATOP_FN (fcs_fs, fixed_complex, fixed,
		   fixed_complex_matrix, fixed_matrix,
		   fixed_complex_matrix, concat)

OCTAVE_FIXED_API void
install_fcs_fs_ops (void)
{
  INSTALL_BINOP (op_add, octave_fixed_complex, octave_fixed, add);
  INSTALL_BINOP (op_sub, octave_fixed_complex, octave_fixed, sub);
  INSTALL_BINOP (op_mul, octave_fixed_complex, octave_fixed, mul);
  INSTALL_BINOP (op_div, octave_fixed_complex, octave_fixed, div);
  INSTALL_BINOP (op_pow, octave_fixed_complex, octave_fixed, pow);
  INSTALL_BINOP (op_ldiv, octave_fixed_complex, octave_fixed, ldiv);
  INSTALL_BINOP (op_lt, octave_fixed_complex, octave_fixed, lt);
  INSTALL_BINOP (op_le, octave_fixed_complex, octave_fixed, le);
  INSTALL_BINOP (op_eq, octave_fixed_complex, octave_fixed, eq);
  INSTALL_BINOP (op_ge, octave_fixed_complex, octave_fixed, ge);
  INSTALL_BINOP (op_gt, octave_fixed_complex, octave_fixed, gt);
  INSTALL_BINOP (op_ne, octave_fixed_complex, octave_fixed, ne);
  INSTALL_BINOP (op_el_mul, octave_fixed_complex, octave_fixed, el_mul);
  INSTALL_BINOP (op_el_div, octave_fixed_complex, octave_fixed, el_div);
  INSTALL_BINOP (op_el_pow, octave_fixed_complex, octave_fixed, el_pow);
  INSTALL_BINOP (op_el_ldiv, octave_fixed_complex, octave_fixed, el_ldiv);
  INSTALL_BINOP (op_el_and, octave_fixed_complex, octave_fixed, el_and);
  INSTALL_BINOP (op_el_or, octave_fixed_complex, octave_fixed, el_or);

  FIXED_INSTALL_CATOP (octave_fixed_complex, octave_fixed, fcs_fs);

  INSTALL_ASSIGNCONV (octave_fixed_complex, octave_fixed, 
		      octave_fixed_complex_matrix);

}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
