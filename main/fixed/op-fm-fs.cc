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

#include <octave/gripes.h>
#include <octave/config.h>
#include <octave/oct-obj.h>
#include <octave/ov.h>
#include <octave/ov-re-mat.h>
#include <octave/ov-typeinfo.h>
#include <octave/ops.h>

#include "int/fixed.h"
#include "ov-fixed.h"
#include "ov-fixed-mat.h"
#include "fixed-def.h"

// fixed matrix by fixedscalar ops.

FIXED_DEFBINOP_OP (add, fixed_matrix, fixed, fixed_matrix, +)
FIXED_DEFBINOP_OP (sub, fixed_matrix, fixed, fixed_matrix, -)
FIXED_DEFBINOP_OP (mul, fixed_matrix, fixed, fixed_matrix, *)

DEFBINOP (div, fixed_matrix, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_matrix&, const octave_fixed&);

  FixedPoint f = v2.fixed_value ();

  if (f == FixedPoint())
    gripe_divide_by_zero ();

  return new octave_fixed_matrix (v1.fixed_matrix_value () / f);
}

DEFBINOP (pow, fixed_matrix, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_matrix&, const octave_fixed&);

  return new octave_fixed_matrix (pow (v1.fixed_matrix_value (), 
				       v2.fixed_matrix_value ()));
}

DEFBINOP_FN (lt, fixed_matrix, fixed, mx_el_lt)
DEFBINOP_FN (le, fixed_matrix, fixed, mx_el_le)
DEFBINOP_FN (eq, fixed_matrix, fixed, mx_el_eq)
DEFBINOP_FN (ge, fixed_matrix, fixed, mx_el_ge)
DEFBINOP_FN (gt, fixed_matrix, fixed, mx_el_gt)
DEFBINOP_FN (ne, fixed_matrix, fixed, mx_el_ne)

FIXED_DEFBINOP_OP (el_mul, fixed_matrix, fixed, fixed_matrix, *)

DEFBINOP (el_div, fixed_matrix, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_matrix&, const octave_fixed&);

  FixedPoint f = v2.fixed_value ();

  if (f == FixedPoint())
    gripe_divide_by_zero ();

  return new octave_fixed_matrix (v1.fixed_matrix_value () / f);
}

FIXED_DEFBINOP_FN (el_pow, fixed_matrix, fixed, fixed_matrix, elem_pow)

DEFBINOP (el_ldiv, fixed_matrix, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed_matrix&, const octave_fixed&);

  FixedPoint f = v2.fixed_value ();

  boolMatrix no_zeros = (v1.fixed_matrix_value().all()).all();
  if (!no_zeros(0,0))
    gripe_divide_by_zero ();

  return new octave_fixed_matrix (f / v1.fixed_matrix_value ());
}


DEFBINOP_FN (el_and, fixed_matrix, fixed, mx_el_and)
DEFBINOP_FN (el_or, fixed_matrix, fixed, mx_el_or)

DEFASSIGNOP_FN (assign, fixed_matrix, fixed, assign)

void
install_fm_fs_ops (void)
{
  INSTALL_BINOP (op_add, octave_fixed_matrix, octave_fixed, add);
  INSTALL_BINOP (op_sub, octave_fixed_matrix, octave_fixed, sub);
  INSTALL_BINOP (op_mul, octave_fixed_matrix, octave_fixed, mul);
  INSTALL_BINOP (op_div, octave_fixed_matrix, octave_fixed, div);
  INSTALL_BINOP (op_pow, octave_fixed_matrix, octave_fixed, pow);
  INSTALL_BINOP (op_lt, octave_fixed_matrix, octave_fixed, lt);
  INSTALL_BINOP (op_le, octave_fixed_matrix, octave_fixed, le);
  INSTALL_BINOP (op_eq, octave_fixed_matrix, octave_fixed, eq);
  INSTALL_BINOP (op_ge, octave_fixed_matrix, octave_fixed, ge);
  INSTALL_BINOP (op_gt, octave_fixed_matrix, octave_fixed, gt);
  INSTALL_BINOP (op_ne, octave_fixed_matrix, octave_fixed, ne);
  INSTALL_BINOP (op_el_mul, octave_fixed_matrix, octave_fixed, el_mul);
  INSTALL_BINOP (op_el_div, octave_fixed_matrix, octave_fixed, el_div);
  INSTALL_BINOP (op_el_pow, octave_fixed_matrix, octave_fixed, el_pow);
  INSTALL_BINOP (op_el_ldiv, octave_fixed_matrix, octave_fixed, el_ldiv);
  INSTALL_BINOP (op_el_and, octave_fixed_matrix, octave_fixed, el_and);
  INSTALL_BINOP (op_el_or, octave_fixed_matrix, octave_fixed, el_or);

  INSTALL_ASSIGNOP (op_asn_eq, octave_fixed_matrix, octave_fixed, assign);
}


/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
