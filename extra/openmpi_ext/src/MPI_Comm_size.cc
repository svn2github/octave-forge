// Copyright (C) 2004-2007 Javier Fernández Baldomero, Mancia Anguita López
// This code has been adjusted for octave3.2.3 and more in 
// 2009 by  Riccardo Corradini <riccardocorradini@yahoo.it>

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

#define   NAME  MPI_Comm_size
/*
 * ----------------------------------------------------
 * Determines the size of the calling process in the communicator
 * [info rank] = MPI_Comm_size (comm)
 * ----------------------------------------------------
 */

#include "mpi.h"       
#include <octave/oct.h>

DEFUN_DLD(NAME, args, nargout,
"MPI_Comm_size          Determines rank of calling process in communicator\n\
\n\
  [info rank] =  MPI_Comm_size (comm)\n\
\n\
  comm (int) communicator handle. MPI_COMM_NULL not valid\n\
  size (int) size of the calling process in group of comm\n\
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
    int my_size;
    int info = MPI_Comm_size(MPI_COMM_WORLD,&my_size);
    results(0) = info;
    results(1) = my_size;

    /* [info rank] = MPI_Comm_size (comm) */
   
    return results;
}

