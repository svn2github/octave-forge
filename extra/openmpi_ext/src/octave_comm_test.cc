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

DEFUN_DLD(octave_comm_test, args, ,"")
{
  if (!octave_comm_type_loaded)
    {
      octave_comm::register_type ();
      octave_comm_type_loaded = true;
      mlock ();
    }



	octave_value retval;
	if(args.length() < 1 
	   || args(0).type_id()!=octave_comm::static_type_id()){
		
		error("Please enter a comunicator object!");
		return octave_value(-1);
	}


	const octave_base_value& rep = args(0).get_rep();
	const octave_comm& b = ((const octave_comm &)rep);
// 	this is the amazing result I can create as many comunicators I want
// simply accessing from the public property of the octave_comm object
	MPI_Comm gt = b.comm;
  return retval;
}