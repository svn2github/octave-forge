/*

Copyright (C) 2001, 2004  Rafael Laboissiere

This file is part of Octave-GPC.

Octave-GPC is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

Octave-GPC is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with Octave-GPC; see the file COPYING.  If not, write to the Free
Software Foundation, 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

#include "octave-gpc.h"

// This is the user function for polygon operations
DEFUN_DLD (gpc_clip, args, ,
"  SYNOPSIS:\n"
"    result = gpc_clip (subject, clip, [operation]])\n"
"\n"
"  DESCRIPTION:\n"
"    Make an clipping operation between the SUBJECT and CLIP\n"
"    arguments, which must be gpc_polygon objects.  The OPERATION\n"
"    argument must be one of \"DIFF\", \"INT\", \"XOR\", or\n"
"    \"UNION\" (the default value is \"INT\").\n" 
"\n"
"    RESULT is the resulting gpc_polygon object.\n"
"\n"
"  SEE ALSO:\n"
"    The General Polygon Clipper Library documentation.\n"
"    gpc_create, gpc_get, gpc_read, gpc_write,\n"
"    gpc_is_polygon, gpc_plot.\n" )
{
  octave_value retval;
  gpc_op operation = GPC_INT;
  gpc_polygon *subject, *clip, result;

  // Sanity check of the arguments
  int nargin = args.length ();
  
  if (nargin < 2 || nargin > 3)
    print_usage ();
  else
    {
      if ( nargin == 3 )
	{
          std::string op = args (2).string_value ();
	  if ( error_state )
	    {
	      error ("gpc_clip: operation argument should be a "
		     "string");
	      return retval;
	    }
	  else
	    {
	      if ( op == "DIFF" )
		operation = GPC_DIFF;
	      else
		if ( op == "INT" )
		  operation = GPC_INT;
		else
		  if ( op == "XOR" )
		    operation = GPC_XOR;
		  else
		    if ( op == "UNION" )
		      operation = GPC_UNION;
		    else
		      {
			error ("gpc_clip: operation argument must be "
			       "one of \"DIFF\", \"INT\", \"XOR\", or "
			       "\"UNION\"");
			return retval;
		      }
	    }
	}

      if ( args(0).type_id () == octave_gpc_polygon::static_type_id () )
	  subject = get_gpc_pt (args(0));
      else
	{
	  error ("gpc_clip: subject argument must be of type "
		 "gpc_polygon");
	  return retval;
	}
      
      if ( args (1).type_id () == octave_gpc_polygon::static_type_id () )
	  clip = get_gpc_pt (args(1));
      else
	{
	  error ("gpc_clip: clip argument must be of type "
		 "gpc_polygon");
	  return retval;
	}
      
      gpc_polygon_clip (operation, subject, clip, &result);
      Octave_map m;
      gpc_to_map (&result, &m);
      retval = octave_value (new octave_gpc_polygon (m));
      
      // The result polygon must be freed by the C library function as
      // it was created by gpc_polygon_clip.
      gpc_free_polygon (&result);
    }  
  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
