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
DEFUN_DLD (gpc_read, args, ,
"  SYNOPSIS:\n"
"    polygon = gpc_read (file [, read_hole_flags])\n"
"\n"
"  DESCRIPTION:\n"
"    Reads a gpc_polygon from FILE, which is in the format described in\n"
"    the GPC documentation.  The reading of hole flags is optional and is\n"
"    controlled by setting the optional argument READ_HOLE_FLAGS (0 for\n"
"    false and 1 for true)."
"\n"
"    The returned value POLYGON is a gpc_polygon object.\n"
"\n"
"  SEE ALSO:\n"
"    The General Polygon Clipper Library documentation.\n"
"    gpc_create, gpc_clip, gpc_get, gpc_write, \n"
"    gpc_is_polygon, gpc_plot.\n" )
{
  octave_value retval;
  gpc_polygon p;
  int read_hole_flags = 0;

  // Sanity check of the arguments
  int nargin = args.length ();
  
  if ( nargin < 1 || nargin > 2 )
    print_usage ("gpc_read");
  else
    {
      if ( nargin == 2 )
	{
	  octave_value ov = args (1);
	  if ( ! ov.is_real_scalar () )
	    {
	      error ("gpc_read: read_hole_flags must be a real "
		     "scalar");
	      return retval;
	    }
	  read_hole_flags = (int) ov.double_value ();
	}
      if ( ! args (0).is_string () )
	{
	  error ("gpc_read: file argument must be string");
	  return retval;
	}
	
      FILE *fp = fopen (args (0).string_value ().c_str (), "r");
      if ( fp == NULL )
	{
	  error ("gpc_read: cannot open file");
	  return retval;
	}

      gpc_read_polygon (fp, read_hole_flags, &p);
      fclose (fp);

      Octave_map m;
      gpc_to_map (&p, &m);
      retval = octave_value (new octave_gpc_polygon (m));

      gpc_free_polygon (&p);
      
    }  
  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
