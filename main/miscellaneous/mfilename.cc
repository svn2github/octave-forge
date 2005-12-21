/*

Copyright (C) 2005 David Bateman

Octave is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

Octave is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with this program; see the file COPYING.  If not, write to the
Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
Boston, MA 02110-1301, USA.

*/

//#ifdef HAVE_CONFIG_H
#include <config.h>
//#endif

#include "defun-dld.h"
#include "error.h"
#include "gripes.h"
#include "oct-obj.h"
#include "utils.h"
#include "toplev.h"
#include "variables.h"

DEFUN_DLD (mfilename, args, ,
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{p} =} mfilename ( )\n\
@deftypefnx {Loadable Function} {@var{p} =} mfilename ('fullpath')\n\
\n\
Returns the path to the currently executing function. Given the\n\
'fullpath', returns the return path to the currently executing\n\
function.\n\
@end deftypefn")
{
  int nargin = args.length();
  octave_value retval;
  
  if (nargin == 0 || nargin == 1)
    {
      if (curr_caller_function)
	{
	  if (nargin == 0)
	    retval = curr_caller_function -> name ();
	  else 
	    {
	      std::string str = args(0).string_value();
	      if (error_state)
		error ("mfilename: argument must be a string");
	      else
		{
		  std::transform (str.begin (), str.end (), str.begin (), tolower);
		  if (str == "fullpath")
		    {
		      std::string nm (curr_caller_function->fcn_file_name ());
		      if (nm == std::string())
			retval = curr_caller_function->name ();
		      else
			retval = nm;
		    }
		  else if (str == "class")
		    error ("mfilename: class not implemented");
		  else
		    error ("mfilename: unrecognized argument");
		}
	    }
	}
      else
	retval = std::string ();
    }
  else
    print_usage("mfilename");

  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
