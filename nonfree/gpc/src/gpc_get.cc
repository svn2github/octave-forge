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
along with this software-GPC; see the file COPYING.  If not, see
<http://www.gnu.org/licenses/>.

*/

#include "octave-gpc.h"

// This are the user functions for reading (writing) polygons from (to)
// files. 
DEFUN_DLD (gpc_get, args, ,
"  SYNOPSIS:\n"
"    polygon_struct = gpc_get (polygon)\n"
"\n"
"  DESCRIPTION:\n"
"    Obtain the associated structure of a gpc_polygon object.  See\n"
"    the documentation of gpc_create for the details.\n"
"\n"
"  SEE ALSO:\n"
"    The General Polygon Clipper Library documentation.\n"
"    gpc_create, gpc_clip, gpc_read, gpc_write, \n"
"    gpc_is_polygon, gpc_plot.\n" )
{
  octave_value retval;

  // Sanity check of the arguments
  int nargin = args.length ();
  
  if ( nargin != 1 )
    print_usage ();
  else
    {
      if ( args(0).type_id () != octave_gpc_polygon::static_type_id () )
	{
	  error ("gpc_get: argument must be of type gpc_polygon");
	  return retval;
	}
      else 
	{
	  Octave_map m;
	  gpc_to_map (get_gpc_pt (args(0)), &m);
	  retval = octave_value (m);
	}  
    }

  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
