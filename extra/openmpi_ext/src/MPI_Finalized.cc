// Copyright (C) 2004-2007 Javier Fernández Baldomero, Mancia Anguita López
// This code has been adjusted for octave3.2.3 and more in 
// 2009 by  Riccardo Corradini <riccardocorradini@yahoo.it>

// under the terms of the GNU General Public License.
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

#define   NAME  MPI_Finalized
/*
 * ----------------------------------------------------
 * Indicates whether MPI_Finalize has completed
 * [info flag] = MPI_Finalized
 * ----------------------------------------------------
 */
#include "mpi.h"       
#include <octave/oct.h>

DEFUN_DLD(NAME, args, nargout,
"MPI_Finalized          Indicates whether MPI_Finalize has completed\n\
\n\
  [info flag] = MPI_Finalized\n\
\n\
  flag(int) 0 false\n\
            1 true\n\
\n\
  info(int) return code\n\
      0 MPI_SUCCESS    This function always returns MPI_SUCCESS\n\
\n\
  SEE ALSO: MPI_Init, MPI_Finalize, MPI_Initialized\n\
            misc\n\
\n\
")
{
   octave_value_list results;
    int flag;           



    int info = MPI_Finalized(&flag);
    results(0) = info;
    results(1) = flag;
    return results;

    /* [info flag] = MPI_Finalized */
}
