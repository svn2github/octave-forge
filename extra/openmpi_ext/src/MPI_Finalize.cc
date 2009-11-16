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

#define   NAME    MPI_Finalize
/*
 * ----------------------------------------------------
 * Terminates MPI execution environment
 * info = MPI_Finalize
 * ----------------------------------------------------
 */
#include "mpi.h"       
#include <octave/oct.h>

DEFUN_DLD(NAME, args, nargout,
"MPI_Finalize           Terminates MPI execution environment\n\
\n\
  info = MPI_Finalize\n\
\n\
  info(int) return code\n\
      0 MPI_SUCCESS    No error\n\
     17 MPI_ERR_INTERN This is fatal. Please send bug report to OPENMPI\n\
     16 MPI_ERR_OTHER  A different thread attempts to finalize MPI than\n\
                       the thread that initialized MPI\n\
\n\
  SEE ALSO: MPI_Init, MPI_Initialized, MPI_Finalized\n\
            misc\n\
\n\
")
{

    int info = MPI_Finalize();
   
    return octave_value(info);
}
