/*

Copyright (C) 2001 Paul Kienzle

Modified from variable.cc, Copyright (C) 1996, 1997 John W. Eaton

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

Octave is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with Octave; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#include <octave/oct.h>
#include <octave/variables.h>
#include <octave/symtab.h>

DEFUN_DLD(command, args, , "-*- texinfo -*-\n\
@deffn {Command} command name @dots{}\n\
Register all the named functions as commands which can be invoked\n\
with a set of string arguments without having to quote them or wrap\n\
them in parentheses.  For example\n\
\n\
@example\n\
command axis\n\
@end example\n\
\n\
@noindent\n\
allows you to invoke the script axis.m as @code{axis off} rather than\n\
@code{axis(\"off\")} in order to turn off the axis tic marks.\n\
\n\
Note that this effect is applied at run time, not at parse time.  Since\n\
a function is parsed before it is run, you will not be able to convert\n\
a function into a command at the beginning of the script and use it as\n\
a command in the remainder of the script, since the remainder of the\n\
script will already have been parsed assuming the function was not a\n\
command.\n\
\n\
WARNING: DO NOT APPLY THIS MORE THAN ONCE TO THE SAME FUNCTION otherwise\n\
octave crashes.  Fixes are welcome.\n\
@end deffn")
{
#if defined(HAVE_OCTAVE_20)
  error("command: unavailable for Octave 2.0");
#else
  int nargin = args.length();

  for (int i=0; i < nargin; i++)
    {
      std::string fcn_name;
      if (args(i).is_string())
	fcn_name = args(i).string_value();

      if (! error_state)
	{
	  symbol_record *sr = 0;
	  if (! fcn_name.empty ())
	    {
	      // check for symbol in global context, or create a new one
	      sr = global_sym_tab->lookup (fcn_name, true);
	      
	      // read/reread function file if necessary, but don't execute
	      lookup (sr, false);
	    }
	  if (sr && sr->is_function ())
	    {
	      octave_function* fn = sr->def().function_value();
	      if (! error_state)
		// can't do this step for octave 2.0
		sr->define(fn, sr->type()|symbol_record::TEXT_FUNCTION);
	      else
		warning("command: %s function_value error", fcn_name.c_str());
	    }
	  else
	    warning("command: %s is not a valid function", fcn_name.c_str());
	}
      else
	warning("command: expects string values for arg %d", i+1);
    }
#endif

  return octave_value_list();
}
