/*

Copyright (C) 2001, 2004  Rafael Laboissiere

This file is part of octave-gpc.

octave-gpc is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

octave-gpc is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License
along with octave-gpc; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#include "octave-gpc.h"

// This are the user functions for reading (writing) polygons from (to)
// files. 
DEFUN_DLD (gpc_write, args, ,
"  SYNOPSIS:\n"
"    gpc_write (polygon, file [, write_hole_flags])\n"
"\n"
"  DESCRIPTION:\n"
"    Write a gpc_polygon to FILE in the format described in the GPC \n"
"    documentation.  The writing of hole flags is optional and is\n"
"    controlled by setting the optional argument WRITE_HOLE_FLAGS (0 for\n"
"    false and 1 for true).\n"
"\n"
"  SEE ALSO:\n"
"    The General Polygon Clipper Library documentation.\n"
"    gpc_create, gpc_clip, gpc_get, gpc_read, \n"
"    gpc_is_polygon, gpc_plot.\n" )
{
  octave_value retval;
  gpc_polygon *p;
  int write_hole_flags = 0;

  // Sanity check of the arguments
  int nargin = args.length ();
  
  if ( nargin < 2 || nargin > 3 )
    print_usage ("gpc_write");
  else
    {
      if ( nargin == 3 )
	{
	  octave_value ov = args (2);
	  if ( ! ov.is_real_scalar () )
	    {
	      error ("gpc_write: write_hole_flags must be a real "
		     "scalar");
	      return retval;
	    }
	  write_hole_flags = (int) ov.double_value ();
	}
      if ( args(0).type_id () != octave_gpc_polygon::static_type_id () )
	{
	  error ("gpc_write: 1st argument must be of type "
		 "gpc_polygon");
	  return retval;
	}
      p = get_gpc_pt (args (0));

      if ( ! args (1).is_string () )
	{
	  error ("gpc_write: file argument must be string");
	  return retval;
	}
	
      const char* file = args (1).string_value ().c_str ();
      FILE *fp = fopen (file, "w");
      if ( fp == NULL )
	{
	  error ("gpc_write: cannot open file %s", file);
	  return retval;
	}

      gpc_write_polygon (fp, write_hole_flags, p);

      fclose (fp);

    }  
  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
