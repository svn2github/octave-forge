// Copyright (C) 2009 Riccardo Corradini <riccardocorradini@yahoo.it>
// under the terms of the GNU General Public License.
// Copyright (C) 2009 VZLU Prague
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; If not, see <http://www.gnu.org/licenses/>.

#include "octave_comm.h"


DEFUN_DLD(octave_comm_make, args, ,"")
{
  if (!octave_comm_type_loaded)
    {
      octave_comm::register_type ();
      octave_comm_type_loaded = true;
      mlock ();
    }

   octave_value retval;
  if (args.length () != 1 || !args (0).is_string ())
    {
      error ("octave_comm: first argument must be a string");
      return retval;
    }
   
  const std::string name = args (0).string_value ();
   
  retval = new octave_comm (name);
  return retval;

}