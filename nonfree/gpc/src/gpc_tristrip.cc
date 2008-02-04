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
along with this software-GPC; see the file COPYING.  If not, write to the Free
Software Foundation, 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

*/

#include "octave-gpc.h"

// This are the user functions for reading (writing) polygons from (to)
// files. 
DEFUN_DLD (gpc_tristrip, args, ,
"  SYNOPSIS:\n"
"    tristrip = gpc_tristrip (polygon)\n"
"\n"
"  DESCRIPTION:\n"
"    Obtain a TRISTRIP representation of POLYGON, a gpc_polygon object.\n"
"    Tristrips are suitable for fill plottings and are coped with by\n"
"    gpc_plot.\n"
"\n"
"  SEE ALSO:\n"
"    The General Polygon Clipper Library documentation.\n"
"    gpc_create, gpc_clip, gpc_get, gpc_read, gpc_write, \n"
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
	  error ("gpc_tristrip: argument must be of type gpc_polygon");
	  return retval;
	}
      else 
	{
	  gpc_tristrip t;
          gpc_polygon p;

          gpc_polygon_to_tristrip (get_gpc_pt (args (0)), &t);

	  p.contour = t.strip;
	  int n = (p.num_contours = t.num_strips);
          p.hole = new int [n];
          for (int i = 0; i < n; i++)
	    p.hole[i] = 0;

	  Octave_map m;
	  gpc_to_map (&p, &m);
	  retval = octave_value (new octave_gpc_polygon (m));

          gpc_free_tristrip (&t);
          delete [] p.hole;
	}  
    }

  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
