/*

Copyright (C) 2012 Olaf Till <i7tiol@t-online.de>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; If not, see <http://www.gnu.org/licenses/>.

*/

#include <octave/oct.h>

#include "pq_connection.h"


// PKG_ADD: autoload ("__pq_connect__", "pq_interface.oct");

DEFUN_DLD (__pq_connect__, args, ,
           "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{id}} __pq_connect__ (@var{options})\n\
Text.\n\
\n\
@end deftypefn")
{
  std::string fname ("__pq_connect__");

  if (args.length () != 1)
    {
      print_usage ();

      return octave_value_list ();
    }

  std::string opt_string = args(0).string_value ();

  if (error_state)
    {
      error ("%s: argument not a string", fname.c_str ());

      return octave_value_list ();
    }

  octave_value retval (new octave_pq_connection (opt_string));

  // We spare checking
  // bool(octave_pq_connection_rep::octave_pq_get_conn()), since in
  // case of false there was an error thrown, so destruction of the
  // octave_pq_connection object will be caused by Octaves reference
  // counting scheme.
  return retval;
}
