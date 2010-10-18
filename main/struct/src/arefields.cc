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

DEFUN_DLD (arefields, args, , 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} arefields (@var{s}, @var{names})\n\
Return a logical vector indicating which of the strings in cell array @var{names} is a valid field name of structure @var{s}.\n\
@end deftypefn")
{
  std::string fname ("arefields");

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

  dim_vector dims = names.dims ();
  if (dims.length () > 2 ||
      (dims(0) > 1 && dims(1) > 1))
    {
      error ("%s: second argument must be a one-dimensional cell array",
	     fname.c_str ());
      return octave_value_list ();
    }

  boolMatrix retval (dims);

  octave_idx_type n = names.length ();
  for (octave_idx_type i = 0; i < n; i++)
    {
      if (s.contains (names(i)))
	retval(i) = true;
      else
	retval(i) = false;
    }

  return octave_value (retval);
}
