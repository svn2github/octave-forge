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

#if !defined (fixed_var_cc)
#define fixed_var_cc 1

#include "int/fixed.h"
#include "fixedversion.h"

#include "ov-fixed.h"
#include "ov-fixed-mat.h"

#include <octave/variables.h>
#include <octave/utils.h>
#include <octave/defun.h>

#define FIXED_VAR( TYP, VAR, VAR_INT) \
TYP &V ## VAR = VAR_INT; \
static int VAR (void) \
{ \
  V ## VAR = check_preference (#VAR); \
  return 0; \
}

FIXED_VAR ( bool, fixed_point_warn_overflow, Fixed::FP_Overflow)
FIXED_VAR ( bool, fixed_point_debug, Fixed::FP_Debug)
FIXED_VAR ( bool, fixed_point_count_operations, Fixed::FP_CountOperations)

void
symbols_of_fixed (void)
{
  DEFVAR (fixed_point_warn_overflow, false, fixed_point_warn_overflow,
    "-*- texinfo -*-\n"
"@defvr {Loadable Variable} {} fixed_point_warn_overflow\n\
If the value of @code{fixed_point_warn_overflow} is nonzero, Octave warns\n\
the user of overflows in fixed point operations. The default is 0.\n\
@end defvr");

  DEFVAR (fixed_point_debug, false, fixed_point_debug,
    "-*- texinfo -*-\n"
"@defvr {Loadable Variable} {} fixed_point_debug\n\
If the value of @code{fixed_point_debug} is nonzero, Octave keeps\n\
a copy of the value of fixed point variable internally. This is useful\n\
for use with a debug to allow easy access to the variables value.\n\
The default value is 0.\n\
@end defvr");

  DEFVAR (fixed_point_count_operations, false, fixed_point_count_operations,
    "-*- texinfo -*-\n"
"@defvr {Loadable Variable} {} fixed_point_count_operations\n\
If the value of @code{fixed_point_count_operations} is nonzero, Octave keeps\n\
track of how many times each type of floating point operation has been used\n\
internally. This can be used to give an approximation of the algorithms\n\
complexity. The default value is 0.\n\
@end defvr\n\
@seealso{display_fixed_operations}");

  DEFCONST (fixed_point_version, OCTAVEFIXEDVERSION, 
    "-*- texinfo -*-\n"
"@defvr {Loadable Constant} {} fixed_point_version\n\
A constant containing the version number of the fixed point package used.\n\
@end defvr");

  DEFCONST (fixed_point_library_version, FIXEDVERSION, 
    "-*- texinfo -*-\n"
"@defvr {Loadable Constant} {} fixed_point_library_version\n\
A constant containing the version number of the fixed point library used.\n\
@end defvr");

}

#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/

