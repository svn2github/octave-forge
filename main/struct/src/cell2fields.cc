/*

Copyright (C) 2010 Olaf Till

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

#include <octave/oct.h>
#include <octave/ov-struct.h>

DEFUN_DLD (cell2fields, args, , 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} cell2fields (@var{c}, @var{fields}, @var{dim}, @var{s})\n\
Return structure @var{s} after setting the fields @var{fields} with the slices of cell-array @var{c} vertically to dimension @var{dim}. @var{s} must have matching dimensions or be empty.\n\
@end deftypefn")
{
  std::string fname ("cell2fields");

  if (args.length () != 4)
    {
      print_usage ();
      return octave_value_list ();
    }

  Cell c = args(0).cell_value ();
  if (error_state)
    {
      error ("%s: first argument must be a cell array", fname.c_str ());
      return octave_value_list ();
    }

  Array<std::string> names = args(1).cellstr_value ();
  if (error_state)
    {
      error ("%s: second argument must be a cell array of strings", fname.c_str ());
      return octave_value_list ();
    }

  if (! names.dims ().is_vector ())
    {
      error ("%s: second argument must be a one-dimensional cell array",
	     fname.c_str ());
      return octave_value_list ();
    }

  octave_idx_type dim = args(2).int_value ();
  if (error_state)
    {
      error ("%s: second argument must be an integer",
	     fname.c_str ());
      return octave_value_list ();
    }

  Octave_map s = args(3).map_value ();
  if (error_state)
    {
      error ("%s: third argument must be a structure", fname.c_str ());
      return octave_value_list ();
    }

  octave_idx_type i, j;

  dim_vector cdims (c.dims ());

  octave_idx_type n_cdims = cdims.length ();

  dim_vector tdims (cdims);

  octave_idx_type nr = 1;

  if (n_cdims >= dim && cdims(dim - 1) > 1)
    {
      nr = cdims(dim - 1);

      tdims(dim - 1) = 1;

      tdims.chop_trailing_singletons ();
    }

  if (nr != names.numel ())
    {
      error ("%s: second argument has incorrect length", fname.c_str ());

      return octave_value_list ();
    }

  Octave_map retval;

  if (s.keys (). length () == 0)
    retval.resize (tdims);
  else
    {
      if (s.dims () != tdims)
	{
	  error ("%s: structure has incorrect dimenstions", fname.c_str ());

	  return octave_value_list ();
	}
      retval = (s);
    }

  octave_idx_type nt = tdims.numel ();

  octave_idx_type base = 0, origin, cursor;

  octave_idx_type skip_count = 1; // when to skip

  octave_idx_type min_tp = n_cdims < dim - 1 ? n_cdims : dim - 1;

  for (i = 0; i < min_tp; i++)
    skip_count *= cdims(i);

  octave_idx_type skip = skip_count; // how much to skip

  if (n_cdims >= dim)
    skip *= cdims(dim - 1);

  for (i = 0; i < nr; i++)
    {
      Cell t (tdims);

      origin = base;

      cursor = 0;

      for (j = 0; j < nt; j++)
	{
	  t(j) = c(origin + cursor++);

	  if (cursor == skip_count)
	    {
	      cursor = 0;

	      origin += skip;
	    }
	}

      retval.assign (names(i), t);

      base += skip_count;
    }

  return octave_value (retval);
}
