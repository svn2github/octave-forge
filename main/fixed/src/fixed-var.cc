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
#include <octave/defun-dld.h>

DEFUN_DLD (fixed_point_warn_overflow, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{val} =} fixed_point_warn_overflow ()\n\
@deftypefnx {Loadable Function} {@var{old_val} =} fixed_point_warn_overflow (@var{new_val})\n\
Query or set the internal variable @code{fixed_point_warn_overflow}.\n\
If enabled, Octave warns of overflows in fixed point operations.\n\
By default, these warnings are disabled.\n\
@end deftypefn")
{
  return set_internal_variable (Fixed::FP_Overflow, args, nargout,
				"fixed_point_warn_overflow");
}

DEFUN_DLD (fixed_point_debug, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{val} =} fixed_point_debug ()\n\
@deftypefnx {Loadable Function} {@var{old_val} =} fixed_point_debug (@var{new_val})\n\
Query or set the internal variable @code{fixed_point_debug}.  If\n\
enabled, Octave keeps a copy of the value of fixed point variable\n\
internally. This is useful for use with a debug to allow easy access\n\
to the variables value.  By default this feature is disabled.\n\
@end deftypefn")
{
  return set_internal_variable (Fixed::FP_Debug, args, nargout,
				"fixed_point_debug");
}

DEFUN_DLD (fixed_point_count_operations, args, nargout,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{val} =} fixed_point_count_operations ()\n\
@deftypefnx {Loadable Function} {@var{old_val} =} fixed_point_count_operations (@var{new_val})\n\
Query or set the internal variable @code{fixed_point_count_operations}.\n\
If enabled, Octave keeps track of how many times each type of floating\n\
point operation has been used internally.  This can be used to give an\n\
approximation of the algorithms complexity.  By default, this feature is\n\
disabled.\n\
@seealso{display_fixed_operations}\n\
@end deftypefn")
{
  return set_internal_variable (Fixed::FP_CountOperations, args, nargout,
				"fixed_point_count_operations");
}

DEFUN_DLD (fixed_point_version, args, ,
    "-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {} fixed_point_version ()\n\
A function returning the version number of the fixed point package used.\n\
@end deftypefn")
{
  octave_value retval;
  
  if (args.length () == 0)
    retval = OCTAVEFIXEDVERSION;
  else
    print_usage ();
  	 
  return retval;
}

DEFUN_DLD (fixed_point_library_version, args, ,
    "-*- texinfo -*-\n"
"@deftypefn {Loadable Function} {} fixed_point_library_version ()\n\
A function returning the version number of the fixed point library used.\n\
@end deftypefn")
{
  octave_value retval;
  
  if (args.length () == 0)
    retval = FIXEDVERSION;
  else
    print_usage ();
  	 
  return retval;
}


#endif

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/

