/*
  Copyright (C) 2011 Carlo de Falco
  This software is distributed under the terms 
  the terms of the GNU/GPL licence v3
*/


#include <mumps_class.h>


void mumps::init ()
{
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
}


void mumps::set_lhs_structure (int n, std::vector<int> &ir, std::vector<int> &jc)
{
  id.n  = n;
  id.nz = ir.size ();
  
  id.irn = &*ir.begin ();
  id.jcn = &*jc.begin ();
}

void mumps::analyze ()
{
  id.job = 1;
  dmumps_c (&id);
}

void mumps::set_lhs_data (std::vector<double> &xa)
{
  // Define LHS entries
  id.a   = &*xa.begin ();
}

void mumps::set_rhs (std::vector<double> &rhs)
{
  // Define RHS 
  id.rhs  =  &*rhs.begin ();
  id.nrhs =  1;
  id.lrhs =  rhs.size ();
}

void mumps::factorize ()
{
  id.job = 2;
  dmumps_c (&id);
}

void mumps::solve ()
{
  id.job = 3;
  dmumps_c (&id);
}

void mumps::cleanup ()
{
  // clean up
  id.job =  -2; 
  dmumps_c (&id);
}



