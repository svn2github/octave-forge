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

DEFUN_DLD (fields2cell, args, , 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} fields2cell (@var{s}, @var{names})\n\
Works similarly to @code{struct2cell} (see there), but considers only fields given by the strings in cell array @var{names}. Returns an error if a field is missing in @var{s}.\n\
@end deftypefn")
{
  std::string fname ("fields2cell");

  if (args.length () != 2)
    {
      print_usage ();
      return octave_value_list ();
    }

  Octave_map s = args(0).map_value ();
  if (error_state)
    {
      error ("%s: first argument must be a structure", fname.c_str ());
      return octave_value_list ();
    }

  Array<std::string> names = args(1).cellstr_value ();
  if (error_state)
    {
      error ("%s: second argument must be a cell array of strings",
	     fname.c_str ());
      return octave_value_list ();
    }

  dim_vector ndims = names.dims ();
  if (ndims.length () > 2 || (ndims(0) > 1 && ndims(1) > 1))
    {
      error ("%s: second argument must be a one-dimensional cell array",
	     fname.c_str ());
      return octave_value_list ();
    }

  octave_idx_type n = names.length ();

  dim_vector sdims = s.dims ();

  octave_idx_type n_sdims = sdims.length ();

  dim_vector dims;
  if (sdims(n_sdims - 1) == 1)
    dims.resize (n_sdims);
  else
    dims.resize (++n_sdims);

  dims(0) = n;
  for (octave_idx_type i = 1; i < n_sdims; i++)
    dims(i) = sdims(i - 1);

  Cell retval (dims);

  octave_idx_type k = s.numel ();

  for (octave_idx_type i = 0; i < n; i++)
    {
      if (! s.contains (names(i)))
	{
	  error ("%s: some fields not present", fname.c_str ());
	  return octave_value_list ();
	}

      Cell tp = s.contents (names(i));

      octave_idx_type l = i;
      for (octave_idx_type j = 0; j < k; j++)
	{
	  retval(l) = tp(j);
	  l += n;
	}
    }

  return octave_value (retval);
}
