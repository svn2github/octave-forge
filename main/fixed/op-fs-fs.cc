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

// fixed scalar unary ops.

FIXED_DEFUNOP_OP (not, fixed, !)
FIXED_DEFUNOP_OP (uminus, fixed, -)
#ifdef HAVE_OCTAVE_UPLUS
FIXED_DEFUNOP_OP (uplus, fixed, /* no-op */)
#endif
FIXED_DEFUNOP_OP (transpose, fixed, /* no-op */)
FIXED_DEFUNOP_OP (hermitian, fixed, /* no-op */)

DEFNCUNOP_METHOD (incr, fixed, increment)
DEFNCUNOP_METHOD (decr, fixed, decrement)

// fixed scalar by fixed scalar ops.

FIXED_DEFBINOP_OP (add, fixed, fixed, fixed, +)
FIXED_DEFBINOP_OP (sub, fixed, fixed, fixed, -)
FIXED_DEFBINOP_OP (mul, fixed, fixed, fixed, *)

DEFBINOP (div, fixed, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed&);

  FixedPoint d = v2.fixed_value ();

  if (d.fixedpoint() == 0.0)
    gripe_divide_by_zero ();

  return new octave_fixed (v1.fixed_value () / d);
}

FIXED_DEFBINOP_FN (pow, fixed, fixed, fixed, pow)

DEFBINOP (ldiv, fixed, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed&);

  FixedPoint d = v1.fixed_value ();

  if (d.fixedpoint() == 0.0)
    gripe_divide_by_zero ();

  return new octave_fixed (v2.fixed_value () / d);
}

DEFBINOP_OP (lt, fixed, fixed, <)
DEFBINOP_OP (le, fixed, fixed, <=)
DEFBINOP_OP (eq, fixed, fixed, ==)
DEFBINOP_OP (ge, fixed, fixed, >=)
DEFBINOP_OP (gt, fixed, fixed, >)
DEFBINOP_OP (ne, fixed, fixed, !=)

FIXED_DEFBINOP_OP (el_mul, fixed, fixed, fixed, *)

DEFBINOP (el_div, fixed, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed&);

  FixedPoint d = v2.fixed_value ();

  if (d.fixedpoint() == 0.0)
    gripe_divide_by_zero ();

  return new octave_fixed (v1.fixed_value () / d);
}

FIXED_DEFBINOP_FN (el_pow, fixed, fixed, fixed, pow)

DEFBINOP (el_ldiv, fixed, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed&);

  FixedPoint d = v1.fixed_value ();

  if (d.fixedpoint() == 0.0)
    gripe_divide_by_zero ();

  return new octave_fixed (v2.fixed_value () / d);
}


DEFBINOP (el_and, fixed, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed&);
  FixedPoint d1 = v1.fixed_value ();
  FixedPoint d2 = v2.fixed_value ();
  return octave_value ((d1.fixedpoint() && d2.fixedpoint ()));
}

DEFBINOP (el_or, fixed, fixed)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed&);
  FixedPoint d1 = v1.fixed_value ();
  FixedPoint d2 = v2.fixed_value ();
  return octave_value ((d1.fixedpoint() || d2.fixedpoint ()));
}

FIXED_DEFCATOP_FN (fs_fs, fixed, fixed, fixed_matrix, fixed_matrix, 
		   fixed_matrix, concat)

void
install_fs_fs_ops (void)
{
  INSTALL_UNOP (op_not, octave_fixed, not);
  INSTALL_UNOP (op_uminus, octave_fixed, uminus);
#ifdef HAVE_OCTAVE_UPLUS
  INSTALL_UNOP (op_uplus, octave_fixed, uplus);
#endif
  INSTALL_UNOP (op_transpose, octave_fixed, transpose);
  INSTALL_UNOP (op_hermitian, octave_fixed, hermitian);

  INSTALL_NCUNOP (op_incr, octave_fixed, incr);
  INSTALL_NCUNOP (op_decr, octave_fixed, decr);

  INSTALL_BINOP (op_add, octave_fixed, octave_fixed, add);
  INSTALL_BINOP (op_sub, octave_fixed, octave_fixed, sub);
  INSTALL_BINOP (op_mul, octave_fixed, octave_fixed, mul);
  INSTALL_BINOP (op_div, octave_fixed, octave_fixed, div);
  INSTALL_BINOP (op_pow, octave_fixed, octave_fixed, pow);
  INSTALL_BINOP (op_ldiv, octave_fixed, octave_fixed, ldiv);
  INSTALL_BINOP (op_lt, octave_fixed, octave_fixed, lt);
  INSTALL_BINOP (op_le, octave_fixed, octave_fixed, le);
  INSTALL_BINOP (op_eq, octave_fixed, octave_fixed, eq);
  INSTALL_BINOP (op_ge, octave_fixed, octave_fixed, ge);
  INSTALL_BINOP (op_gt, octave_fixed, octave_fixed, gt);
  INSTALL_BINOP (op_ne, octave_fixed, octave_fixed, ne);
  INSTALL_BINOP (op_el_mul, octave_fixed, octave_fixed, el_mul);
  INSTALL_BINOP (op_el_div, octave_fixed, octave_fixed, el_div);
  INSTALL_BINOP (op_el_pow, octave_fixed, octave_fixed, el_pow);
  INSTALL_BINOP (op_el_ldiv, octave_fixed, octave_fixed, el_ldiv);
  INSTALL_BINOP (op_el_and, octave_fixed, octave_fixed, el_and);
  INSTALL_BINOP (op_el_or, octave_fixed, octave_fixed, el_or);

  FIXED_INSTALL_CATOP (octave_fixed, octave_fixed, fs_fs);

  INSTALL_ASSIGNCONV (octave_fixed, octave_fixed, octave_fixed_matrix);
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
