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

// PKG_ADD: autoload ("pq_close", "pq_interface.oct");

DEFUN_DLD (pq_close, args, ,
           "-*- texinfo -*-\n\
@deftypefn {Loadable Function} {@var{id}} pq_close (@var{connection})\n\
Text.\n\
\n\
@end deftypefn")
{
  std::string fname ("pq_close");

  if (args.length () != 1 ||
      args(0).type_id () != octave_pq_connection::static_type_id ())
    {
      print_usage ();

      return octave_value_list ();
    }

  octave_base_value& rep = const_cast<octave_base_value&> (args(0).get_rep ());

  octave_pq_connection &oct_pq_conn = dynamic_cast<octave_pq_connection&> (rep);

  oct_pq_conn.octave_pq_close ();

  return octave_value_list ();
}
