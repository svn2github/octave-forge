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

#define   NAME  MPI_Initialized
/*
 * ----------------------------------------------------
 * Indicates whether MPI_Initialize has been called
 * [info flag] = MPI_Initialized
 * ----------------------------------------------------
 */
#include "mpi.h"
#include <octave/oct.h>

DEFUN_DLD(NAME, args, nargout,
"MPI_Initialized        Indicates whether MPI_Init has been called\n\
\n\
 [flag info] = MPI_Initialized\n\
\n\
 flag(int) 0 false\n\
           1 true\n\
\n\
 info(int) return code\n\
     0 MPI_SUCCESS    This function always returns MPI_SUCCESS\n\
\n\
 SEE ALSO: MPI_Init, MPI_Finalize,\n\
           misc\n\
\n\
")
{
  octave_value_list results;
   int flag;

   int info = MPI_Initialized(&flag);
    if (nargout > 1)
      results(1) = info;
    results(0) = flag != 0;
   return results;

   /* [flag info] = MPI_Initialized */
}
