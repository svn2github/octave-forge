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

#include <octave/oct.h>
#include <octave/oct-lvalue.h>
#include <octave/ov.h>
#include <octave/ov-struct.h>

extern "C" {
#include <gpcl/gpc.h>
}

#ifndef OV_REP_TYPE
#define OV_REP_TYPE octave_value
#endif

void octave_gpc_free_polygon (gpc_polygon*);

gpc_polygon* get_gpc_pt (octave_value);

void map_to_gpc (Octave_map&, gpc_polygon*);

void gpc_to_map (gpc_polygon*, Octave_map*);

bool assert_gpc_polygon (Octave_map*);

class
octave_gpc_polygon : public octave_base_value
{
public:

  octave_gpc_polygon (void)
    : octave_base_value (), polygon (new gpc_polygon)
  { }

  octave_gpc_polygon (Octave_map m)
    : octave_base_value (), polygon (new gpc_polygon)
  { map_to_gpc (m, polygon); }

  octave_gpc_polygon (const octave_gpc_polygon& p)
    : octave_base_value (), polygon (new gpc_polygon)
  {
    Octave_map m;
    gpc_to_map (p.polygon_value (), &m);
    map_to_gpc (m, polygon);
  }

  ~octave_gpc_polygon (void) { octave_gpc_free_polygon (polygon); }

  OV_REP_TYPE* clone (void) { return new octave_gpc_polygon (*this); }

  bool is_defined (void) const { return true; }

  void print (std::ostream&, bool) const;

  gpc_polygon* polygon_value (void) const { return polygon; }

private:

  gpc_polygon* polygon;

  // The code below is needed for properly defining a new Octave object
  // type.
  DECLARE_OCTAVE_ALLOCATOR

  DECLARE_OV_TYPEID_FUNCTIONS_AND_DATA
};

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
