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

// Registration of the octave_gpc_polygon object type.
DEFINE_OCTAVE_ALLOCATOR (octave_gpc_polygon);

DEFINE_OV_TYPEID_FUNCTIONS_AND_DATA (octave_gpc_polygon, "gpc_polygon",
                                     "gpc_polygon");

// Member function

void
octave_gpc_polygon::print (std::ostream& os,
			   bool pr_as_read_syntax = false) const
{
  os << "Variable is of type " <<  t_name << ".\n"
     << "Its members (accessible with the function gpc_get) are:\n";
  Octave_map m;
  gpc_to_map (polygon, &m);
  (octave_struct (m)).print (os);
}


// Utility function to check if an Octave object is a matrix with 2
// columns.  This is the basic type for x.vertices and x.indices,
// where x is of type gpc_polygon.

static
bool
assert_nx2_matrix (octave_value ov)
{
  if ( ! ov.is_matrix_type () )
    return false;
  if ( ov.columns () != 2 )
    return false;
  return true;
}

// gpc_polygon_free will free any C gpc_polygon structure initialized
// by the octave_gpc library (in C++).  For
void
octave_gpc_free_polygon (gpc_polygon* p)
{
  delete [] p->hole;
  for (int i = 0; i < p->num_contours; i++)
    delete [] p->contour[i].vertex;
  delete [] p->contour;
}

gpc_polygon*
get_gpc_pt (octave_value v)
{
  // Peek the representation and extract the data (i.e., the pointer
  // to the gpc_polygon stored in the octave variable).  This seems to
  // be the only way to do that with Octave 2.1
  const octave_value& rep = v.get_rep ();
  return ((const octave_gpc_polygon&) rep).polygon_value ();
}

void
map_to_gpc (Octave_map& m, gpc_polygon* p)
{
  Matrix vtx = m.contents ("vertices") (0).matrix_value ();
  Matrix idx = m.contents ("indices") (0).matrix_value ();
  ColumnVector hol = m.contents ("hole") (0).column_vector_value ();
  int n = idx.rows ();

  p->num_contours = n;
  p->hole = new int [n];
  p->contour = new gpc_vertex_list [n];

  for (int i = 0; i < n; i++)
    {
      p->hole[i] = (int) hol (i);

      int j0 = (int) idx (i, 0) - 1;
      int m = (int) idx (i, 1) - j0;

      p->contour[i].num_vertices = m;
      p->contour[i].vertex = new gpc_vertex [m];

      for (int j = 0; j < m; j++)
	{
	  p->contour[i].vertex[j].x = vtx (j0 + j, 0);
	  p->contour[i].vertex[j].y = vtx (j0 + j, 1);
	}
    }
}

void
gpc_to_map (gpc_polygon* p, Octave_map* map)
{
  int n = p->num_contours;
  ColumnVector hol (n);
  Matrix idx (n, 2);
  int m = 0;
  for (int i = 0; i < n; i++)
    {
      hol (i) = p->hole[i];
      idx (i, 0) = m + 1;
      m += p->contour[i].num_vertices;
      idx (i, 1) = m;
    }
  Matrix vtx (m, 2);
  int j = 0;
  for (int i = 0; i < n; i++)
    {
      int m = p->contour[i].num_vertices;
      gpc_vertex* v = p->contour[i].vertex;
      for (int k = 0; k < m; k++)
	{
	  vtx (j, 0) = v[k].x;
	  vtx (j++, 1) = v[k].y;
	}
    }

  map->assign ("vertices", vtx);
  map->assign ("indices", idx);
  map->assign ("hole", hol);
}

bool
assert_gpc_polygon (Octave_map* m)
{
  if ( ! m->contains ("vertices") )
    {
      warning ("No vertices !");
      return false;
    }
  octave_value v = m->contents ("vertices") (0);
  if ( ! assert_nx2_matrix (v) )
    {
      warning ("assert_gpc_polygon: vertices member should be a "
	       "[n,2] matrix");
      	return false;
    }
  octave_value i;
  if ( ! m->contains ("indices") )
    {
      Matrix im (1, 2);
      im (0, 0) = (double) 1;
      im (0, 1) = (double) v.rows ();
      i = m->contents ("indices") (0) = im;
    }
  else
    {
      i = m->contents ("indices") (0);
      if ( ! assert_nx2_matrix (i) )
	{
	  warning ("assert_gpc_polygon: indices member should be a "
		   "[n,2] matrix");
	  return false;
	}
      Matrix im = i.matrix_value ();
      if ( im.column_max ().max () > v.rows ()
	   || im.column_min ().min () < 1 )
	{
	  warning ("assert_gpc_polygon: indices out of range");
	  return false;
	}
    }

  if ( ! m->contains ("hole") )
    {
      ColumnVector h (i.rows ());
      h.fill ((double) 0);
      m->contents ("hole") (0) = h;
    }
  else
    {
      octave_value h = m->contents ("hole") (0);

      if ( (! h.is_matrix_type () || h.columns () != 1)
	   && ! h.is_real_scalar () )
	{
	  warning ("assert_gpc_polygon: hole member should be a "
		   "column vector");
	  return false;
	}
      int n = h.rows ();
      if ( n != i.rows () )
	{
	  warning ("assert_gpc_polygon: hole member length should "
		   "be equal to the number of lines of indices member");
	  return false;
	}
      for (int i = 0; i < n; i++)
	if ( h.matrix_value () (i, 0) != 0
	     && h.matrix_value () (i, 0) != 1 )
	  {
	    warning ("assert_gpc_polygon: hole member elements should "
		     "be either 0 or 1");
	    return false;
	  }
    }
  return true;
}

/*
;;; Local Variables: ***
;;; mode: C++ ***
;;; End: ***
*/
