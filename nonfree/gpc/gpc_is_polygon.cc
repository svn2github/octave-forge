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

// This is the user function for testing if an object is a gpc_polygon
DEFUN_DLD (gpc_is_polygon, args, ,
"  SYNOPSIS:\n"
"    result = gpc_is_polygon (x)\n"
"\n"
"  DESCRIPTION:\n"
"    Returns true if X is a object of type gpc_polygon.  Returns false\n"
"    otherwise.\n"
"\n"
"  SEE ALSO:\n"
"    The General Polygon Clipper Library documentation.\n"
"    gpc_create, gpc_clip, gpc_read, gpc_write, \n"
"    gpc_get, gpc_plot.\n" )
{
  octave_value retval = false;

  // Sanity check of the arguments
  int nargin = args.length ();
  
  if (nargin != 1)
    print_usage ("gpc_is_polygon");
  else
    retval = octave_value
      (args(0).type_id () == octave_gpc_polygon::static_type_id ());

  return retval;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
