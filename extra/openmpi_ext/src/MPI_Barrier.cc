// Copyright (C) 2004-2007 Javier Fernández Baldomero, Mancia Anguita López
// This code has been adjusted for octave3.2.3 and more in 
// 2009 by  Riccardo Corradini <riccardocorradini@yahoo.it>
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

#define   NAME  MPI_Barrier
/*
 * ----------------------------------------------------
 * Blocks until all processes in the communicator have reached this routine
 * [info ] = MPI_Barrier (comm)
 * ----------------------------------------------------
 */

#include "octave_comm.h"    

DEFUN_DLD(NAME, args, nargout,
"MPI_Barrier          Blocks until all processes in the communicator have reached this routine\n\
\n\
  [info] =  MPI_Barrier (comm)\n\
\n\
  comm (int) communicator handle. MPI_COMM_NULL not valid\n\
\n\
  info (int) return code\n\
      0 MPI_SUCCESS    No error\n\
      5 MPI_ERR_COMM   Invalid communicator (NULL?)\n\
     13 MPI_ERR_ARG    Invalid argument (typically a NULL pointer?)\n\
\n\
  SEE ALSO: MPI_Comm_rank\n\
            comms\n\
\n\
")

{
    octave_value_list results;
    int nargin = args.length ();
   if (nargin != 1)
     {
       error ("expecting  1 input argument");
       return results;
     }

  if (!octave_comm_type_loaded)
    {
      octave_comm::register_type ();
      octave_comm_type_loaded = true;
      mlock ();
    }

	if (args(0).type_id()!=octave_comm::static_type_id()){
		
		error("Please enter a comunicator object!");
		return octave_value(-1);
	}


	const octave_base_value& rep = args(0).get_rep();
	const octave_comm& b = ((const octave_comm &)rep);
	MPI_Comm comm = b.comm;
	if (b.name == "MPI_COMM_WORLD")
	{
	 comm = MPI_COMM_WORLD;
	}
	else
	{
	 error("Other MPI Comunicator not yet implemented!");
	}
        if (! error_state)
          {
            int my_size;
            int info = MPI_Barrier (comm);
            if (nargout > 1)
              results(1) = info;
            results(0) = my_size;
          }
    else
      print_usage ();

    /* [info] = MPI_Barrier (comm) */
   
    return results;
}

