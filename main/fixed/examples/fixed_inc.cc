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

#include <octave/config.h>
#include <octave/oct.h>
#include "fixed.h"

// This code is an example of an oct-file using fixed point values
template <class A, class B>
A myfunc(const A &a, const B &b) {
  return (a + b);
}

// Floating point instantiations
template double myfunc (const double&, const double&);
template Complex myfunc (const Complex&, const double&);
template Matrix myfunc (const Matrix&, const double&);
template ComplexMatrix myfunc (const ComplexMatrix&, const double&);

// Fixed point instantiations
template FixedPoint myfunc (const FixedPoint&, const FixedPoint&);
template FixedPointComplex myfunc (const FixedPointComplex&, 
				   const FixedPoint&);
template FixedMatrix myfunc (const FixedMatrix&, const FixedPoint&);
template FixedComplexMatrix myfunc (const FixedComplexMatrix&, 
				    const FixedPoint&);

DEFUN_DLD (fixed_inc, args, ,
"-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{y} =}  fixed_inc (@var{x})\n\
Example code of the use of the fixed point types in an oct-file.\n\
Returns @code{@var{x} + 1}\n\
@end deftypefn")
{
  octave_value retval;
  FixedPoint one(1,0,1,0);  // Fixed Point value of 1

  if (args.length() != 1)
    print_usage ();
  else
    if (args(0).type_id () == octave_fixed_matrix::static_type_id ()) {
      FixedMatrix f = ((const octave_fixed_matrix&) args(0).get_rep()).
	fixed_matrix_value();
      retval = new octave_fixed_matrix (myfunc(f,one));
    } else if (args(0).type_id () == octave_fixed::static_type_id ()) {
      FixedPoint f = ((const octave_fixed&) args(0).get_rep()).fixed_value();
      retval = new octave_fixed (myfunc(f,one));
    } else if (args(0).type_id () == octave_fixed_complex::static_type_id ()) {
      FixedPointComplex f = ((const octave_fixed_complex&) 
			     args(0).get_rep()).fixed_complex_value();
      retval = new octave_fixed_complex (myfunc(f,one));
    } else if (args(0).type_id () == 
		octave_fixed_complex_matrix::static_type_id ()) {
      FixedComplexMatrix f = ((const octave_fixed_complex_matrix&) 
			      args(0).get_rep()).fixed_complex_matrix_value();
      retval = new octave_fixed_complex_matrix (myfunc(f,one));
    } else {
      // promote the operation to complex matrix. The narrowing op in 
      // octave_value will later change the type if needed. This is not
      // optimal but is convenient....
      ComplexMatrix f = args(0).complex_matrix_value();
      retval = octave_value (myfunc(f,1.));
    }
  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
