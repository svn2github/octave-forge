/*

Copyright (C) 2010, 2011, 2012 Olaf Till

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

// Code of the files of Octave-3.2.4 src/data.cc (do_cat()), src/ov.cc
// (do_cat_op ()), src/OPERATORS/op-struct.cc, src/ops.h, and
// oct-map.cc (Octave_map::concat ()) has been studied and initially
// re-used, but in the end it has been made differently here.

#include <octave/oct.h>
#include <octave/ov-struct.h>

static Octave_map
structcat_op_fcn (const Octave_map& m1, const Octave_map& m2,
		      const dim_vector& dv,
		      const Array<octave_idx_type>& ra_idx,
		      const octave_value& fillv)
{
  Octave_map retval (dv);

  Cell c2 (m2.dims (), fillv);

  for (Octave_map::const_iterator pa = m1.begin (); pa != m1.end (); pa++)
    {
      Cell c (dv);

      c.insert (m1.contents(pa), 0, 0);

      Octave_map::const_iterator pb = m2.seek (m1.key(pa));

      if (pb == m2.end ())
	c.insert (c2, ra_idx);
      else
	c.insert (m2.contents(pb), ra_idx);

      retval.assign (m1.key(pa), c);
    }

  for (Octave_map::const_iterator pa = m2.begin (); pa != m2.end (); pa++)
    {
      Octave_map::const_iterator pb = m1.seek (m2.key(pa));

      if (pb == m1.end ())
	{
	  Cell c (dv, fillv);

	  retval.assign (m2.key(pa),
			 c.insert (m2.contents(pa), ra_idx));
	}
    }

  return retval;
}


DEFUN_DLD (structcat, args, , 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} structcat (@var{dim}, @var{struct1}, @dots{}, @var{structn})\n\
@deftypefnx {Loadable Function} {} structcat (@var{dim}, @var{default}, @var{struct1}, @dots{}, @var{structn})\n\
Return the concatenation of N-d structures @var{struct1}, @dots{}, @var{structn} along dimension @var{dim}. Differently to @code{cat}, fields need not match --- missing fields get an empty matrix value. Without structure arguments, an empty structure array is returned. If a scalar argument @var{default} is given, missing fields get its value instead of an empty matrix value.\n\
\n\
@seealso{structcat_default}\n\
@end deftypefn")
{
  std::string fname ("structcat");

  Octave_map retval;

  octave_idx_type n_args = args.length ();

  if (n_args == 0)
    print_usage ();
  else
    {
      octave_idx_type dim = args(0).int_value () - 1;

      if (error_state || dim < 0)
	{
	  error ("%s: first argument must be a positive integer",
		 fname.c_str ());
	  return octave_value ();
	}

      octave_idx_type m1_id;
      octave_value fillv;

      if (n_args > 1 && args(1).is_scalar_type ())
	{
	  m1_id = 2;

	  fillv = args(1);
	}
      else
	{
	  m1_id = 1;

	  fillv = Matrix ();
	}

      dim_vector dv;

      octave_idx_type idx_len = dv.length ();

      if (dim >= idx_len) idx_len = dim + 1;

      Array<octave_idx_type> ra_idx (dim_vector (idx_len, 1), 0);

      for (octave_idx_type i = m1_id; i < n_args; i++)
	{
	  if (! args(i).is_map ())
	    {
	      error ("%s: some argument not a structure", fname.c_str ());

	      return octave_value ();
	    }

	  dim_vector dvi = args(i).dims (), old_dv = dv;

	  if (! dv.concat (dvi, dim))
	    {
	      error ("%s: dimension mismatch", fname.c_str ());

	      return octave_value ();
	    }

	  if (! dvi.all_zero ())
	    {
	      retval = structcat_op_fcn (retval, args(i).map_value (),
					 dv, ra_idx, fillv);

	      ra_idx(dim) += (dim < dvi.length () ? dvi(dim) : 1);
	    }
	}  
    }
  return octave_value (retval);
}
