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

DEFUN_DLD (fieldempty, args, , 
  "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {} fieldempty (@var{s}, @var{name})\n\
Returns a logical array with same dimensions as structure @var{s}, indicating where field @var{name} is empty.\n\
@end deftypefn")
{
  std::string fname ("fieldempty");

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

  std::string name = args(1).string_value ();
  if (error_state)
    {
      error ("%s: second argument must be a string", fname.c_str ());
      return octave_value_list ();
    }

  if (! s.contains (name))
    {
      error ("%s: no such field", fname.c_str ());
      return octave_value_list ();
    }

  dim_vector sdims = s.dims ();

  boolNDArray retval (sdims);

  octave_idx_type numel = s.numel ();

  if (! numel)
    return octave_value (retval);

  Cell c (s.contents (name));

  for (octave_idx_type i = 0; i < numel; i++)
    {
      if (c(i).numel ())
	retval(i) = false;
      else
	retval(i) = true;
    }

  return octave_value (retval);
}
