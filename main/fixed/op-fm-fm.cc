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

// fixed matrix unary ops.

FIXED_DEFUNOP_OP (not, fixed_matrix, !)
FIXED_DEFUNOP_OP (uminus, fixed_matrix, -)
#ifdef HAVE_OCTAVE_UPLUS
FIXED_DEFUNOP_OP (uplus, fixed_matrix, /* no-op */)
#endif
DEFUNOP (transpose, fixed_matrix)
{
  CAST_UNOP_ARG (const octave_fixed_matrix&);

  return new octave_fixed_matrix (v.fixed_matrix_value().transpose ());
}

DEFNCUNOP_METHOD (incr, fixed_matrix, increment)
DEFNCUNOP_METHOD (decr, fixed_matrix, decrement)

// fixed matrix by fixed matrix ops.

FIXED_DEFBINOP_OP (add, fixed_matrix, fixed_matrix, fixed_matrix, +)
FIXED_DEFBINOP_OP (sub, fixed_matrix, fixed_matrix, fixed_matrix, -)
FIXED_DEFBINOP_OP (mul, fixed_matrix, fixed_matrix, fixed_matrix, *)

DEFBINOPX (pow, fixed_matrix, fixed_matrix)
{
  error ("can't do A ^ B for A and B both matrices");
  return octave_value ();
}

DEFBINOP_FN (lt, fixed_matrix, fixed_matrix, mx_el_lt)
DEFBINOP_FN (le, fixed_matrix, fixed_matrix, mx_el_le)
DEFBINOP_FN (eq, fixed_matrix, fixed_matrix, mx_el_eq)
DEFBINOP_FN (ge, fixed_matrix, fixed_matrix, mx_el_ge)
DEFBINOP_FN (gt, fixed_matrix, fixed_matrix, mx_el_gt)
DEFBINOP_FN (ne, fixed_matrix, fixed_matrix, mx_el_ne)

FIXED_DEFBINOP_FN (el_mul, fixed_matrix, fixed_matrix, fixed_matrix, product)

DEFBINOP (el_div, fixed_matrix, fixed_matrix)
{
  CAST_BINOP_ARGS (const octave_fixed_matrix&, const octave_fixed_matrix&);

  boolMatrix no_zeros = (v2.fixed_matrix_value().all()).all();
  if (!no_zeros(0,0))
    gripe_divide_by_zero ();

  return new octave_fixed_matrix (quotient(v1.fixed_matrix_value(), 
				  v2.fixed_matrix_value ()));
}

FIXED_DEFBINOP_FN (el_pow, fixed_matrix, fixed_matrix, fixed_matrix, elem_pow)

DEFBINOP (el_ldiv, fixed_matrix, fixed_matrix)
{
  CAST_BINOP_ARGS (const octave_fixed_matrix&, const octave_fixed_matrix&);

  boolMatrix no_zeros = (v1.fixed_matrix_value().all()).all();
  if (!no_zeros(0,0))
    gripe_divide_by_zero ();

  return new octave_fixed_matrix (quotient(v2.fixed_matrix_value(),
				  v1.fixed_matrix_value ()));
}

DEFBINOP_FN (el_and, fixed_matrix, fixed_matrix, mx_el_and)
DEFBINOP_FN (el_or, fixed_matrix, fixed_matrix, mx_el_or)

FIXED_DEFCATOP_FN (fm_fm, fixed_matrix, fixed_matrix, fixed_matrix, fixed_matrix,
		   fixed_matrix, concat)

CONVDECLX (fixed_matrix_conv)
{
  return new octave_fixed_matrix ();
}

DEFASSIGNOP_FN (assign, fixed_matrix, fixed_matrix, assign)

void
install_fm_fm_ops (void)
{
  INSTALL_UNOP (op_not, octave_fixed_matrix, not);
  INSTALL_UNOP (op_uminus, octave_fixed_matrix, uminus);
#ifdef HAVE_OCTAVE_UPLUS
  INSTALL_UNOP (op_uplus, octave_fixed_matrix, uplus);
#endif
  INSTALL_UNOP (op_transpose, octave_fixed_matrix, transpose);
  INSTALL_UNOP (op_hermitian, octave_fixed_matrix, transpose);

  INSTALL_NCUNOP (op_incr, octave_fixed_matrix, incr);
  INSTALL_NCUNOP (op_decr, octave_fixed_matrix, decr);

  INSTALL_BINOP (op_add, octave_fixed_matrix, octave_fixed_matrix, add);
  INSTALL_BINOP (op_sub, octave_fixed_matrix, octave_fixed_matrix, sub);
  INSTALL_BINOP (op_mul, octave_fixed_matrix, octave_fixed_matrix, mul);
  INSTALL_BINOP (op_pow, octave_fixed_matrix, octave_fixed_matrix, pow);
  INSTALL_BINOP (op_lt, octave_fixed_matrix, octave_fixed_matrix, lt);
  INSTALL_BINOP (op_le, octave_fixed_matrix, octave_fixed_matrix, le);
  INSTALL_BINOP (op_eq, octave_fixed_matrix, octave_fixed_matrix, eq);
  INSTALL_BINOP (op_ge, octave_fixed_matrix, octave_fixed_matrix, ge);
  INSTALL_BINOP (op_gt, octave_fixed_matrix, octave_fixed_matrix, gt);
  INSTALL_BINOP (op_ne, octave_fixed_matrix, octave_fixed_matrix, ne);
  INSTALL_BINOP (op_el_mul, octave_fixed_matrix, octave_fixed_matrix, el_mul);
  INSTALL_BINOP (op_el_div, octave_fixed_matrix, octave_fixed_matrix, el_div);
  INSTALL_BINOP (op_el_pow, octave_fixed_matrix, octave_fixed_matrix, el_pow);
  INSTALL_BINOP (op_el_ldiv, octave_fixed_matrix, octave_fixed_matrix, 
		 el_ldiv);
  INSTALL_BINOP (op_el_and, octave_fixed_matrix, octave_fixed_matrix, el_and);
  INSTALL_BINOP (op_el_or, octave_fixed_matrix, octave_fixed_matrix, el_or);

  FIXED_INSTALL_CATOP (octave_fixed_matrix, octave_fixed_matrix, fm_fm);

  INSTALL_ASSIGNOP (op_asn_eq, octave_fixed_matrix, octave_fixed_matrix, 
		    assign);
  INSTALL_ASSIGNCONV (octave_fixed_matrix, octave_fixed_matrix, 
		      octave_fixed_matrix);
  INSTALL_ASSIGNCONV (octave_base_value, octave_fixed_matrix, 
  		      octave_fixed_matrix);

  INSTALL_WIDENOP (octave_base_value, octave_fixed_matrix, fixed_matrix_conv);
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
