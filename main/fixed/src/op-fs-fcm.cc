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

#include "ov-fixed.h"
#include "ov-fixed-complex.h"
#include "ov-fixed-cx-mat.h"
#include "fixed-def.h"

// fixed scalar by fixed complex matrix ops.

FIXED_DEFBINOP_OP (add, fixed, fixed_complex_matrix, fixed_complex_matrix, +)
FIXED_DEFBINOP_OP (sub, fixed, fixed_complex_matrix, fixed_complex_matrix, -)
FIXED_DEFBINOP_OP (mul, fixed, fixed_complex_matrix, fixed_complex_matrix, *)

DEFBINOP (ldiv, fixed, fixed_complex_matrix)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed_complex_matrix&);

  FixedPoint f = v1.fixed_value ();

  if (f.fixedpoint() == 0.0)
    gripe_divide_by_zero ();

  return new octave_fixed_complex_matrix (v2.fixed_complex_matrix_value () 
					  / f);
}

DEFBINOP_FN (lt, fixed, fixed_complex_matrix, mx_el_lt)
DEFBINOP_FN (le, fixed, fixed_complex_matrix, mx_el_le)
DEFBINOP_FN (eq, fixed, fixed_complex_matrix, mx_el_eq)
DEFBINOP_FN (ge, fixed, fixed_complex_matrix, mx_el_ge)
DEFBINOP_FN (gt, fixed, fixed_complex_matrix, mx_el_gt)
DEFBINOP_FN (ne, fixed, fixed_complex_matrix, mx_el_ne)

FIXED_DEFBINOP_OP (el_mul, fixed, fixed_complex_matrix, 
		   fixed_complex_matrix, *)

DEFBINOP (el_div, fixed, fixed_complex_matrix)
{
  CAST_BINOP_ARGS (const octave_fixed&, 
		   const octave_fixed_complex_matrix&);

  FixedPoint f = v1.fixed_value ();

  boolMatrix no_zeros = (v2.fixed_complex_matrix_value().all()).all();
  if (!no_zeros(0,0))
    gripe_divide_by_zero ();

  return new octave_fixed_complex_matrix 
    (f / v2.fixed_complex_matrix_value ());
}


FIXED_DEFBINOP_FN (el_pow, fixed, fixed_complex_matrix, fixed_complex_matrix, 
		   elem_pow)

DEFBINOP (el_ldiv, fixed, fixed_complex_matrix)
{
  CAST_BINOP_ARGS (const octave_fixed&, 
		   const octave_fixed_complex_matrix&);

  FixedPoint f = v1.fixed_value ();

  if (f.fixedpoint() == 0.0)
    gripe_divide_by_zero ();

  return new octave_fixed_complex_matrix (v2.fixed_complex_matrix_value () 
					  / f);
}

DEFBINOP_FN (el_and, fixed, fixed_complex_matrix, mx_el_and)
DEFBINOP_FN (el_or, fixed, fixed_complex_matrix, mx_el_or)

FIXED_DEFCATOP_FN (fs_fcm, fixed, fixed_complex_matrix, 
		   fixed_matrix, fixed_complex_matrix,
		   fixed_complex_matrix, concat)

DEFCONV (fixed_complex_matrix_conv, fixed, fixed_complex_matrix)
{
  CAST_CONV_ARG (const octave_fixed&);

  return new octave_fixed_complex_matrix (v.fixed_complex_matrix_value ());
}

OCTAVE_FIXED_API void
install_fs_fcm_ops (void)
{
  INSTALL_BINOP (op_add, octave_fixed, octave_fixed_complex_matrix, 
		 add);
  INSTALL_BINOP (op_sub, octave_fixed, octave_fixed_complex_matrix, sub);
  INSTALL_BINOP (op_mul, octave_fixed, octave_fixed_complex_matrix, mul);
  INSTALL_BINOP (op_ldiv, octave_fixed, octave_fixed_complex_matrix, ldiv);
  INSTALL_BINOP (op_lt, octave_fixed, octave_fixed_complex_matrix, lt);
  INSTALL_BINOP (op_le, octave_fixed, octave_fixed_complex_matrix, le);
  INSTALL_BINOP (op_eq, octave_fixed, octave_fixed_complex_matrix, eq);
  INSTALL_BINOP (op_ge, octave_fixed, octave_fixed_complex_matrix, ge);
  INSTALL_BINOP (op_gt, octave_fixed, octave_fixed_complex_matrix, gt);
  INSTALL_BINOP (op_ne, octave_fixed, octave_fixed_complex_matrix, ne);
  INSTALL_BINOP (op_el_mul, octave_fixed, octave_fixed_complex_matrix, el_mul);
  INSTALL_BINOP (op_el_div, octave_fixed, octave_fixed_complex_matrix, el_div);
  INSTALL_BINOP (op_el_pow, octave_fixed, octave_fixed_complex_matrix, el_pow);
  INSTALL_BINOP (op_el_ldiv, octave_fixed, octave_fixed_complex_matrix,
		 el_ldiv);
  INSTALL_BINOP (op_el_and, octave_fixed, octave_fixed_complex_matrix, el_and);
  INSTALL_BINOP (op_el_or, octave_fixed, octave_fixed_complex_matrix, el_or);

  FIXED_INSTALL_CATOP (octave_fixed, octave_fixed_complex_matrix, fs_fcm);

  INSTALL_ASSIGNCONV (octave_fixed, octave_fixed_complex_matrix, 
		      octave_fixed_complex_matrix);

  INSTALL_WIDENOP (octave_fixed, octave_fixed_complex_matrix, 
		   fixed_complex_matrix_conv);
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
