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
#include "ov-fixed-complex.h"
#include "fixed-def.h"

// fixed scalar by fixed complex scalar ops.

FIXED_DEFBINOP_OP (add, fixed, fixed_complex, fixed_complex, +)
FIXED_DEFBINOP_OP (sub, fixed, fixed_complex, fixed_complex, -)
FIXED_DEFBINOP_OP (mul, fixed, fixed_complex, fixed_complex, *)

DEFBINOP (div, fixed, fixed_complex)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed_complex&);

  FixedPointComplex d = v2.fixed_complex_value ();

  if (d.fixedpoint() == 0.0)
    gripe_divide_by_zero ();

  return new octave_fixed_complex (v1.fixed_value () / d);
}

DEFBINOP (pow, fixed, fixed_complex)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed_complex&);
  octave_value retval = new octave_fixed_complex (pow (
	v1.fixed_complex_value (), v2.fixed_complex_value ()));
  retval.maybe_mutate();
  return retval; 
}

DEFBINOP (ldiv, fixed, fixed_complex)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed_complex&);

  FixedPoint d = v1.fixed_value ();

  if (d.fixedpoint() == 0.0)
    gripe_divide_by_zero ();

  return new octave_fixed_complex (v2.fixed_complex_value () / d);
}


DEFBINOP (lt, fixed, fixed_complex)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed_complex&);

  return v1.fixed_value () < real (v2.fixed_complex_value ());
}

DEFBINOP (le, fixed, fixed_complex)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed_complex&);

  return v1.fixed_value () <= real (v2.fixed_complex_value ());
}

DEFBINOP (eq, fixed, fixed_complex)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed_complex&);

  return v1.fixed_value () == v2.fixed_complex_value ();
}

DEFBINOP (ge, fixed, fixed_complex)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed_complex&);

  return v1.fixed_value () >= real (v2.fixed_complex_value ());
}

DEFBINOP (gt, fixed, fixed_complex)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed_complex&);

  return v1.fixed_value () > real (v2.fixed_complex_value ());
}

DEFBINOP (ne, fixed, fixed_complex)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed_complex&);

  return v1.fixed_value () != v2.fixed_complex_value ();
}

FIXED_DEFBINOP_OP (el_mul, fixed, fixed_complex, fixed_complex, *)

DEFBINOP (el_div, fixed, fixed_complex)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed_complex&);

  FixedPointComplex d = v2.fixed_complex_value ();

  if (d.fixedpoint() == 0.0)
    gripe_divide_by_zero ();

  return new octave_fixed_complex (v1.fixed_value () / d);
}

DEFBINOP (el_pow, fixed, fixed_complex)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed_complex&);
  octave_value retval = new octave_fixed_complex (pow (
	v1.fixed_complex_value (), v2.fixed_complex_value ()));
  retval.maybe_mutate();
  return retval; 

}

DEFBINOP (el_ldiv, fixed, fixed_complex)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed_complex&);

  FixedPoint d = v1.fixed_value ();

  if (d.fixedpoint() == 0.0)
    gripe_divide_by_zero ();

  return new octave_fixed_complex (v2.fixed_complex_value () / d);
}


DEFBINOP (el_and, fixed, fixed_complex)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed_complex&);
  FixedPoint d1 = v1.fixed_value ();
  FixedPointComplex d2 = v2.fixed_complex_value ();
  return octave_value ((d1.fixedpoint() != 0.0  && d2.fixedpoint () != 0.0));
}

DEFBINOP (el_or, fixed, fixed_complex)
{
  CAST_BINOP_ARGS (const octave_fixed&, const octave_fixed_complex&);
  FixedPoint d1 = v1.fixed_value ();
  FixedPointComplex d2 = v2.fixed_complex_value ();
  return octave_value ((d1.fixedpoint() != 0.0 || d2.fixedpoint () != 0.0));
}

DEFCONV (complex_conv, fixed, fixed_complex)
{
  CAST_CONV_ARG (const octave_fixed&);

  return new octave_fixed_complex (v.fixed_complex_value ());
}

void
install_fs_fcs_ops (void)
{
  INSTALL_BINOP (op_add, octave_fixed, octave_fixed_complex, add);
  INSTALL_BINOP (op_sub, octave_fixed, octave_fixed_complex, sub);
  INSTALL_BINOP (op_mul, octave_fixed, octave_fixed_complex, mul);
  INSTALL_BINOP (op_div, octave_fixed, octave_fixed_complex, div);
  INSTALL_BINOP (op_pow, octave_fixed, octave_fixed_complex, pow);
  INSTALL_BINOP (op_ldiv, octave_fixed, octave_fixed_complex, ldiv);
  INSTALL_BINOP (op_lt, octave_fixed, octave_fixed_complex, lt);
  INSTALL_BINOP (op_le, octave_fixed, octave_fixed_complex, le);
  INSTALL_BINOP (op_eq, octave_fixed, octave_fixed_complex, eq);
  INSTALL_BINOP (op_ge, octave_fixed, octave_fixed_complex, ge);
  INSTALL_BINOP (op_gt, octave_fixed, octave_fixed_complex, gt);
  INSTALL_BINOP (op_ne, octave_fixed, octave_fixed_complex, ne);
  INSTALL_BINOP (op_el_mul, octave_fixed, octave_fixed_complex, el_mul);
  INSTALL_BINOP (op_el_div, octave_fixed, octave_fixed_complex, el_div);
  INSTALL_BINOP (op_el_pow, octave_fixed, octave_fixed_complex, el_pow);
  INSTALL_BINOP (op_el_ldiv, octave_fixed, octave_fixed_complex, el_ldiv);
  INSTALL_BINOP (op_el_and, octave_fixed, octave_fixed_complex, el_and);
  INSTALL_BINOP (op_el_or, octave_fixed, octave_fixed_complex, el_or);

  INSTALL_ASSIGNCONV (octave_fixed, octave_fixed_complex, 
		      octave_fixed_complex_matrix);

  INSTALL_WIDENOP (octave_fixed, octave_fixed_complex, complex_conv);

}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
