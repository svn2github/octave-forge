/*
  Copyright (C) 2006-2009 Evgenii Rudnyi, http://MatrixProgramming.com
  http://Evgenii.Rudnyi.Ru/

  Copyright (C) 2011 Carlo de Falco
  
  The program reads the matrix and RHS in the Matrix Market format then run MUMPS.

  This software is a copyrighted work licensed under the terms of the GNU/GPL v2 license
  <http://www.gnu.org/licenses/gpl-2.0.txt>
*/

#include <iostream>
#include <octave/oct.h>
#include <octave/oct-map.h>
#include <string.h>

#include "dmumps_c.h"
using namespace std;

DEFUN_DLD (mumps_test, args, nargout, "")
{
  octave_value_list retval;

  Array<int> I = args(0).octave_idx_type_vector_value ();
  Array<int> J = args(1).octave_idx_type_vector_value ();

  Array<double> a = args(2).array_value ();
  Matrix rhs      = args(3).matrix_value ();

  int m = args(4).idx_type_value ();
  int n = args(5).idx_type_value ();

  if (!error_state)
    {         

      int    *Iptr = I.fortran_vec ();
      int    *Jptr = J.fortran_vec ();
      double *aptr = a.fortran_vec ();
      double *rhsptr  = rhs.fortran_vec ();

      DMUMPS_STRUC_C id;

      id.job =  -1;               // -1 = init
      id.par =   1;               // work serially
      id.sym =   0;               // non symmetric
      id.comm_fortran = -987654;  // MPI_COMM_WORLD

      dmumps_c (&id);

      // streams    
      id.icntl[0] =  -1; // Output stream for error messages
      id.icntl[1] =  -1; // Output stream for diagnostic messages
      id.icntl[2] =  -1; // Output stream for global information
      id.icntl[3] =   0; // Level of printing 

      // ordering
      id.icntl[6] =  0; // metis (5), or pord (4), or AMD (0), AMF (2), QAMD (6)	
  
      id.n  = m;
      id.nz = I.numel ();
      //      std::cout << id.n  << std::endl;
      //      std::cout << id.nz << std::endl;

      id.irn = Iptr; 
      id.jcn = Jptr;
      id.a   = aptr; 

      // Define RHS and set up MUMPS
      id.rhs  =  rhsptr;
      id.nrhs =  rhs.cols ();
      id.lrhs =  rhs.rows ();

      // Back substitution	
      id.job =  6;

      dmumps_c (&id);
  
      //      for (int i = 0; i < id.n; i ++)
      //        std::cout << resptr[i] << std::endl;

      // clean up
      id.job =  -2; 
      dmumps_c (&id);
  
      retval (0) = octave_value (rhs);
    }
  
  return (retval);	
}

