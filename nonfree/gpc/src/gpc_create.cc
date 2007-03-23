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

// This is the user function for creating the gpc_polygon object.
DEFUN_DLD (gpc_create, args, ,
"  SYNOPSIS:\n"
"    polygon = gpc_create (vertices[, indices[, hole]])\n"
"    polygon = gpc_create (polygon_struct)\n"
"\n"
"  DESCRIPTION:\n"
"    Create a gpc_polygon object for futher use with gpc_clip.  When\n"
"    called with regular matrices as arguments, gpc_create accepts a\n"
"    [n,2] matrix as VERTICES, containing the x and y coordinates of\n"
"    the polygon vertices, a [m,2] integer matrix as INDICES with the\n"
"    initial (first column) and final (second column) indices of each\n"
"    contour composing the polygon, and a [m,1] boolean vector HOLE,\n"
"    which specifies which contours are holes.  The HOLE and INDICES\n"
"    are optional parameters and they default to:\n"
"\n"
"      HOLE = zeroes(size(indices,1),2)\n"
"      INDICES = [1,size(vertices,1)]\n"
"\n" 
"    gpc_create can also be called with a single argument that is a\n"
"    structure.  In this case it must be a structure containing the\n"
"     members vertices, indices and hole, as above.\n"
"\n"
"    The value return is an object of type gpc_polygon.\n"
"\n"
"  SEE ALSO:\n"
"    The General Polygon Clipper Library documentation.\n"
"    gpc_clip, gpc_get, gpc_read, gpc_write, \n"
"    gpc_is_polygon, gpc_plot.\n" )
{
  octave_value retval;

  static bool type_loaded = false;

  if (! type_loaded)
    {
      octave_gpc_polygon::register_type ();
      type_loaded = true;
    }

  int nargin = args.length ();

  if (nargin < 1 || nargin > 3)

    print_usage ();

  else
    {
      Octave_map* m;

      if (args (0).is_map ())
	 m = new Octave_map (args (0).map_value ());
      else
	{
	  m = new Octave_map ();

	  m->contents ("vertices") = args (0);
	  if (nargin > 1)
	    {
	      m->contents ("indices") = args (1);
	      if (nargin > 2)
		m->contents ("hole") = args (2);	  
	    }
	}

      if ( ! assert_gpc_polygon (m) ) 
	warning ("gpc_create: inconsistent arguments, but "
		 "gpc_polygon object created anyway");

      retval = octave_value (new octave_gpc_polygon (*m));

      delete m;
    }
  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
