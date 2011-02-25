/*

Copyright (C) 2009 John W. Eaton
Copyright (C) 2009 Jaroslav Hajek
Copyright (C) 2010, 2011 Olaf Till

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.

*/

// This code and the comments are taken and slightly modified from
// Octave-3.2.4, src/data.cc (do_cat()), src/ov.cc (do_cat_op ()),
// src/OPERATORS/op-struct.cc, src/ops.h, and oct-map.cc
// (Octave_map::concat ()).

#include <octave/oct.h>
#include <octave/ov-struct.h>

static octave_value
structcat_cat_op_fcn (const octave_value& v1, const octave_value& v2, 
		      const Array<octave_idx_type>& ra_idx)
{
  Octave_map m1 = v1.map_value ();
  Octave_map m2 = v2.map_value ();

  dim_vector dv1 (m1.dims ());

  Octave_map retval (dv1);

  Cell c2 (m2.dims ());

  for (Octave_map::const_iterator pa = m1.begin (); pa != m1.end (); pa++)
    {
      Octave_map::const_iterator pb = m2.seek (m1.key(pa));

      if (pb == m2.end ())
	retval.assign (m1.key(pa),
		       m1.contents(pa).insert (c2, ra_idx));
      else
	retval.assign (m1.key(pa),
		       m1.contents(pa).insert (m2.contents(pb), ra_idx));
    }

  for (Octave_map::const_iterator pa = m2.begin (); pa != m2.end (); pa++)
    {
      Octave_map::const_iterator pb = m1.seek (m2.key(pa));

      if (pb == m1.end ())
	{
	  Cell c1 (dv1);
	  retval.assign (m2.key(pa),
			 c1.insert (m2.contents(pa), ra_idx));
	}
    }

  return retval;
}


DEFUN_DLD (structcat, args, , 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} structcat (@var{dim}, @var{struct1}, @dots{}, @var{structn})\n\
Return the concatenation of N-d structures @var{struct1}, @dots{}, @var{structn} along dimension @var{dim}. Differently to @code{cat}, fields need not match --- missing fields get an empty matrix value. Without structure arguments, an empty structure array is returned.\n\
@end deftypefn")
{
  std::string fname ("structcat");

  octave_value retval;

  int n_args = args.length (); 

  if (n_args == 1)
    retval = Octave_map ();
  else if (n_args == 2)
    retval = args(1).map_value ();
  else if (n_args > 2)
    {
      octave_idx_type dim = args(0).int_value () - 1;

      if (error_state)
	{
	  error ("%s: expecting first argument to be a integer",
		 fname.c_str ());
	  return retval;
	}
  
      if (dim >= 0)
	{
 	  dim_vector  dv = args(1).dims ();
	  std::string result_type ("struct");

 	  for (int i = 2; i < args.length (); i++)
  	    {
 	      // Construct a dimension vector which holds the
	      // dimensions of the final array after concatenation.
      
	      if (! dv.concat (args(i).dims (), dim))
		{
		  // Dimensions do not match. 
		  error ("%s: dimension mismatch", fname.c_str ());
		  return retval;
		}
	      
	      if (args(i).class_name () != result_type)
		{
		  error ("%s: some argument not a structure",
			 fname.c_str ());
		  return retval;
		}
	    }

	  // The lines below might seem crazy, since we take a
	  // copy of the first argument, resize it to be empty and
	  // then resize it to be full. This is done since it
	  // means that there is no recopying of data, as would
	  // happen if we used a single resize.  It should be
	  // noted that resize operation is also significantly
	  // slower than the do_cat_op function, so it makes sense
	  // to have an empty matrix and copy all data.
	  //
	  // We might also start with a empty octave_value using
	  //   tmp = octave_value_typeinfo::lookup_type 
	  //                                (args(1).type_name());
	  // and then directly resize. However, for some types there might
	  // be some additional setup needed, and so this should be avoided.

	  octave_value tmp = args (1);
	  tmp = tmp.resize (dim_vector (0, 0)).resize (dv);

	  if (error_state)
	    return retval;

	  int dv_len = dv.length ();
	  Array<octave_idx_type> ra_idx (dim_vector (dv_len, 1), 0);

	  for (int j = 1; j < n_args; j++)
	    {
	      dim_vector dv_tmp = args (j).dims ();

	      if (! dv_tmp.all_zero ())
		{
		  tmp = structcat_cat_op_fcn (tmp, args(j), ra_idx);

		  if (error_state)
		    return retval;

		  if (dim >= dv_len)
		    {
		      if (j > 1)
			error ("%s: indexing error", fname.c_str ());
		      break;
		    }
		  else
		    ra_idx (dim) += (dim < dv_tmp.length () ? 
				     dv_tmp (dim) : 1);
		}
	    }
	  retval = tmp;

	  if (! error_state)
	    {
	      // Reshape, chopping trailing singleton dimensions
	      dv.chop_trailing_singletons ();
	      retval = retval.reshape (dv);
	    }
	}
      else
	error ("%s: invalid dimension argument", fname.c_str ());
    }
  else
    print_usage ();

  return retval;
}
